//
//  FrameCaptureRecorder.swift
//  VidExies
//
//  Created by Andrew Dent on 10/6/2025.
//

import SpriteKit
import Metal
import AVFoundation
import CoreVideo

class FrameCaptureRecorder {
    let renderSize: CGSize
    // Metal and SpriteKit properties.
    let device: MTLDevice = MTLCreateSystemDefaultDevice()!
    let commandQueue: MTLCommandQueue
    let renderer: SKRenderer
    var textureCache: CVMetalTextureCache!
    
    // AVAssetWriter pixel buffer adaptor.
    let pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor
    
    // The scene you want to record.
    let scene: SKScene
    
    init(scene: SKScene, pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor, size: CGSize) {
        self.renderSize = size
        self.scene = scene
        self.pixelBufferAdaptor = pixelBufferAdaptor
        commandQueue = device.makeCommandQueue()!
        renderer = SKRenderer(device: device)
        renderer.scene = scene  // do we need to do anything else, is this eqivalent to SKView.presentScene?
        
        // Create a Metal texture cache for converting CVPixelBuffer to Metal textures.
        CVMetalTextureCacheCreate(nil, nil, device, nil, &textureCache)
    }
    
    func captureFrame(at time: CMTime) {
        guard scene.size.width > 0.0 && scene.size.height > 0.0 else {
            return // skip some weird transitory state getting at least one capture with zero size frame
        }
        let width = Int(renderSize.width)
        let height = Int(renderSize.height)

        // 1. Get a CVPixelBuffer for the frame, from the adaptor's pool
        guard let pool = pixelBufferAdaptor.pixelBufferPool else {
          fatalError("No pixelBufferPool on adaptor")
        }
        var bufferOut: CVPixelBuffer?
        CVPixelBufferPoolCreatePixelBuffer(nil, pool, &bufferOut)
        guard let buffer = bufferOut else {
          fatalError("Couldn’t get a buffer from the pool")
        }

        
        // 2. Create a Metal texture from the CVPixelBuffer.
        var cvTextureOut: CVMetalTexture?
        let metalStatus = CVMetalTextureCacheCreateTextureFromImage(nil,
                                                  textureCache,
                                                  buffer,
                                                  nil,
                                                  .bgra8Unorm,
                                                  width,
                                                  height,
                                                  0,
                                                  &cvTextureOut)
        guard let cvTexture = cvTextureOut,
              let texture = CVMetalTextureGetTexture(cvTexture),
              metalStatus == kCVReturnSuccess else {
            print("Failed to create Metal texture from pixel buffer, status \(metalStatus)")
            return
        }

        // 3. Set up a command buffer and render pass descriptor.
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            print("Failed to create Metal command buffer")
            return
        }
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        // Clear to a default color.
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1)
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        // Define the viewport to match the texture dimensions.
        let viewport = CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
        
        // logging put in to find that the SKScene is being resized to half, before captureFrame
        //print("▶️ Metal texture: \(texture.width)x\(texture.height)")
        //print("▶️ SKScene size:  \(scene.size.width)x\(scene.size.height)")
        //print("▶️ viewport:      \(viewport.width)x\(viewport.height)")

        // 4. Render the SKScene into the Metal texture.
        renderer.render(withViewport: viewport, commandBuffer: commandBuffer, renderPassDescriptor: renderPassDescriptor)
        
        // Commit the command buffer and wait until rendering is complete.
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        // 5. Append the rendered pixel buffer to AVAssetWriter.
        if pixelBufferAdaptor.assetWriterInput.isReadyForMoreMediaData {
            pixelBufferAdaptor.append(buffer, withPresentationTime: time)
        } else {
            print("Unable to append to pixel buffer at time \(time)")
        }
    }
    
    func markAsFinished() {
        pixelBufferAdaptor.assetWriterInput.markAsFinished()
    }
}
