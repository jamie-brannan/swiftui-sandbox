//
//  SummaryView.swift
//  ConditionalHiddenApp
//
//  Key takeaways summary.
//

import SwiftUI

struct SummaryView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Key Takeaways", systemImage: "lightbulb")
                .font(.headline)
            Group {
                bulletPoint("`.isViewHidden` and `.opacity(0)` keep the view in the SwiftUI node tree. The view's body is still called on every relevant state change, and its layout space is preserved.")
                bulletPoint("`@ViewBuilder` if/else removes the view from the tree entirely. Body is *not* called while hidden, saving diffing work. Layout space collapses.")
                bulletPoint("For views inside a `ZStack` driven by `@Published` state, `if/else` is the most efficient choice — it avoids unnecessary body evaluations and keeps the tree smaller.")
                bulletPoint("`.opacity` is useful when you want zero-cost animated fades and don't need the space to collapse, but it still incurs body calls.")
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemBlue).opacity(0.08)))
    }

    private func bulletPoint(_ text: String) -> some View {
        Label {
            Text(LocalizedStringKey(text))
                .font(.caption)
                .foregroundColor(.secondary)
        } icon: {
            Image(systemName: "circle.fill")
                .font(.system(size: 5))
                .foregroundColor(.secondary)
        }
    }
}
