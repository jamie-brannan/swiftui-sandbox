import SwiftUI

/// A layout that arranges subviews horizontally and wraps them onto the next
/// row when they no longer fit within the available width — similar to how
/// inline text wraps.
///
/// Usage:
/// ```swift
/// FlowLayout(horizontalSpacing: 8, verticalSpacing: 8) {
///     ForEach(tags, id: \.self) { tag in
///         TagView(tag)
///     }
/// }
/// ```
public struct FlowLayout: Layout {

    /// Horizontal spacing between adjacent items on the same row.
    public var horizontalSpacing: CGFloat

    /// Vertical spacing between rows.
    public var verticalSpacing: CGFloat

    /// Row alignment when a row does not fill the full available width.
    public var alignment: HorizontalAlignment

    public init(
        horizontalSpacing: CGFloat = 8,
        verticalSpacing: CGFloat = 8,
        alignment: HorizontalAlignment = .leading
    ) {
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.alignment = alignment
    }

    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) -> CGSize {
        let rows = makeRows(proposal: proposal, subviews: subviews)
        return totalSize(rows: rows, proposal: proposal)
    }

    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) {
        let rows = makeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY

        for row in rows {
            let rowHeight = row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            let rowWidth = row.reduce(0) { $0 + $1.sizeThatFits(.unspecified).width }
                + CGFloat(max(row.count - 1, 0)) * horizontalSpacing

            let startX: CGFloat
            switch alignment {
            case .center:
                startX = bounds.minX + (bounds.width - rowWidth) / 2
            case .trailing:
                startX = bounds.maxX - rowWidth
            default:
                startX = bounds.minX
            }

            var x = startX
            for subview in row {
                let size = subview.sizeThatFits(.unspecified)
                subview.place(
                    at: CGPoint(x: x, y: y + (rowHeight - size.height) / 2),
                    anchor: .topLeading,
                    proposal: .unspecified
                )
                x += size.width + horizontalSpacing
            }
            y += rowHeight + verticalSpacing
        }
    }

    // MARK: - Private helpers

    private func makeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[LayoutSubview]] {
        var rows: [[LayoutSubview]] = []
        var currentRow: [LayoutSubview] = []
        var currentWidth: CGFloat = 0
        let maxWidth = proposal.width ?? .infinity

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentRow.isEmpty {
                currentRow.append(subview)
                currentWidth = size.width
            } else if currentWidth + horizontalSpacing + size.width <= maxWidth {
                currentRow.append(subview)
                currentWidth += horizontalSpacing + size.width
            } else {
                rows.append(currentRow)
                currentRow = [subview]
                currentWidth = size.width
            }
        }

        if !currentRow.isEmpty {
            rows.append(currentRow)
        }
        return rows
    }

    private func totalSize(rows: [[LayoutSubview]], proposal: ProposedViewSize) -> CGSize {
        var totalHeight: CGFloat = 0
        var maxWidth: CGFloat = 0

        for (index, row) in rows.enumerated() {
            let rowHeight = row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            let rowWidth = row.reduce(0) { $0 + $1.sizeThatFits(.unspecified).width }
                + CGFloat(max(row.count - 1, 0)) * horizontalSpacing
            totalHeight += rowHeight
            if index < rows.count - 1 {
                totalHeight += verticalSpacing
            }
            maxWidth = max(maxWidth, rowWidth)
        }

        return CGSize(width: proposal.width ?? maxWidth, height: totalHeight)
    }
}
