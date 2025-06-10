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
    
    public func exportFrameWise(isRecordingFlag: Binding<Bool>, resultIn: Binding<String>, exportSize: CGSize, fromView: SKView) {
        guard let activeScene = fromView.scene as? RecordableScene else {
            print("No active scene to export")  // something very weirdly wrong
            return
        }
        let videoURL = makeVideoFileURL()
        do {
            let (writer, _, pixelBufferAdaptor) = try makeAssetWriter(for: videoURL, size: exportSize)
            writer.startWriting()
            writer.startSession(atSourceTime: .zero)  // this source time bothers me if we're picking up a scene that's already run a while
            previewPlayer = fromView
            activeScene.isPaused = true
            fromView.presentScene(nil)  // stop it playing on the main SKView (wrapped in SpriteKitContainerWithGen)
            exportingScene = activeScene
            framewiseRecorder = FrameCaptureRecorder(scene: activeScene, pixelBufferAdaptor: pixelBufferAdaptor, size: exportSize)
            framewiseWriter = writer
            framewiseTimer = OffscreenRenderTimer(recorder: framewiseRecorder!)
            framewiseTimer?.startRendering(fromTime: activeScene.lastFrameTime)
            activeScene.isPaused = false  // undo being paused by presentScene(nil)
            activeScene.size = exportSize
            resultMessage = resultIn
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
                let filename = toStop.outputURL.lastPathComponent
                self.framewiseWriter = nil
                self.framewiseRecorder = nil
                self.framewiseTimer = nil
                self.resultMessage?.wrappedValue = "Saved to \(filename)"
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
