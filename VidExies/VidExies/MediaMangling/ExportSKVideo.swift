//
//  ExportSKVideo.swift
//  VidExies
//
//  Created by Andy Dent on 18/3/2025.
//
import SwiftUI
import ReplayKit

class ExportSKVideo {
    
    private var replayRecorder: ReplayKitRecorder? = nil
    private var replayPreviewer: RPPreviewViewController? = nil
    private var isShowingContentToRecord: Binding<Bool>? = nil
    private var isShowingPreview: Binding<Bool>? = nil
    private var resultMessage: Binding<String>? = nil
    private var currentMode = RecordType.replayKitInMemory

    public func export(mode: RecordType, fullScreenFlag: Binding<Bool>, previewFlag: Binding<Bool>, resultIn: Binding<String>) {
        currentMode = mode
        switch mode {
            
        case .replayKitInMemory:
            fullScreenFlag.wrappedValue = true
            isShowingContentToRecord = fullScreenFlag  // save so final completion can toggle
            self.isShowingPreview = previewFlag
            replayRecorder = ReplayKitRecorder()
            replayRecorder?.startRecording()
            resultMessage = resultIn
        
        case .frameWise:
            fullScreenFlag.wrappedValue = true
            isShowingContentToRecord = fullScreenFlag  // save so final completion can toggle
            self.isShowingPreview = previewFlag

        default:
            print("unknown export mode")
            self.isShowingPreview = nil
            isShowingContentToRecord = nil
            resultMessage = nil
        }
        
    }
    
    public func stopRecording() {
        if let rr = replayRecorder {
            rr.stopRecording() { previewVC in
                self.isShowingContentToRecord?.wrappedValue = false  // cancel full screen regqrdless
                self.replayPreviewer = previewVC
                self.isShowingPreview?.wrappedValue = previewVC != nil  // should make sheet aqppear
                if self.currentMode == .replayKitInMemory {
                    self.resultMessage?.wrappedValue = "Saved movies appear in Photos"
                }
            }
        } else {
            print("stopRecording invoked when not recording")
        }
    }
    
    public func makePreview() -> PreviewContainer {
        guard let parentPresentingPreview = isShowingPreview, let previewer = replayPreviewer else {
            fatalError("makePreview called without bound flag to stop presenting")
        }
        return PreviewContainer(previewViewController: previewer, isShowingPreview: parentPresentingPreview)
    }

}
