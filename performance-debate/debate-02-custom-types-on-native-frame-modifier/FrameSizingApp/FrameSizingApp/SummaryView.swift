//
//  SummaryView.swift
//  FrameSizingApp
//
//  Ranked trade-off summary for all four approaches.
//

import SwiftUI

struct SummaryView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Ranked Trade-offs", systemImage: "chart.bar.xaxis")
                .font(.headline)

            Group {
                rankRow(
                    rank: "🥇",
                    title: "B — CGFloat static extension",
                    color: .orange,
                    detail: "Zero framework overhead. The constant is inlined at compile time and works with *every* modifier that already accepts `CGFloat` (`.padding`, `.offset`, `.frame`, …). No new type needed. Downside: values are duplicated from the enum; a typo can silently diverge from the design token."
                )
                rankRow(
                    rank: "🥈",
                    title: "C — extension View (.squareFrame)",
                    color: .green,
                    detail: "One thin `@inlinable` function that forwards to `.frame()`. The compiler folds it away in optimised builds — identical runtime cost to calling `.frame()` directly. Best choice when you want a named, autocomplete-friendly API that accepts the enum type. Returns the same `_FrameLayout`-backed `ModifiedContent` type as the built-in `.frame()`, so SwiftUI's diffing cost is unchanged."
                )
                rankRow(
                    rank: "🥉",
                    title: "D — ViewModifier (SquareFrameModifier)",
                    color: .purple,
                    detail: "Adds one extra type layer (`ModifiedContent<Content, SquareFrameModifier>`) in the view tree, but conforms to `Equatable` so SwiftUI can short-circuit body evaluation when neither `size` nor `alignment` has changed. Genuinely useful for *complex* modifiers that bundle multiple attributes or carry `@Environment`. Overkill for a single `.frame()` call."
                )
                rankRow(
                    rank: "4️⃣",
                    title: "A — .rawValue (direct enum access)",
                    color: .red,
                    detail: "Technically correct but bypasses the type system at the call site: `.frame(width: Sizing.s48.rawValue, …)` exposes the `CGFloat` value explicitly, which defeats the purpose of having a typed token in the first place. Use as a fallback only when passing to third-party APIs that have no `Sizing`-aware overload."
                )
            }

            Divider()

            Group {
                bulletPoint("**Should you use an enum or CGFloat extensions?** Both patterns are valid. The enum is the *single source of truth* — define it once and generate the `CGFloat` extensions from it (or use the `rawValue` accessors). This prevents values from drifting apart.")
                bulletPoint("**Performance differences are negligible** in practice. All approaches resolve to the same `_FrameLayout` attributes passed to the SwiftUI render loop. Optimise design-token ergonomics, not micro-benchmarks.")
                bulletPoint("**Instruments tip:** run Product → Profile (⌘I) and choose the SwiftUI template to see the exact number of body evaluations and modifier applications in your real app.")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14).fill(Color(.systemBlue).opacity(0.08))
        )
    }

    // MARK: - Helpers

    private func rankRow(rank: String,
                         title: String,
                         color: Color,
                         detail: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 6) {
                Text(rank)
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(color)
            }
            Text(LocalizedStringKey(detail))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
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
