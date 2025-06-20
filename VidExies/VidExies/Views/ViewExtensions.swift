////
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  ViewExtensions.swift - small portion copied from
// https://github.com/RevenueCat/purchases-ios/blob/main/RevenueCatUI/Modifiers/ViewExtensions.swift

import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension View {

    /// Wraps the 2 `onChange(of:)` implementations in iOS 17+ and below depending on what's available
    @inlinable
    @ViewBuilder
    func onChangeOf<V>(
        _ value: V,
        perform action: @escaping (_ newValue: V) -> Void
    ) -> some View where V: Equatable {
        #if swift(>=5.9)
        // wrapping with AnyView to type erase is needed because when archiving an xcframework,
        // the compiler gets confused between the types returned
        // by the different implementations of self.onChange(of:value).
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            AnyView(self.onChange(of: value) { _, newValue in action(newValue) })
        } else {
            AnyView(self.onChange(of: value) { newValue in action(newValue) })
        }
        #else
        self.onChange(of: value) { newValue in action(newValue) }
        #endif
    }

}
