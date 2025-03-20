//
//  PreviewContainer.swift
//  VidExies
//
//  Created by Andy Dent on 19/3/2025.
//

import SwiftUI
import ReplayKit

// Container for a RPPreviewViewController to present on iOS or Mac
struct PreviewContainer : AgnosticViewControllerRepresentable {
    typealias RepresentedViewControllerType = RPPreviewViewController
    let previewViewController: RPPreviewViewController
    @Binding var isShowingPreview: Bool

    // memoizes state to be passed back in via updateViewController context
    class Coordinator: NSObject, RPPreviewViewControllerDelegate {
        var parentContainer: PreviewContainer
           
        init(_ parent: PreviewContainer) {
            self.parentContainer = parent
        }
           
        func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
            parentContainer.finishedPreview()
        }

    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeViewController(context: Context) -> RepresentedViewControllerType {
        previewViewController.previewControllerDelegate = context.coordinator
        #if os(iOS)
        previewViewController.modalPresentationStyle = .fullScreen
        // make it fit because controls vanishing off bottom
        #endif
        return previewViewController
    }

    func updateViewController(_ viewController: RepresentedViewControllerType, context: Context) {
        // nothing to do
    }
    
    func finishedPreview() {
        previewViewController.previewControllerDelegate = nil
        withAnimation {
            isShowingPreview = false  // pass back to dismiss sheet
        }
    }

}
