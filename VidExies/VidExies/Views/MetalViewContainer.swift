//
//  MetalViewContainer.swift
//  VidExies
//
//  Created by Andy Dent on 7/7/2025.
//  Based on https://medium.com/@giikwebdeveloper/metal-view-for-swiftui-93f5f78ec36a

import MetalKit
import SwiftUI

// simple ref class to own a view made in here, so caller can pass around
// much like what happens inside Coordinator but exposed at higher level
class MetalViewOwner : ObservableObject, TextureMonitor {
    @Published var texture: MTLTexture?
    public let id = UUID()
    public var ownedView: MTKView? = nil
    
    func update(texture newTexture: MTLTexture) {
            self.texture = newTexture
    }
}

struct MetalViewContainer: AgnosticViewRepresentable {
    typealias RepresentedViewType = MTKView
    let playsOn: MetalViewOwner

    @Binding var texture: MTLTexture?


    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Creating the wrapped MTKView
    func makeView(context: Context) -> MTKView {
        var mtk: MTKView!
        if let keptView = playsOn.ownedView {
            mtk = keptView // don't recreate the MTKView
            mtk.device = context.coordinator.device  // unsure if reassigning this makes sense
        } else {
            mtk = MTKView(frame: .zero, device: context.coordinator.device)
            mtk.isPaused = false                          // we’ll trigger draws manually
            mtk.enableSetNeedsDisplay = false
            mtk.framebufferOnly = false                  // need to sample into it
            // match the view’s pixel format to our shaders
            mtk.colorPixelFormat = .bgra8Unorm
            playsOn.ownedView = mtk
            //print("MTKView created for MetalViewOwner id \(playsOn.id.uuidString)")
        }
        mtk.delegate = context.coordinator
        return mtk
    }
    
    // Called when the view needs to be updated, incl. because the value of the
    // Binding changed. It gives us a chance to call draw() which in turn will
    // call draw(in:) on the delegate.
    func updateView(_ view: MTKView, context: Context) {
        // feed the latest texture into the coordinator
        context.coordinator.previewTexture = texture
        // ask it to draw immediately
        view.draw()
    }
    
    static func dismantleView(_ view: MTKView, coordinator: Coordinator) {
        print("dismantleView invoked in MetalViewContainer")
    }

    
    class Coordinator: NSObject, MTKViewDelegate {
        let parent: MetalViewContainer
        let device: MTLDevice
        var previewTexture: MTLTexture?
        let pipelineState: MTLRenderPipelineState
        let commandQueue: MTLCommandQueue

        init(_ parent: MetalViewContainer) {
            self.parent = parent
            guard let device = MTLCreateSystemDefaultDevice() else {
                fatalError("Metal is not supported on this device")
            }
            self.device = device

            // load our passthrough shaders
            let library = device.makeDefaultLibrary()!
            let vFunc   = library.makeFunction(name: "vertex_passthrough")!
            let fFunc   = library.makeFunction(name: "fragment_passthrough")!
            
            // build a simple pipeline
            let desc = MTLRenderPipelineDescriptor()
            desc.vertexFunction   = vFunc
            desc.fragmentFunction = fFunc
            desc.colorAttachments[0].pixelFormat = .bgra8Unorm
            
            pipelineState = try! device.makeRenderPipelineState(descriptor: desc)
            commandQueue  = device.makeCommandQueue()!
            
            super.init()
        }

        // required but unused
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

        func draw(in view: MTKView) {
            guard let texture = previewTexture,
                  let drawable = view.currentDrawable,
                  let rpd      = view.currentRenderPassDescriptor
            else {
                return
            }

            // Issue a single render pass that draws a quad sampling your texture
            let cmd = commandQueue.makeCommandBuffer()!
            let enc = cmd.makeRenderCommandEncoder(descriptor: rpd)!
            enc.setRenderPipelineState(pipelineState)
            enc.setFragmentTexture(texture, index: 0)
            enc.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
            enc.endEncoding()
            
            cmd.present(drawable)
            cmd.commit()
        }
    }
}
