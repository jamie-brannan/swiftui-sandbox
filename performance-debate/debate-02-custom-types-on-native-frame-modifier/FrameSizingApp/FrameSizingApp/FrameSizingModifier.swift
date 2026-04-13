//
//  FrameSizingModifier.swift
//  FrameSizingApp
//
//  Approach D: ViewModifier — an explicit struct that applies a square frame.
//
//  Trade-offs vs extension View:
//  • ✅ Named, reusable, composable modifier — easy to store & pass around.
//  • ✅ Conforms to `Equatable` automatically (all stored properties are
//     Equatable), which lets SwiftUI skip applying the modifier when the
//     value hasn't changed.
//  • ✅ Can add `@Environment` / `@State` if you need adaptive sizing.
//  • ⚠️ Slightly more verbose call site:
//       `.modifier(SquareFrameModifier(.s48))`
//       (mitigated by wrapping in an extension View—see below).
//  • ⚠️ Introduces an extra type layer in the view tree
//     (`ModifiedContent<Content, SquareFrameModifier>` instead of the thinner
//     `ModifiedContent<Content, _FrameLayout>`) — SwiftUI still short-circuits
//     body evaluation when the modifier is `Equatable` and unchanged.
//

import SwiftUI

// MARK: - ViewModifier

/// A `ViewModifier` that constrains a view to a square frame using a `Sizing` token.
public struct SquareFrameModifier: ViewModifier, Equatable {
    public let size: Sizing
    public var alignment: Alignment

    public init(_ size: Sizing, alignment: Alignment = .center) {
        self.size = size
        self.alignment = alignment
    }

    public func body(content: Content) -> some View {
        content.frame(
            width: size.rawValue,
            height: size.rawValue,
            alignment: alignment
        )
    }

    // Equatable conformance: SwiftUI uses this to bail out of re-rendering
    // when neither `size` nor `alignment` has changed.
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.size == rhs.size && lhs.alignment == rhs.alignment
    }
}

// MARK: - Convenience extension wrapping the modifier

public extension View {
    /// Applies `SquareFrameModifier` — the `ViewModifier`-based approach.
    ///
    /// ```swift
    /// Color.blue.squareFrameViaModifier(.s48)
    /// ```
    @inlinable
    func squareFrameViaModifier(_ size: Sizing,
                                alignment: Alignment = .center) -> some View {
        modifier(SquareFrameModifier(size, alignment: alignment))
    }
}
