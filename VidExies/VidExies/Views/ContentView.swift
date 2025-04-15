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
    @State var exporter = ExportSKVideo()
    @State private var exportTabSelection = RecordType.replayKitInMemory
    @State var resultMessage = ""
    
    var body: some View {
        VStack {
            SpriteKitContainerWithGen(sceneMaker: TapppableEmitterSceneMaker(onTouch: {
                self.exporter.stopRecording()
            }))
            // controls below the video, may be hidden by it expanding
            if !isFullScreenSK {
                Text("Choose a movie export method")
                    .font(.subheadline)
                Text("Tap full-screen views to stop recording")
                    .font(.caption)
                Picker("", selection: $exportTabSelection) {
                    Text("ReplayKit Full screen").tag(RecordType.replayKitInMemory)
                    Text("ReplayKit Cropped").tag(RecordType.replayKitFiltering)
                    Text("Framewise").tag(RecordType.frameWise)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                if resultMessage.isEmpty {
                    Button("Export video") {
                        exporter.export(mode: exportTabSelection,  // actually do the video export
                                        fullScreenFlag: $isFullScreenSK,
                                        previewFlag: $isShowingReplayPreview,
                                        resultIn: $resultMessage)
                    }
                    .disabled(exportTabSelection == .replayKitFiltering)
                    .buttonStyle(.borderedProminent)
                } else {
                    Text(resultMessage)
                        .font(.subheadline)
                }
                Spacer()
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

