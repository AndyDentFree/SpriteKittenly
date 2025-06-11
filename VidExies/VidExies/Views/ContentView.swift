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
    
    var body: some View {
        VStack {
            SpriteKitContainerWithGen(sceneMaker: TapppableEmitterSceneMaker(onTouch: {
                self.exporter.stopRecording()
            }),
                                      playsOn: wrappedSKView
            )
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
                        Button("Export video (framewise)") {
                            guard let skv = wrappedSKView.ownedView else {
                                return
                            }
                            // force a different size from the current view just to see what happens
                            let exportSize = skv.bounds.size  // CGSize(width: 400, height: 400)
                            exporter.exportFrameWise(isRecordingFlag: $isDirectRecording,
                                                     resultIn: $resultMessage, logIn: $exportStatus,
                                                     exportSize: exportSize, fromView:skv
                            )
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    Button("Export video") {
                        // using ReplayKit so keep playing
                        exporter.export(mode: exportTabSelection,  // actually do the video export
                                        fullScreenFlag: $isFullScreenSK,
                                        previewFlag: $isShowingReplayPreview,
                                        resultIn: $resultMessage)
                        
                    }
                    .disabled(exportTabSelection == .replayKitFiltering)
                    .buttonStyle(.borderedProminent)
                }
                if !resultMessage.isEmpty {  // only during or after a video export
                    Spacer()
                    Text(resultMessage)
                        .font(.subheadline)
                }
                Spacer(minLength: 40)
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


