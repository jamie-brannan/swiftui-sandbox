import SwiftUI

/// A layout that positions subviews evenly along a circular arc.
///
/// Views are distributed starting from `startAngle` and spanning the full
/// `totalAngle` sweep. A `totalAngle` of 360° produces a complete ring; smaller
/// values create arcs or fans.
///
/// Usage:
/// ```swift
/// RadialLayout(radius: 120) {
///     ForEach(0..<8) { _ in
///         Circle().frame(width: 24, height: 24).foregroundColor(.blue)
///     }
/// }
/// .frame(width: 280, height: 280)
/// ```
public struct RadialLayout: Layout {

    /// Distance from the centre of the layout to the centre of each subview.
    public var radius: CGFloat

    /// The angle at which the first subview is placed.
    /// Defaults to the 12 o'clock position (`-90°`).
    public var startAngle: Angle

    /// The total arc swept by all subviews. Use `.degrees(360)` for a full ring.
    public var totalAngle: Angle

    public init(
        radius: CGFloat = 100,
        startAngle: Angle = .degrees(-90),
        totalAngle: Angle = .degrees(360)
    ) {
        self.radius = radius
        self.startAngle = startAngle
        self.totalAngle = totalAngle
    }

    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) -> CGSize {
        let side = radius * 2
        return CGSize(width: side, height: side)
    }

    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) {
        guard !subviews.isEmpty else { return }

        let center = CGPoint(x: bounds.midX, y: bounds.midY)

        // When there is only one view, place it at startAngle. When there are
        // multiple views and totalAngle is 360°, avoid duplicating the last
        // position by using count steps instead of count−1.
        let isFull = abs(totalAngle.degrees).truncatingRemainder(dividingBy: 360) < 0.001
        let stepCount = (subviews.count > 1 && isFull) ? subviews.count : max(subviews.count - 1, 1)
        let angleStep = subviews.count > 1 ? totalAngle.radians / Double(stepCount) : 0

        for (index, subview) in subviews.enumerated() {
            let angle = startAngle.radians + angleStep * Double(index)
            let x = center.x + CGFloat(cos(angle)) * radius
            let y = center.y + CGFloat(sin(angle)) * radius
            subview.place(at: CGPoint(x: x, y: y), anchor: .center, proposal: .unspecified)
        }
    }
}
