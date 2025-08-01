//
//  ContentView.swift
//  SkinSuit
//
//  Created by AndyDent on 26/1/2023.
//

import SwiftUI
import SpriteKit

#if os(macOS)
import AppKit
#endif

enum RecordType: Int {
    case replayKitInMemory
    case replayKitFiltering
    case frameWise
}

// little helper pulled out because need to use .sheet or .fullScreenCover depending on platform
struct PreviewContent: View {
    let exporter: ExportSKVideo
    let onDisappear:  () -> Void
    
    // @escaping @Sendable @convention(block) () -> Void
    var body: some View {
        exporter.makePreview()
            .onDisappear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    self.onDisappear() }
            }
    }
}


struct ContentView: View {
    
    @State var isFullScreenSK = false
    @State var isShowingReplayPreview = false
    @State var isDirectRecording = false
    @State var exporter = ExportSKVideo()
    @State private var exportTabSelection = RecordType.replayKitInMemory
    @State var resultMessage = ""
    @State var exportStatus = ""
    var wrappedSKView = SKViewOwner() // coordinator for video exporter to be able to affect preview
    @StateObject var wrappedMetalView = MetalViewOwner() // for video exporter to be able to publish frames whilst exporting
    private var frameWiseConfig = MovieExportConfiguration.zero  // defer getting size from view then remember
    @State private var showingConfigEditor = false
    private var maker = TapppableEmitterSceneMaker(onTouch: {})  // MUST not be inline in the SpriteKitContainerWithGen init because that is rebuilt regularly
    
    var body: some View {
        if isDirectRecording {  // replace instructional labels with big counter and stop button
            VStack {
                MetalViewContainer(playsOn: wrappedMetalView, texture: $wrappedMetalView.texture)  // TODO maybe just bind directly to the playsOn, think the need to have binding to the texture is to force updates
                    .aspectRatio(frameWiseConfig.movieAspectRatio, contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .layoutPriority(1)
                    .border(Color.gray, width: 2)
                Spacer()
                Text("Writing \(frameWiseConfig.movieFormatDescription)")
                    .font(.subheadline)
                Spacer()
                ZStack {
                    HStack {
                        Spacer()
                        Button("Stop export", systemImage: "stop.circle") {
                            exporter.stopRecordingFramewise()
                            exportStatus = ""
                        }
                        .padding()
                        .buttonStyle(.bordered)
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Text(exportStatus)
                            .font(.headline.monospacedDigit())
                        Spacer().frame(width: 8)
                    }
                } // ZStack to put controls at right
                Spacer()
            }
        } else {
            VStack {
                SpriteKitContainerWithGen(sceneMaker: maker, playsOn: wrappedSKView)  // sized to fit above UI, full-screen or hidden when direct-recording
                                                                                      // controls below the video, may be hidden by it expanding
                if !isFullScreenSK {
                    VStack {
                        Text("Choose a movie export method")
                            .font(.subheadline)
                        Text(exportTabSelection == .frameWise ?
                             "Videos are exported to your Documents folder" :
                                "Tap full-screen views to stop recording")
                        .font(.caption)
                    }
                    Picker("", selection: $exportTabSelection) {
                        Text("ReplayKit Full screen").tag(RecordType.replayKitInMemory)
                        //Text("ReplayKit Cropped").tag(RecordType.replayKitFiltering)
                        Text("Framewise").tag(RecordType.frameWise)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    if exportTabSelection == .frameWise {
                        ZStack {
                            Button("Export video") {
                                guard wrappedSKView.ownedView != nil else {
                                    print("Impossible condition of no SKView in the wrapper")
                                    return
                                }
                                ensureHaveExportSize()
                                exporter.exportFrameWise(isRecordingFlag: $isDirectRecording,
                                                         resultIn: $resultMessage, logIn: $exportStatus,
                                                         config: frameWiseConfig, fromView: wrappedSKView, metalPreviewVia: wrappedMetalView,
                                                         sceneMaker: maker
                                )
                            }
                            .buttonStyle(.borderedProminent)
                            HStack {
                                Spacer()
                                // export settings
                                Button("", systemImage: "slider.horizontal.3") {
                                    ensureHaveExportSize()
                                    showingConfigEditor.toggle()
                                }
                                .popover(isPresented: $showingConfigEditor) {
                                    ExportConfigEditorView(configuration: frameWiseConfig)
                                        .frame(width: 300, height: 360)
                                        .padding()
                                }
                                .font(.title)
                                Spacer().frame(width: 8)
                            }
                        } // ZStack to put controls at right
                        
                    } else {
                        Button("Export video") {
                            // using ReplayKit so keep playing, we're going to expand to fullscreen and capture the entire phone
                            exporter.export(mode: exportTabSelection,  // actually do the video export
                                            fullScreenFlag: $isFullScreenSK,
                                            previewFlag: $isShowingReplayPreview,
                                            resultIn: $resultMessage)
                            
                        }
                        .buttonStyle(.borderedProminent)
                    }  // export tab alternatives
                    Spacer()
                    HStack {
                        Text(resultMessage) // only has content during or after a video export
                            .font(.subheadline)
                        if exporter.hasExportedVideo {
#if os(iOS)
                            ShareLink(item: exporter.frameWiseVideoURL!)
#else
                            Button("Open exported video") {
                                openVideo(at: exporter.frameWiseVideoURL!)
                            }
#endif
                        }
                    }
                    Spacer(minLength: 40)
                }
            }  // VStack for main content other than during isDirectRecording
            .onAppear {
                maker.onTouch = {
                    exporter.stopRecording()
                }
            }
            .edgesIgnoringSafeArea(isFullScreenSK ? .all : .init())
#if os(iOS)
            //REPLAYKIT horrible hack but kinda works
            //note anything other than .fullScreenCover fails on iOS as the embedded VC stubbornly refuses to resize
            //this also has to be used in combination with UIViewController.present in makeViewController
            .fullScreenCover(isPresented: $isShowingReplayPreview) {
                PreviewContent(exporter: exporter) {
                    withAnimation {
                        resultMessage = ""
                    }
                }
            }
#else
            //REPLAYKIT abandoned on macOS
            .sheet(isPresented: $isShowingReplayPreview) {
                PreviewContent(exporter: exporter) {
                    withAnimation {
                        resultMessage = ""
                    }
                }
            }  //sheet
#endif
        }
    }
    
    private func ensureHaveExportSize() {
        if frameWiseConfig.needsSizing && showingConfigEditor == false {
            guard let skv = wrappedSKView.ownedView else { return }
            frameWiseConfig.useSizeIfNotSet(skv.bounds.size)
        }
    }
    
    
#if os(macOS)
    /// Opens a video URL in the user’s default player on macOS.
    func openVideo(at url: URL) {
        NSWorkspace.shared.open(url)
    }
#endif
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


