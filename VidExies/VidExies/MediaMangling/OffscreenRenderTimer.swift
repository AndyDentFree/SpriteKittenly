//
//  OffscreenRenderTimer.swift
//  VidExies
//
//  Created by Andrew Dent on 10/6/2025.
//

import Foundation
import AVFoundation

// Assume frameCaptureRecorder is an instance of your FrameCaptureRecorder
// and has been properly configured with an SKScene and pixel buffer adaptor.

class OffscreenRenderTimer {
    private let frameRate: Double = 30.0 // desired FPS
    private let frameDuration: Double
    private var frameIndex: Int = 0
    private var timer: DispatchSourceTimer?
    private let recorder: FrameCaptureRecorder

    init(recorder: FrameCaptureRecorder) {
        self.recorder = recorder
        frameDuration = 1.0 / frameRate
    }
    
    func startRendering() {
        // Create a timer that fires at our desired frame rate.
        timer = DispatchSource.makeTimerSource(queue: DispatchQueue(label: "FrameCaptureTimer"))
        timer?.schedule(deadline: .now(), repeating: frameDuration)
        timer?.setEventHandler { [weak self] in
            guard let self = self else { return }
            
            // Calculate the presentation time for the current frame.
            let seconds = Double(self.frameIndex) * self.frameDuration
            let presentationTime = CMTime(seconds: seconds, preferredTimescale: 600)
            
            // Manually drive the scene update.
            self.recorder.renderer.update(atTime: seconds)
            
            // Capture and append the frame.
            self.recorder.captureFrame(at: presentationTime)
            
            self.frameIndex += 1
        }
        timer?.resume()
    }
    
    func stopRendering(completion: @escaping () -> Void) {
        guard let activeTimer = timer else {return}
        activeTimer.setCancelHandler(handler: completion)  // ensure completion block not called until stopped
        activeTimer.cancel()
        timer = nil
    }
}
