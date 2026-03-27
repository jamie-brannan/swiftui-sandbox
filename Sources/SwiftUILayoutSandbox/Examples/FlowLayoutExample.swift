import SwiftUI

/// Demonstrates `FlowLayout` with a collection of tag-style labels.
public struct FlowLayoutExample: View {

    private let tags = [
        "SwiftUI", "Layout", "iOS 16", "Custom", "Flow",
        "Wrap", "Horizontal", "Adaptive", "Tags", "Chips",
        "macOS 13", "Swift 5.9", "Sandbox"
    ]

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("FlowLayout")
                .font(.title2.bold())

            FlowLayout(horizontalSpacing: 8, verticalSpacing: 8, alignment: .leading) {
                ForEach(tags, id: \.self) { tag in
                    tagLabel(tag)
                }
            }
        }
        .padding()
    }

    private func tagLabel(_ text: String) -> some View {
        Text(text)
            .font(.callout)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.accentColor.opacity(0.15), in: Capsule())
            .foregroundStyle(Color.accentColor)
    }
}

#Preview {
    FlowLayoutExample()
        .frame(maxWidth: 340)
}
