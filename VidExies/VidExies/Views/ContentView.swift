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
    case other
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
                    Text("Framewise").tag(RecordType.other)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                if resultMessage.isEmpty {
                    Button("Export video") {
                        exporter.export(mode: exportTabSelection,
                                        fullScreenFlag: $isFullScreenSK,
                                        previewFlag: $isShowingReplayPreview,
                                        resultIn: $resultMessage)
                    }
                    .disabled(exportTabSelection != .replayKitInMemory)  // first sample just in memory
                    .buttonStyle(.borderedProminent)
                } else {
                    Text(resultMessage)
                        .font(.subheadline)
                }
                Spacer()
            }
        }
        .edgesIgnoringSafeArea(isFullScreenSK ? .all : .init())
        .fullScreenCover(isPresented: $isShowingReplayPreview) {
            exporter.makePreview()
                .onDisappear {
                    // if a message left from preview, fade it out
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation {
                            resultMessage = ""
                        }
                    }
                }
    }  // sheet
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

