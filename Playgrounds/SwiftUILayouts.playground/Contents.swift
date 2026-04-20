import SwiftUI
import PlaygroundSupport

// =============================================================================
// SwiftUI Layout Sandbox — Playground
//
// This playground demonstrates three custom layouts built with the SwiftUI
// `Layout` protocol (requires iOS 16 / macOS 13).
//
// Change the `DemoView` assignment at the bottom to switch between examples.
// =============================================================================

// MARK: - FlowLayout

/// Wraps subviews horizontally onto new rows when they overflow the width.
struct FlowLayout: Layout {
    var horizontalSpacing: CGFloat = 8
    var verticalSpacing: CGFloat = 8
    var alignment: HorizontalAlignment = .leading

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let rows = makeRows(proposal: proposal, subviews: subviews)
        return totalSize(rows: rows, proposal: proposal)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let rows = makeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            let rowHeight = row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            let rowWidth = row.reduce(0) { $0 + $1.sizeThatFits(.unspecified).width }
                + CGFloat(max(row.count - 1, 0)) * horizontalSpacing
            let startX: CGFloat
            switch alignment {
            case .center:  startX = bounds.minX + (bounds.width - rowWidth) / 2
            case .trailing: startX = bounds.maxX - rowWidth
            default:        startX = bounds.minX
            }
            var x = startX
            for subview in row {
                let size = subview.sizeThatFits(.unspecified)
                subview.place(at: CGPoint(x: x, y: y + (rowHeight - size.height) / 2),
                              anchor: .topLeading, proposal: .unspecified)
                x += size.width + horizontalSpacing
            }
            y += rowHeight + verticalSpacing
        }
    }

    private func makeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[LayoutSubview]] {
        var rows: [[LayoutSubview]] = []
        var currentRow: [LayoutSubview] = []
        var currentWidth: CGFloat = 0
        let maxWidth = proposal.width ?? .infinity
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentRow.isEmpty {
                currentRow.append(subview); currentWidth = size.width
            } else if currentWidth + horizontalSpacing + size.width <= maxWidth {
                currentRow.append(subview); currentWidth += horizontalSpacing + size.width
            } else {
                rows.append(currentRow); currentRow = [subview]; currentWidth = size.width
            }
        }
        if !currentRow.isEmpty { rows.append(currentRow) }
        return rows
    }

    private func totalSize(rows: [[LayoutSubview]], proposal: ProposedViewSize) -> CGSize {
        var totalHeight: CGFloat = 0; var maxWidth: CGFloat = 0
        for (i, row) in rows.enumerated() {
            let rowH = row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            let rowW = row.reduce(0) { $0 + $1.sizeThatFits(.unspecified).width }
                + CGFloat(max(row.count - 1, 0)) * horizontalSpacing
            totalHeight += rowH; if i < rows.count - 1 { totalHeight += verticalSpacing }
            maxWidth = max(maxWidth, rowW)
        }
        return CGSize(width: proposal.width ?? maxWidth, height: totalHeight)
    }
}

// MARK: - RadialLayout

/// Positions subviews evenly around a circular arc.
struct RadialLayout: Layout {
    var radius: CGFloat = 100
    var startAngle: Angle = .degrees(-90)
    var totalAngle: Angle = .degrees(360)

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        CGSize(width: radius * 2, height: radius * 2)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        guard !subviews.isEmpty else { return }
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let isFull = abs(totalAngle.degrees).truncatingRemainder(dividingBy: 360) < 0.001
        let stepCount = (subviews.count > 1 && isFull) ? subviews.count : max(subviews.count - 1, 1)
        let step = subviews.count > 1 ? totalAngle.radians / Double(stepCount) : 0
        for (i, subview) in subviews.enumerated() {
            let angle = startAngle.radians + step * Double(i)
            subview.place(
                at: CGPoint(x: center.x + CGFloat(cos(angle)) * radius,
                            y: center.y + CGFloat(sin(angle)) * radius),
                anchor: .center, proposal: .unspecified)
        }
    }
}

// MARK: - MasonryLayout

/// Staggered grid that places each item in the shortest column.
struct MasonryLayout: Layout {
    var columns: Int = 2
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let cw = colWidth(proposal)
        return CGSize(width: proposal.width ?? 0, height: heights(subviews, cw).max() ?? 0)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let cw = colWidth(ProposedViewSize(bounds.size))
        var tops = [CGFloat](repeating: bounds.minY, count: columns)
        for subview in subviews {
            let (col, top) = shortest(tops)
            let x = bounds.minX + CGFloat(col) * (cw + spacing)
            let p = ProposedViewSize(width: cw, height: nil)
            subview.place(at: CGPoint(x: x, y: top), anchor: .topLeading, proposal: p)
            tops[col] = top + subview.sizeThatFits(p).height + spacing
        }
    }

    private func colWidth(_ p: ProposedViewSize) -> CGFloat {
        ((p.width ?? 0) - CGFloat(columns - 1) * spacing) / CGFloat(columns)
    }
    private func heights(_ subviews: Subviews, _ cw: CGFloat) -> [CGFloat] {
        var h = [CGFloat](repeating: 0, count: columns)
        for s in subviews {
            let (col, _) = shortest(h)
            h[col] += s.sizeThatFits(ProposedViewSize(width: cw, height: nil)).height + spacing
        }
        return h
    }
    private func shortest(_ h: [CGFloat]) -> (Int, CGFloat) {
        guard let pair = h.enumerated().min(by: { $0.element < $1.element }) else { return (0, 0) }
        return (pair.offset, pair.element)
    }
}

// MARK: - Demo views

struct FlowDemo: View {
    let tags = ["SwiftUI", "Layout", "iOS 16", "Custom", "Flow", "Wrap",
                "Horizontal", "Adaptive", "Tags", "Chips", "Sandbox"]
    var body: some View {
        FlowLayout(horizontalSpacing: 8, verticalSpacing: 8) {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Color.blue.opacity(0.15), in: Capsule())
                    .foregroundStyle(Color.blue)
            }
        }
        .padding()
        .frame(width: 320)
    }
}

struct RadialDemo: View {
    var body: some View {
        RadialLayout(radius: 110) {
            ForEach(0..<8, id: \.self) { i in
                Circle()
                    .fill(Color(hue: Double(i) / 8, saturation: 0.7, brightness: 0.85))
                    .frame(width: 36, height: 36)
                    .overlay { Text("\(i + 1)").font(.caption.bold()).foregroundStyle(.white) }
            }
        }
        .frame(width: 280, height: 280)
    }
}

struct MasonryDemo: View {
    let data: [(Color, CGFloat, String)] = [
        (.blue, 100, "A"), (.green, 160, "B"), (.orange, 80, "C"),
        (.purple, 200, "D"), (.pink, 120, "E"), (.teal, 90, "F"),
        (.red, 140, "G"), (.indigo, 110, "H"),
    ]
    var body: some View {
        MasonryLayout(columns: 2, spacing: 10) {
            ForEach(data.indices, id: \.self) { i in
                RoundedRectangle(cornerRadius: 12)
                    .fill(data[i].0.opacity(0.75))
                    .frame(height: data[i].1)
                    .overlay { Text(data[i].2).font(.headline.bold()).foregroundStyle(.white) }
            }
        }
        .frame(width: 320)
        .padding()
    }
}

// =============================================================================
// 👇 Change this line to switch demos: FlowDemo / RadialDemo / MasonryDemo
// =============================================================================
PlaygroundPage.current.setLiveView(MasonryDemo())
