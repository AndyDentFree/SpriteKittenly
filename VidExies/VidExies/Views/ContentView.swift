//
//  ContentView.swift
//  SkinSuit
//
//  Created by AndyDent on 26/1/2023.
//

import SwiftUI
import SpriteKit

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
    var wrappedSKView = SKViewOwner() // hacky way for exporter to be able to affect preview
    private var frameWiseConfig = MovieExportConfiguration.zero  // defer getting size from view then remember
    @State private var showingConfigEditor = false
    private var maker = TapppableEmitterSceneMaker(onTouch: {})
    
    var body: some View {
        VStack {
            SpriteKitContainerWithGen(sceneMaker: maker, playsOn: wrappedSKView)
            // controls below the video, may be hidden by it expanding
            if !isFullScreenSK {
                if isDirectRecording {  // replace instructional labels with big counter
                    Text(exportStatus)
                        .font(.headline.monospacedDigit())
                } else {
                    VStack {
                        Text("Choose a movie export method")
                            .font(.subheadline)
                        Text(exportTabSelection == .frameWise ?
                             "Videos are exported to your Documents folder" :
                                "Tap full-screen views to stop recording")
                        .font(.caption)
                    }
                }
                Picker("", selection: $exportTabSelection) {
                    Text("ReplayKit Full screen").tag(RecordType.replayKitInMemory)
                    //Text("ReplayKit Cropped").tag(RecordType.replayKitFiltering)
                    Text("Framewise").tag(RecordType.frameWise)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                if exportTabSelection == .frameWise {
                    if isDirectRecording {
                        Button("Stop exporting (framewise)", systemImage: "stop.circle") {
                            exporter.stopRecordingFramewise()
                            exportStatus = ""
                        }
                        .buttonStyle(.bordered)
                    } else {
                        ZStack {
                            Button("Export video (framewise)") {
                                guard let skv = wrappedSKView.ownedView else {
                                    return
                                }
                                ensureHaveExportSize()
                                exporter.exportFrameWise(isRecordingFlag: $isDirectRecording,
                                                         resultIn: $resultMessage, logIn: $exportStatus,
                                                         config: frameWiseConfig, fromView: wrappedSKView
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
                    }
                } else {
                    Button("Export video") {
                        // using ReplayKit so keep playing, we're going to expand to fullscreen and capture the entire phone
                        exporter.export(mode: exportTabSelection,  // actually do the video export
                                        fullScreenFlag: $isFullScreenSK,
                                        previewFlag: $isShowingReplayPreview,
                                        resultIn: $resultMessage)
                        
                    }
                    .buttonStyle(.borderedProminent)
                }
                Spacer()
                Text(resultMessage) // only has content during or after a video export
                    .font(.subheadline)
                Spacer(minLength: 40)
            }
        }
        .onAppear {
            maker.onTouch = {
                exporter.stopRecording()
            }
        }
        .edgesIgnoringSafeArea(isFullScreenSK ? .all : .init())
#if os(iOS)
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
        .sheet(isPresented: $isShowingReplayPreview) {
            PreviewContent(exporter: exporter) {
                withAnimation {
                    resultMessage = ""
                }
            }
        }  //sheet
#endif
    }
    
    private func ensureHaveExportSize() {
        if frameWiseConfig.needsSizing && showingConfigEditor == false {
            guard let skv = wrappedSKView.ownedView else { return }
            frameWiseConfig.useSizeIfNotSet(skv.bounds.size)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


