//
//  OffscreenRenderTimer.swift
//  VidExies
//
//  Created by Andy Dent on 10/6/2025.
//

import Foundation
import AVFoundation

typealias TimeLogger = (CMTime)->Void

class OffscreenRenderTimer {
    private let frameDuration: Double
    private var frameIndex: Int = 0
    private var timer: DispatchSourceTimer?
    private let recorder: FrameCaptureRecorder
    private let timeLogger: TimeLogger?
    private let baseScale = CMTimeScale(600)  // usual base multiple of 6, 10, 12, 15, 24, 30, 60, 120
    private var logEveryFrames: Int
    private var lastLogFrameIndex: Int = 0

    init(recorder: FrameCaptureRecorder, frameRate: Double, timeLogger: TimeLogger? = nil, logEverySeconds: Double = 1/15.0) {
        self.recorder = recorder
        self.timeLogger = timeLogger
        frameDuration = 1.0 / frameRate
        logEveryFrames = Int(round(frameRate * logEverySeconds))
    }
    
    func startRendering(fromTime: TimeInterval) {
        // Create a timer that fires at our desired frame rate.
        timer = DispatchSource.makeTimerSource(queue: DispatchQueue(label: "FrameCaptureTimer"))
        timer?.schedule(deadline: .now(), repeating: frameDuration)
        let isLogging = timeLogger != nil // flag may have other reasons to prevent
        let baseTime = CACurrentMediaTime()
        timer?.setEventHandler { [weak self] in
            guard let self = self else { return }
            let now = CACurrentMediaTime()
            // Calculate the presentation time for the current frame.
            // naive approach: let elapsed = Double(self.frameIndex) * self.frameDuration
            let elapsed = now - baseTime  // keep recalculating based on actual timer invoke rather than assumed accuracy
            let rendererTime = fromTime + elapsed  // offset matches our paused SKScene
            let movieTime = CMTime(seconds: elapsed, preferredTimescale: baseScale)  // movie started from 0
            
            // Manually drive the scene update.
            self.recorder.renderer.update(atTime: rendererTime)
            
            // Capture and append the frame.
            self.recorder.captureFrame(at: movieTime)
            
            if isLogging {
                if frameIndex > (lastLogFrameIndex + logEveryFrames) {
                    timeLogger!(movieTime)
                    lastLogFrameIndex = frameIndex
                }
            }
            
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
