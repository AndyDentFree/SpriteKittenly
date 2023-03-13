//
//  AgnosticViewRepresentable.swift

/*
 from https://forums.swift.org/t/infer-associated-type-on-protocol-conformance/61166/3
 with added dismantle*
 
 See similar on
 https://gist.github.com/insidegui/97d821ca933c8627e7f614bc1d6b4983
 https://gist.github.com/MojtabaHs/569b4b467aa7a4cea2afcb6736314b23
 and discussion https://stackoverflow.com/questions/58164606/undeclared-type-uiviewrepresentable-in-macos-project
 */

import SwiftUI

#if os(iOS) || os(watchOS) || os(tvOS)
import UIKit

public protocol AgnosticViewRepresentable: UIViewRepresentable where UIViewType == RepresentedViewType {
    associatedtype RepresentedViewType
    associatedtype UIViewType = RepresentedViewType
    
    @MainActor
    func makeView(context: Context) -> RepresentedViewType
    
    @MainActor
    func updateView(_ view: RepresentedViewType, context: Context)
    
    @MainActor
    static func dismantleView(view: RepresentedViewType, coordinator: Self.Coordinator)
}

extension AgnosticViewRepresentable {
    @MainActor
    public func makeUIView(context: Context) -> UIViewType {
        makeView(context: context)
    }
    
    @MainActor
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        updateView(uiView, context: context)
    }
    
    @MainActor
    static func dismantleView(view: RepresentedViewType, coordinator: Self.Coordinator) {
        dismantleUIView(view, coordinator: coordinator)
    }
}
#elseif os(macOS)
import AppKit

public protocol AgnosticViewRepresentable: NSViewRepresentable where NSViewType == RepresentedViewType {
    associatedtype RepresentedViewType
    associatedtype NSViewType = RepresentedViewType
    
    @MainActor
    func makeView(context: Context) -> RepresentedViewType
    
    @MainActor
    func updateView(_ view: RepresentedViewType, context: Context)
}

extension AgnosticViewRepresentable {

    @MainActor
    public func makeNSView(context: Context) -> NSViewType {
        makeView(context: context)
    }
    
    @MainActor
    public func updateNSView(_ nsView: NSViewType, context: Context) {
        updateView(nsView, context: context)
    }
    
    @MainActor
    static func dismantleView(view: RepresentedViewType, coordinator: Self.Coordinator) {
        dismantleNSView(view, coordinator: coordinator)
    }
}
#endif
