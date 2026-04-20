import SwiftUI

/// Demonstrates `MasonryLayout` with cards of varying heights.
public struct MasonryLayoutExample: View {

    private struct CardItem: Identifiable {
        let id = UUID()
        let color: Color
        let height: CGFloat
        let label: String
    }

    private let items: [CardItem] = [
        CardItem(color: .blue,   height: 100, label: "A"),
        CardItem(color: .green,  height: 160, label: "B"),
        CardItem(color: .orange, height: 80,  label: "C"),
        CardItem(color: .purple, height: 200, label: "D"),
        CardItem(color: .pink,   height: 120, label: "E"),
        CardItem(color: .teal,   height: 90,  label: "F"),
        CardItem(color: .red,    height: 140, label: "G"),
        CardItem(color: .indigo, height: 110, label: "H"),
        CardItem(color: .mint,   height: 170, label: "I"),
        CardItem(color: .yellow, height: 95,  label: "J"),
    ]

    @State private var columns: Int = 2

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("MasonryLayout")
                .font(.title2.bold())

            VStack(alignment: .leading, spacing: 4) {
                Text("Columns: \(columns)")
                    .font(.caption)
                Slider(value: Binding(
                    get: { Double(columns) },
                    set: { columns = Int($0) }
                ), in: 1...4, step: 1)
            }
            .padding(.horizontal)

            MasonryLayout(columns: columns, spacing: 10) {
                ForEach(items) { item in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(item.color.opacity(0.75))
                        .frame(height: item.height)
                        .overlay {
                            Text(item.label)
                                .font(.headline.bold())
                                .foregroundStyle(.white)
                        }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
}

#Preview {
    ScrollView {
        MasonryLayoutExample()
            .frame(maxWidth: 360)
    }
}
