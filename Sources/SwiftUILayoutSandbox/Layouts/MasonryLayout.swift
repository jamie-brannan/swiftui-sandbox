import SwiftUI

/// A layout that arranges subviews into a fixed number of columns, always
/// placing the next item in the shortest column — producing the staggered
/// "masonry" grid popularised by Pinterest.
///
/// Unlike a regular grid, each column grows independently so items of varying
/// heights pack together without wasted vertical space.
///
/// Usage:
/// ```swift
/// MasonryLayout(columns: 2, spacing: 12) {
///     ForEach(items) { item in
///         ItemCard(item)
///     }
/// }
/// ```
public struct MasonryLayout: Layout {

    /// Number of columns. Clamped to a minimum of 1.
    public var columns: Int

    /// Spacing applied both horizontally between columns and vertically between
    /// items within the same column.
    public var spacing: CGFloat

    public init(columns: Int = 2, spacing: CGFloat = 8) {
        self.columns = max(1, columns)
        self.spacing = spacing
    }

    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) -> CGSize {
        let colWidth = columnWidth(in: proposal)
        let heights = columnHeights(subviews: subviews, columnWidth: colWidth)
        let maxHeight = heights.max() ?? 0
        return CGSize(width: proposal.width ?? 0, height: maxHeight)
    }

    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) {
        let colWidth = columnWidth(in: ProposedViewSize(bounds.size))
        var tops = [CGFloat](repeating: bounds.minY, count: columns)

        for subview in subviews {
            let (col, minTop) = shortestColumn(in: tops)
            let x = bounds.minX + CGFloat(col) * (colWidth + spacing)
            let itemProposal = ProposedViewSize(width: colWidth, height: nil)
            let size = subview.sizeThatFits(itemProposal)
            subview.place(at: CGPoint(x: x, y: minTop), anchor: .topLeading, proposal: itemProposal)
            tops[col] = minTop + size.height + spacing
        }
    }

    // MARK: - Private helpers

    private func columnWidth(in proposal: ProposedViewSize) -> CGFloat {
        let total = proposal.width ?? 0
        let gaps = CGFloat(columns - 1) * spacing
        return (total - gaps) / CGFloat(columns)
    }

    private func columnHeights(subviews: Subviews, columnWidth: CGFloat) -> [CGFloat] {
        var heights = [CGFloat](repeating: 0, count: columns)
        for subview in subviews {
            let (col, _) = shortestColumn(in: heights)
            let size = subview.sizeThatFits(ProposedViewSize(width: columnWidth, height: nil))
            heights[col] += size.height + spacing
        }
        return heights
    }

    private func shortestColumn(in heights: [CGFloat]) -> (index: Int, value: CGFloat) {
        guard let pair = heights.enumerated().min(by: { $0.element < $1.element }) else {
            return (0, 0)
        }
        return (pair.offset, pair.element)
    }
}
