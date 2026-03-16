//: A UIKit based Playground for presenting user interface
  
import SwiftUI
import PlaygroundSupport

/// A horizontal layout that allows an overflow of non-``Text`` views into a second row that's the right size.
///
///  - Parameter interItemSpacing: between each child view, how much trailing space is there?
///  - Parameter lineSpacing: if there's another row, this will be the spacing between them
///  - Parameter maxRows: `nil` by default – ⚠️only set if there's a reason to then add a `.clipped()`, cause it'll set the bounds to the calculated bottom of the last permitted row, which enables the cropping with the modifier to be precise.

/// The designers are making rules especially based on web/CSS layouts. This structure mimics css flexbox flow-layouts.
struct PsuedoFlexbox: Layout {
    var interItemSpacing: CGFloat = 4
    var lineSpacing: CGFloat = 4
    var maxRows: Int? = nil

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {

        let maxWidth = proposal.width ?? .infinity

        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var rowCount = 1
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if x + size.width > maxWidth {
                rowCount += 1
                if let maxRows, rowCount > maxRows { break }
                
                x = 0
                y += rowHeight + lineSpacing
                rowHeight = 0
            }
            
            x += size.width + interItemSpacing
            rowHeight = max(rowHeight, size.height)
        }
        
        return CGSize(width: maxWidth, height: y + rowHeight)
    }
    
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + lineSpacing
                rowHeight = 0
            }
            
            subview.place(
                at: CGPoint(x: x, y: y),
                proposal: ProposedViewSize(size)
            )
            
            x += size.width + interItemSpacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

// MARK: - Preview

// MARK: Mock Views
struct Item: View, Identifiable {
    let id: UUID = UUID()
    let color: Color
    let length: Int = Int.random(in: 1...10)

    func randomString(_ length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyz"
        return String((0..<length).map { _ in letters.randomElement()! })
    }

    init(_ color: Color) {
        self.color = color
    }

    var body: some View {
        Text(randomString(length))
            .background(
                Rectangle()
                    .fill(color)
            )
    }
}

/// This doesn't wrap, because child items are to stay together, and not be split across rows
struct Group: View, Identifiable {
    let id: UUID = UUID()
    let items: [Item]

    init(_ items: [Item]) {
        self.items = items
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items) { item in
                item
                    .padding(.trailing, 4)
            }
        }
    }
}

// MARK: Mock Data
enum Data {
    case red
    case blue
    case yellow
    case green

    var item: Item {
        switch self {
        case .red: return Item(.red)
        case .blue: return Item(.blue)
        case .yellow: return Item(.yellow)
        case .green: return Item(.green)
        }
    }

    var group: Group {
        let items = (0..<3).map { _ in self.item } /// Unique item each time
        return Group(items)
    }
}

// MARK: Render

struct SampleRenderView: View {
    let collection: [Group] = [
        Data.red.group,
        Data.yellow.group,
        Data.green.group,
        Data.blue.group,
    ]

    var body: some View {
        VStack(spacing: 24) {
            Text("Pseudo Flexbox Sandbox")
                .font(.system(.title))
                .bold()
            PsuedoFlexbox(interItemSpacing: 8, lineSpacing: 2, maxRows: nil) {
                ForEach(collection) { group in
                    group
                        .border(.pink)
                }
            }
            .border(.gray, width: 4)
        }
    }

}

/// iPhone 16 like size
PlaygroundPage.current.setLiveView(
    SampleRenderView()
        .frame(width: 393, height: 852)
)
