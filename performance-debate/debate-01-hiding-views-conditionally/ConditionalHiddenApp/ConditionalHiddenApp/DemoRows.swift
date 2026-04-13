//
//  DemoRows.swift
//  ConditionalHiddenApp
//
//  The three demo rows comparing different hiding approaches.
//

import SwiftUI

// MARK: - Row 1 — `.isViewHidden(_:)` extension

struct HiddenExtRow: View {
    @State private var isHidden = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("1 · .isViewHidden(_:) extension", systemImage: "eye.slash")
                .font(.headline)
            Text("Calls .hidden() — view **stays** in the hierarchy, layout space is **preserved**.")
                .font(.caption)
                .foregroundColor(.secondary)
            HStack(spacing: 16) {
                TrackedBox(color: .blue, label: "Box A", counter: hiddenExtCounter)
                    .isViewHidden(isHidden)
                RenderCountBadge(counter: hiddenExtCounter)
            }
            Button(isHidden ? "Show" : "Hide") { isHidden.toggle() }
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemGray6)))
    }
}

// MARK: - Row 2 — `@ViewBuilder` if/else

struct ViewBuilderRow: View {
    @State private var isHidden = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("2 · @ViewBuilder if / else", systemImage: "checkmark.seal")
                .font(.headline)
            Text("Removes the view from the hierarchy. No layout space when hidden.")
                .font(.caption)
                .foregroundColor(.secondary)
            HStack(spacing: 16) {
                if !isHidden {
                    TrackedBox(color: .green, label: "Box B", counter: viewBuilderCounter)
                }
                RenderCountBadge(counter: viewBuilderCounter)
            }
            Button(isHidden ? "Show" : "Hide") { isHidden.toggle() }
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemGray6)))
    }
}

// MARK: - Row 3 — `.opacity(_:)`

struct OpacityRow: View {
    @State private var isHidden = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("3 · .opacity(0)", systemImage: "rectangle.dashed")
                .font(.headline)
            Text("View stays in the hierarchy, layout space is **preserved**. Tap still registers.")
                .font(.caption)
                .foregroundColor(.secondary)
            HStack(spacing: 16) {
                TrackedBox(color: .orange, label: "Box C", counter: opacityCounter)
                    .opacity(isHidden ? 0 : 1)
                RenderCountBadge(counter: opacityCounter)
            }
            Button(isHidden ? "Show" : "Hide") { isHidden.toggle() }
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemGray6)))
    }
}
