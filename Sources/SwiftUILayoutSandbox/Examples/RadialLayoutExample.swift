import SwiftUI

/// Demonstrates `RadialLayout` with a clock-face of numbered circles and an
/// interactive arc sweep control.
public struct RadialLayoutExample: View {

    @State private var itemCount: Int = 8
    @State private var sweepDegrees: Double = 360

    public init() {}

    public var body: some View {
        VStack(spacing: 24) {
            Text("RadialLayout")
                .font(.title2.bold())

            RadialLayout(
                radius: 110,
                startAngle: .degrees(-90),
                totalAngle: .degrees(sweepDegrees)
            ) {
                ForEach(0..<itemCount, id: \.self) { index in
                    Circle()
                        .fill(Color(hue: Double(index) / Double(max(itemCount, 1)), saturation: 0.7, brightness: 0.85))
                        .frame(width: 36, height: 36)
                        .overlay {
                            Text("\(index + 1)")
                                .font(.caption.bold())
                                .foregroundStyle(.white)
                        }
                }
            }
            .frame(width: 280, height: 280)

            VStack(alignment: .leading, spacing: 8) {
                Text("Items: \(itemCount)")
                    .font(.caption)
                Slider(value: Binding(
                    get: { Double(itemCount) },
                    set: { itemCount = Int($0) }
                ), in: 1...12, step: 1)

                Text("Arc: \(Int(sweepDegrees))°")
                    .font(.caption)
                Slider(value: $sweepDegrees, in: 30...360, step: 10)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

#Preview {
    RadialLayoutExample()
}
