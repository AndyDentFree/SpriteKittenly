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
    
    @State var isFullScreen = false
    @State var exporter = ExportSKVideo()
    @State private var exportTabSelection = RecordType.replayKitInMemory
    // constants to save magic numbers being used below for segmented Picker
    fileprivate let replayKitTag = 0
    fileprivate let framewiseTag = 1

    
    var body: some View {
        VStack {
            SpriteKitContainerWithGen(sceneMaker: TapppableEmitterSceneMaker(onTouch: { self.exporter.stopRecording() }))
            // controls below the video, may be hidden by it expanding
            if !isFullScreen {
                Text("Choose a movie export method")
                    .font(.subheadline)
                Text("Tap full-screen views to stop recording")
                    .font(.caption)
                Picker("", selection: $exportTabSelection) {
                    Text("ReplayKit Sample").tag(RecordType.replayKitInMemory)
                    Text("ReplayKit Cropped").tag(RecordType.replayKitFiltering)
                    Text("Framewise").tag(RecordType.other)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                Button("Export video") {
                    exporter.export(mode: exportTabSelection, fullScreenFlag: $isFullScreen)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .edgesIgnoringSafeArea(isFullScreen ? .all : .init())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

