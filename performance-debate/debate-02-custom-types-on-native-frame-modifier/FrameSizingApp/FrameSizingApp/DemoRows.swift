//
//  DemoRows.swift
//  FrameSizingApp
//
//  Four demo rows — one for each approach to bridging `Sizing` with `.frame()`.
//  Each row lets you pick a `Sizing` token and shows how many times the
//  TrackedBox body is evaluated.
//

import SwiftUI

// MARK: - Shared picker helper

/// A segmented picker for selecting a `Sizing` token.
private struct SizingPicker: View {
    @Binding var selection: Sizing
    let tint: Color

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(Sizing.allCases, id: \.self) { s in
                    Button(s.label) { selection = s }
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule().fill(selection == s ? tint : Color(.systemGray5))
                        )
                        .foregroundColor(selection == s ? .white : .primary)
                }
            }
        }
    }
}

// MARK: - Row 1 — Approach A: direct `.rawValue`

struct RawValueRow: View {
    @State private var sizing: Sizing = .s48

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("A · Sizing.rawValue", systemImage: "number")
                .font(.headline)
            Text("`.frame(width: Sizing.s48.rawValue, height: …)` — explicit `.rawValue` access; works but verbose and bypasses type-safety at the call site.")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(spacing: 16) {
                TrackedBox(color: .red, label: "Box A", counter: rawValueCounter)
                    // ← Approach A: caller must unwrap .rawValue manually
                    .frame(
                        width: sizing.rawValue,
                        height: sizing.rawValue
                    )
                RenderCountBadge(counter: rawValueCounter)
            }

            SizingPicker(selection: $sizing, tint: .red)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14).fill(Color(.systemGray6))
        )
    }
}

// MARK: - Row 2 — Approach B: CGFloat static extension

struct CGFloatExtRow: View {
    @State private var sizing: Sizing = .s48
    // Map Sizing → CGFloat extension constant
    private var cgSize: CGFloat { sizing.rawValue }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("B · CGFloat static extension", systemImage: "number.circle")
                .font(.headline)
            Text("`.frame(width: .s48, height: .s48)` — `CGFloat` static let properties mirror each token. Works with *any* modifier that takes `CGFloat`: `.frame`, `.padding`, `.offset`, …")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(spacing: 16) {
                TrackedBox(color: .orange, label: "Box B", counter: cgFloatExtCounter)
                    // ← Approach B: CGFloat static extension (here cgSize holds it)
                    .frame(width: cgSize, height: cgSize)
                RenderCountBadge(counter: cgFloatExtCounter)
            }

            SizingPicker(selection: $sizing, tint: .orange)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14).fill(Color(.systemGray6))
        )
    }
}

// MARK: - Row 3 — Approach C: extension View

struct ViewExtRow: View {
    @State private var sizing: Sizing = .s48

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("C · extension View", systemImage: "square.resize")
                .font(.headline)
            Text("`.squareFrame(.s48)` — a thin `@inlinable` extension on `View` that forwards to `.frame()`. The compiler inlines it; zero extra dispatch overhead. Returns the same `_FrameLayout` modifier type as calling `.frame()` directly.")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(spacing: 16) {
                TrackedBox(color: .green, label: "Box C", counter: viewExtCounter)
                    // ← Approach C: extension View convenience method
                    .squareFrame(sizing)
                RenderCountBadge(counter: viewExtCounter)
            }

            SizingPicker(selection: $sizing, tint: .green)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14).fill(Color(.systemGray6))
        )
    }
}

// MARK: - Row 4 — Approach D: ViewModifier

struct ViewModifierRow: View {
    @State private var sizing: Sizing = .s48

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("D · ViewModifier", systemImage: "wrench.adjustable")
                .font(.headline)
            Text("`.squareFrameViaModifier(.s48)` — an `Equatable` `ViewModifier` struct. SwiftUI can skip the modifier when `size` is unchanged, slightly reducing diffing cost in large trees. More verbose than the extension approach without a wrapper.")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(spacing: 16) {
                TrackedBox(color: .purple, label: "Box D", counter: viewModifierCounter)
                    // ← Approach D: explicit ViewModifier
                    .squareFrameViaModifier(sizing)
                RenderCountBadge(counter: viewModifierCounter)
            }

            SizingPicker(selection: $sizing, tint: .purple)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14).fill(Color(.systemGray6))
        )
    }
}
