//
//  FrameCaptureRecorder.swift
//  VidExies
//
//  Created by Andrew Dent on 5/4/2025.
//

import SpriteKit
import Metal
import AVFoundation
import CoreVideo

class FrameCaptureRecorder {
    // Metal and SpriteKit properties.
    let device: MTLDevice = MTLCreateSystemDefaultDevice()!
    let commandQueue: MTLCommandQueue
    let renderer: SKRenderer
    var textureCache: CVMetalTextureCache?
    
    // AVAssetWriter pixel buffer adaptor.
    let pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor
    
    // The scene you want to record.
    let scene: SKScene
    
    init(scene: SKScene, pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor) {
        self.scene = scene
        self.pixelBufferAdaptor = pixelBufferAdaptor
        commandQueue = device.makeCommandQueue()!
        renderer = SKRenderer(device: device)
        renderer.scene = scene
        
        // Create a Metal texture cache for converting CVPixelBuffer to Metal textures.
        CVMetalTextureCacheCreate(nil, nil, device, nil, &textureCache)
    }
    
    func captureFrame(at time: CMTime) {
        // 1. Create a CVPixelBuffer for the frame.
        var pixelBuffer: CVPixelBuffer?
        // Use the scene's size (or your specific recording area) in pixels.
        let width = Int(scene.size.width)
        let height = Int(scene.size.height)
        let attributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey as String: width,
            kCVPixelBufferHeightKey as String: height,
            kCVPixelBufferMetalCompatibilityKey as String: true
        ]
        
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, attributes as CFDictionary, &pixelBuffer)
        guard status == kCVReturnSuccess, let buffer = pixelBuffer, let textureCache = textureCache else {
            print("Failed to create pixel buffer")
            return
        }
        
        // 2. Create a Metal texture from the CVPixelBuffer.
        var cvTextureOut: CVMetalTexture?
        CVMetalTextureCacheCreateTextureFromImage(nil,
                                                  textureCache,
                                                  buffer,
                                                  nil,
                                                  .bgra8Unorm,
                                                  width,
                                                  height,
                                                  0,
                                                  &cvTextureOut)
        guard let cvTexture = cvTextureOut, let texture = CVMetalTextureGetTexture(cvTexture) else {
            print("Failed to create Metal texture from pixel buffer")
            return
        }
        
        // 3. Set up a command buffer and render pass descriptor.
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        // Clear to a default color.
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1)
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        // Define the viewport to match the texture dimensions.
        let viewport = CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
        
        // 4. Render the SKScene into the Metal texture.
        renderer.render(withViewport: viewport, commandBuffer: commandBuffer, renderPassDescriptor: renderPassDescriptor)
        
        // Commit the command buffer and wait until rendering is complete.
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        // 5. Append the rendered pixel buffer to AVAssetWriter.
        if pixelBufferAdaptor.assetWriterInput.isReadyForMoreMediaData {
            pixelBufferAdaptor.append(buffer, withPresentationTime: time)
        }
    }
}
