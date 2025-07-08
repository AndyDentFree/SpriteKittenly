//
//  MetalViewContainer.swift
//  VidExies
//
//  Created by Andrew Dent on 7/7/2025.
//  Based on https://medium.com/@giikwebdeveloper/metal-view-for-swiftui-93f5f78ec36a

import MetalKit
import SwiftUI

// simple ref class to own a view made in here, so caller can pass around
// much like what happens inside Coordinator but exposed at higher level
class MetalViewOwner {
    //typealias Resizer = (CGSize, CGSize) -> Void
    public let id = UUID()
    public var ownedView: MTKView? = nil
    //public var resizer: Resizer? = nil
}

// The coordinator class implements the MTKViewDelegate protocol and an instance of
// it is used as the delegate for the wrapped MTKView.
class MetalViewCoordinator: NSObject, MTKViewDelegate {
    let device: MTLDevice
    // The Metal Programming Guide recommends that non-transient objects
    // including command queues are reused, especially in performance-sensitive
    // code.
    let commandQueue: MTLCommandQueue
    
    override init() {
        guard let device = MTLCreateSystemDefaultDevice(),
              let queue = device.makeCommandQueue()
        else {
            fatalError("could not create device or command queue")
        }
        // Technically, we don't need to save the device in the coordinator. The
        // MTKView must have its device property set so this is an easy way to
        // ensure that the devices used by the coordinator and the view are
        // identical.
        self.device = device
        self.commandQueue = queue
        super.init()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    // Most importantly, the delegate implements the draw(in:) method which we don't call
    // directly. Rather, we request for it to be called by calling the draw() method of
    // the wrapped MTKView.
    func draw(in view: MTKView) {
        guard let buffer = self.commandQueue.makeCommandBuffer(),
              let descriptor = view.currentRenderPassDescriptor,
              let encoder = buffer.makeRenderCommandEncoder(descriptor: descriptor)
        else {
            fatalError("could not create buffer, render pass descriptor, or encoder")
        }
        encoder.endEncoding()
        if let drawable = view.currentDrawable {
            buffer.present(drawable)
            buffer.commit()
        }
    }
}

struct MetalViewContainer: AgnosticViewRepresentable {
    typealias RepresentedViewType = MTKView
    let playsOn: MetalViewOwner

    @Environment(\.self) var environment  // needed to resolve Color instances
    var color: Color = .clear  // allows us to inject a clear color
    
    func makeCoordinator() -> MetalViewCoordinator {
        MetalViewCoordinator()
    }
    
    // Creating the wrapped MTKView
    func makeView(context: Context) -> MTKView {
        var ret: MTKView!
        if let keptView = playsOn.ownedView {
            ret = keptView // don't recreate the MTKView
        } else {
            ret = MTKView()
            playsOn.ownedView = ret
            print("MTKView created for MetalViewOwner id \(playsOn.id.uuidString)")
        }
        ret.delegate = context.coordinator
        ret.device = context.coordinator.device
        return ret
    }
    
    // Called when the view needs to be updated, incl. because the value of the
    // Binding changed. It gives us a chance to call draw() which in turn will
    // call draw(in:) on the delegate.
    func updateView(_ view: MTKView, context: Context) {
        if #available(iOS 16.0, macOS 14.0, *) {
            let resolved = self.color.resolve(in: self.environment)
            view.clearColor = MTLClearColor(
                red: Double(resolved.red),
                green: Double(resolved.green),
                blue: Double(resolved.blue),
                alpha: Double(resolved.opacity)
            )
            view.draw()
        } else {
            view.clearColor = MTLClearColorMake(0, 0, 0, 1)
        }
    }
    
    static func dismantleView(_ view: MTKView, coordinator: MetalViewCoordinator) {
        print("dismantleView invoked in MetalViewContainer")
    }
    
}

@available(iOS 16.0, macOS 14.0, *)
#Preview {
    @Previewable @State var startDate = Date.now
    @Previewable @State var dummyOwner = MetalViewOwner()
    VStack {
        TimelineView(.periodic(from: startDate, by: 1 / 60)) { ctx in
            let elapsed = ctx.date.timeIntervalSince(startDate)
            let rads = Angle(degrees: elapsed * 72).radians
            let tanRads = Angle(radians: rads.truncatingRemainder(dividingBy: .pi / 4)).radians
            return MetalViewContainer(playsOn: dummyOwner, color: Color(red: tan(tanRads), green: sin(rads), blue: cos(rads))
            )
        }
        Text("Just to show metal can sit above some standard SwiftUI content")
            .font(.caption)
        Spacer()
    }
}


