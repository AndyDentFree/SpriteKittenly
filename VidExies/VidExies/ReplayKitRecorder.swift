import ReplayKit
import AVFoundation
import UIKit

class ReplayKitRecorder: NSObject {
    private var assetWriter: AVAssetWriter?
    private var videoInput: AVAssetWriterInput?
    private var audioInput: AVAssetWriterInput?
    private var sessionAtSourceTime: CMTime?

    /// Starts recording to the given file URL.
    func startRecording(to fileURL: URL) {
        // Create an AVAssetWriter for an MP4 file.
        do {
            assetWriter = try AVAssetWriter(outputURL: fileURL, fileType: .mp4)
        } catch {
            print("Error creating asset writer: \(error)")
            return
        }
        
        // Set up video input based on the screen size.
        let screenSize = UIScreen.main.bounds.size
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: screenSize.width,
            AVVideoHeightKey: screenSize.height
        ]
        videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        videoInput?.expectsMediaDataInRealTime = true
        if let videoInput = videoInput, assetWriter!.canAdd(videoInput) {
            assetWriter!.add(videoInput)
        }
        
        // Optionally, set up audio input.
        let audioSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey: 44100,
            AVEncoderBitRateKey: 192000
        ]
        audioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
        audioInput?.expectsMediaDataInRealTime = true
        if let audioInput = audioInput, assetWriter!.canAdd(audioInput) {
            assetWriter!.add(audioInput)
        }
        
        assetWriter?.startWriting()
        
        // Enable the microphone if needed.
        RPScreenRecorder.shared().isMicrophoneEnabled = true
        
        // Start capturing sample buffers.
        RPScreenRecorder.shared().startCapture(handler: { [weak self] (sampleBuffer, sampleBufferType, error) in
            guard let self = self else { return }
            if let error = error {
                print("Capture error: \(error)")
                return
            }
            
            // Begin the session on receipt of the first buffer.
            if self.sessionAtSourceTime == nil {
                let time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                self.sessionAtSourceTime = time
                self.assetWriter?.startSession(atSourceTime: time)
            }
            
            switch sampleBufferType {
            case .video:
                if self.videoInput?.isReadyForMoreMediaData == true {
                    self.videoInput?.append(sampleBuffer)
                }
            case .audioMic:
                if self.audioInput?.isReadyForMoreMediaData == true {
                    self.audioInput?.append(sampleBuffer)
                }
            default:
                break
            }
        }, completionHandler: { error in
            if let error = error {
                print("Start capture error: \(error)")
            }
        })
    }
    
    /// Stops recording and finalizes the video file.
    func stopRecording(completion: @escaping () -> Void) {
        RPScreenRecorder.shared().stopCapture { [weak self] error in
            guard let self = self else { return }
            self.videoInput?.markAsFinished()
            self.audioInput?.markAsFinished()
            self.assetWriter?.finishWriting {
                completion()
            }
        }
    }
}
