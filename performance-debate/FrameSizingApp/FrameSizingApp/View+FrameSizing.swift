//
//  View+FrameSizing.swift
//  FrameSizingApp
//
//  Approach C: extension View — adds `.squareFrame(_:alignment:)` and
//  `.frame(sizing:alignment:)` directly on View.
//
//  Trade-offs vs ViewModifier:
//  • ✅ Concise call site: `.squareFrame(.s48)` / `.frame(sizing: .s48)`
//  • ✅ Compiler inlines the call (zero dispatch overhead).
//  • ✅ Returns the same stable `ModifiedContent<Self, _FrameLayout>` type
//     that the built-in `.frame()` returns, so SwiftUI diffing cost is
//     identical to calling `.frame()` directly.
//  • ⚠️ Cannot conform to `Equatable` — value identity always comes from
//     the wrapped modifier type, which SwiftUI already handles correctly for
//     _FrameLayout.
//  • ⚠️ Every call site produces a different concrete `some View` type
//     (Self-typed), so views cannot be stored in a homogeneous array without
//     type-erasure.
//

import SwiftUI

public extension View {

    /// Applies a **square** frame using a `Sizing` token.
    ///
    /// ```swift
    /// Color.blue.squareFrame(.s48)
    /// Color.blue.squareFrame(.s48, alignment: .leading)
    /// ```
    @inlinable
    func squareFrame(_ size: Sizing, alignment: Alignment = .center) -> some View {
        frame(width: size.rawValue, height: size.rawValue, alignment: alignment)
    }

    /// Overload of `.frame` that accepts a `Sizing` token for both axes.
    ///
    /// ```swift
    /// Color.blue.frame(sizing: .s48)
    /// ```
    @inlinable
    func frame(sizing: Sizing, alignment: Alignment = .center) -> some View {
        frame(width: sizing.rawValue, height: sizing.rawValue, alignment: alignment)
    }
}
