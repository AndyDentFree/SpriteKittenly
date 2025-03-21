//
//  AgnosticViewControllerRepresentable.swift
//  VidExies
//
//  Created by Andy Dent on 19/3/2025.
//  see also AgnosticViewRepresentable.swift

import SwiftUI

#if os(iOS) || os(watchOS) || os(tvOS)
import UIKit

public protocol AgnosticViewControllerRepresentable: UIViewControllerRepresentable where UIViewControllerType == RepresentedViewControllerType {
    associatedtype RepresentedViewControllerType
    associatedtype UIViewControllerType = RepresentedViewControllerType
    
    @MainActor
    func makeViewController(context: Context) -> RepresentedViewControllerType
    
    @MainActor
    func updateViewController(_ viewController: RepresentedViewControllerType, context: Context)
}

extension AgnosticViewControllerRepresentable {
    @MainActor
    public func makeUIViewController(context: Context) -> UIViewControllerType {
        makeViewController(context: context)
    }
    
    @MainActor
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        updateViewController(uiViewController, context: context)
    }
}

#elseif os(macOS)
import AppKit


public protocol AgnosticViewControllerRepresentable: NSViewControllerRepresentable where NSViewControllerType == RepresentedViewControllerType {
    associatedtype RepresentedViewControllerType
    associatedtype NSViewControllerType = RepresentedViewControllerType
    
    @MainActor
    func makeViewController(context: Context) -> RepresentedViewControllerType
    
    @MainActor
    func updateViewController(_ viewController: RepresentedViewControllerType, context: Context)
}

extension AgnosticViewControllerRepresentable {
    @MainActor
    public func makeNSViewController(context: Context) -> NSViewControllerType {
        makeViewController(context: context)
    }
    
    @MainActor
    public func updateNSViewController(_ uiViewController: NSViewControllerType, context: Context) {
        updateViewController(uiViewController, context: context)
    }
}


#endif
