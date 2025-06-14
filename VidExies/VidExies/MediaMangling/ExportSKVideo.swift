//
//  ExportSKVideo.swift
//  VidExies
//
//  Created by Andy Dent on 18/3/2025.
//
import SwiftUI
import SpriteKit
import ReplayKit

class ExportSKVideo {
    
    private var replayRecorder: ReplayKitRecorder? = nil
    private var replayPreviewer: RPPreviewViewController? = nil
    private var isShowingContentToRecord: Binding<Bool>? = nil
    private var isShowingPreview: Binding<Bool>? = nil
    private var resultMessage: Binding<String>? = nil
    private var currentMode = RecordType.replayKitInMemory
    private var exportingScene: SKScene? = nil
    private var previewPlayer: SKView? = nil
    private var framewiseRecorder: FrameCaptureRecorder? = nil
    private var framewiseWriter: AVAssetWriter? = nil  // need member to finalise on stop
    private var framewiseTimer: OffscreenRenderTimer? = nil
    private var saveScaleMode: SKSceneScaleMode = .aspectFit
    
    public func export(mode: RecordType, fullScreenFlag: Binding<Bool>, previewFlag: Binding<Bool>, resultIn: Binding<String>, exportSize: CGSize = CGSize(width: 400, height: 400)) {
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
            print("use exportDirectRender instead so can render in background")
            
        default:
            print("unknown export mode")
            self.isShowingPreview = nil
            isShowingContentToRecord = nil
            resultMessage = nil
        }
        
    }
    
    public func exportFrameWise(isRecordingFlag: Binding<Bool>, resultIn: Binding<String>, logIn: Binding<String>, exportSize: CGSize, fromView: SKView) {
        guard let activeScene = fromView.scene as? RecordableScene else {
            print("No active scene to export")  // something very weirdly wrong
            return
        }
        let videoURL = makeVideoFileURL()
        resultMessage = resultIn
        do {
            let (writer, _, pixelBufferAdaptor) = try makeAssetWriter(for: videoURL, size: exportSize)
            writer.startWriting()
            writer.startSession(atSourceTime: .zero)  // this source time bothers me if we're picking up a scene that's already run a while
            previewPlayer = fromView
            activeScene.isPaused = true
            saveScaleMode = activeScene.scaleMode
            fromView.presentScene(nil)  // stop it playing on the main SKView (wrapped in SpriteKitContainerWithGen)
            exportingScene = activeScene
            activeScene.scaleMode = .fill  // prevent resize now not rendering to Retina surface
            framewiseRecorder = FrameCaptureRecorder(scene: activeScene, pixelBufferAdaptor: pixelBufferAdaptor, size: exportSize)
            framewiseWriter = writer
            framewiseTimer = OffscreenRenderTimer(recorder: framewiseRecorder!) { (atTime: CMTime) in
                DispatchQueue.main.async {
                    logIn.wrappedValue = atTime.toMinuteSecondString()
                }
            }
            framewiseTimer?.startRendering(fromTime: activeScene.lastFrameTime)
            activeScene.isPaused = false  // undo being paused by presentScene(nil)
            activeScene.size = exportSize
            isShowingContentToRecord = isRecordingFlag  // save so final completion can toggle, eg to hide a Stop button
            isRecordingFlag.wrappedValue = true
            print("Recording to: \(videoURL)")
        } catch {
            print("Error setting up video writer: \(error.localizedDescription) for URL \(videoURL)")
        }
    }
    
    // invoked by tap on preview movie
    public func stopRecording() {
        guard let rr = replayRecorder else {
            print("stopRecording invoked when not recording")
            return
        }
        rr.stopRecording() { previewVC in
            self.isShowingContentToRecord?.wrappedValue = false  // cancel full screen regqrdless
            self.replayPreviewer = previewVC
            self.isShowingPreview?.wrappedValue = previewVC != nil  // should make sheet aqppear
            if self.currentMode == .replayKitInMemory {
                self.resultMessage?.wrappedValue = "Saved movies appear in Photos"
            }
        }
    }
    
    // invoked by tap on preview movie
    public func stopRecordingFramewise() {
        guard let toStop = framewiseWriter  else {
            print("stopRecordingFramewise invoked when not recording")
            return
        }
        self.isShowingContentToRecord?.wrappedValue = false  // hide buttons
        exportingScene?.isPaused = true
        framewiseTimer?.stopRendering {
            self.framewiseRecorder?.markAsFinished()
            toStop.finishWriting {  // only after timer stops generating!
                self.framewiseWriter = nil
                self.framewiseRecorder = nil
                self.framewiseTimer = nil
                self.resultMessage?.wrappedValue = "Saved to \(toStop.outputURL.absoluteString)"
                self.exportingScene?.scaleMode = self.saveScaleMode
                self.previewPlayer?.presentScene(self.exportingScene)  // give it back to preview on main screen
            }
        }
    }
    
    public func makePreview() -> PreviewContainer {
        guard let parentPresentingPreview = isShowingPreview, let previewer = replayPreviewer else {
            fatalError("makePreview called without bound flag to stop presenting")
        }
        return PreviewContainer(previewViewController: previewer, isShowingPreview: parentPresentingPreview)
    }
    
    func makeVideoFileURL() -> URL {
        let fm = FileManager.default
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyyMMdd_HHmmss"
        let filename = "VidExies_\(fmt.string(from: Date())).mp4"
        return docs.appendingPathComponent(filename)
    }
    
    func makeAssetWriter(for url: URL, size: CGSize) throws
    -> (writer: AVAssetWriter, input: AVAssetWriterInput, adaptor: AVAssetWriterInputPixelBufferAdaptor)
    {
        // a) Create writer
        let writer = try AVAssetWriter(outputURL: url, fileType: .mp4)
        
        // b) Video settings matching your scene’s resolution
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey:  size.width,
            AVVideoHeightKey: size.height
        ]
        let input = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        input.expectsMediaDataInRealTime = true
        
        guard writer.canAdd(input) else {
            fatalError("Cannot add video input to writer")
        }
        writer.add(input)
        
        // c) Pixel buffer attributes for Metal compatibility
        let sourceBufferAttrs: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey as String: Int(size.width),
            kCVPixelBufferHeightKey as String: Int(size.height),
            kCVPixelBufferMetalCompatibilityKey as String: true
        ]
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: input,
            sourcePixelBufferAttributes: sourceBufferAttrs
        )
        
        return (writer, input, adaptor)
    }
    
}

import CoreMedia

extension CMTime {
    /// Formats the time as "MM:SS.mmm"
    func toMinuteSecondString() -> String {
        // Convert to seconds as a Double
        let totalSeconds = CMTimeGetSeconds(self)
        guard totalSeconds.isFinite else {
            return "invalid time"
        }

        // Break into integer seconds and fractional milliseconds
        let minutes = Int(totalSeconds) / 60
        let seconds = Int(totalSeconds) % 60
        let milliseconds = Int((totalSeconds - floor(totalSeconds)) * 1000)

        // Format with leading zeros: 02d for minutes/seconds, 03d for millis
        return String(format: "%02d:%02d.%03d", minutes, seconds, milliseconds)
    }
}
