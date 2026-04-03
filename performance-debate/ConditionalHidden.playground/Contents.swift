//: # Conditional Hidden — Performance Debate
//:
//: This playground benchmarks three common ways to conditionally hide a SwiftUI view,
//: and tracks how many times each child view's `body` is evaluated.
//:
//: ## The three approaches
//:
//: 1. **`.isViewHidden(_:)`** — a custom extension that calls `.hidden()` or returns `self`.
//:    The view *stays in the hierarchy* either way; only visibility changes.
//:
//: 2. **`@ViewBuilder` if/else** — the idiomatic SwiftUI approach.
//:    When `isHidden == true` the view is *removed* from the hierarchy entirely.
//:
//: 3. **`.opacity(_:)`** — sets opacity to `0` instead of hiding.
//:    Like `.hidden()`, the view stays in the hierarchy and still participates in layout.

import SwiftUI
import PlaygroundSupport

// MARK: - Render-count tracking

/// A counter used to record how many times a view's body is called.
/// Must only be mutated from the main thread (SwiftUI always evaluates `body` on the main thread).
final class RenderCounter: ObservableObject {
    @Published private(set) var count: Int = 0
    func increment() { count += 1 }
    func reset()     { count = 0  }
}

// Three independent counters — one per approach.
let hiddenExtCounter  = RenderCounter()
let viewBuilderCounter = RenderCounter()
let opacityCounter    = RenderCounter()

// MARK: - Extension under debate

extension View {
    /// The function being debated: keeps the view in the hierarchy but calls `.hidden()`.
    @ViewBuilder func isViewHidden(_ isHidden: Bool) -> some View {
        if isHidden {
            self.hidden()
        } else {
            self
        }
    }
}

// MARK: - Instrumented child views

/// A coloured box that increments `counter.count` every time its body is evaluated.
struct TrackedBox: View {
    let color: Color
    let label: String
    let counter: RenderCounter

    var body: some View {
        // Side-effect: record that body ran.
        let _ = { counter.increment() }()
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(color)
                .frame(width: 120, height: 80)
            Text(label)
                .font(.caption.bold())
                .foregroundColor(.white)
        }
    }
}

// MARK: - Benchmark helper — @ViewBuilder branch (no AnyView overhead)

/// Mirrors a real `@ViewBuilder` if/else without the type-erasure cost of `AnyView`.
@ViewBuilder
private func viewBuilderBranch(isHidden: Bool) -> some View {
    if !isHidden {
        Text("dummy")
    }
}

// MARK: - Demo rows

/// Row 1 — `.isViewHidden(_:)` extension
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

/// Row 2 — `@ViewBuilder` if/else
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

/// Row 3 — `.opacity(_:)`
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

// MARK: - Render-count badge

struct RenderCountBadge: View {
    @ObservedObject var counter: RenderCounter

    var body: some View {
        VStack {
            Text("\(counter.count)")
                .font(.system(.title2, design: .monospaced).bold())
                .foregroundColor(.primary)
            Text("body calls")
                .font(.caption2)
                .foregroundColor(.secondary)
            Button("Reset") { counter.reset() }
                .font(.caption2)
                .buttonStyle(.bordered)
        }
    }
}

// MARK: - Benchmark panel

struct BenchmarkPanel: View {
    @State private var hiddenExtTime:   Double? = nil
    @State private var viewBuilderTime: Double? = nil
    @State private var opacityTime:     Double? = nil
    @State private var isRunning = false

    private let iterations = 10_000

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Timing Benchmark (\(iterations) toggles)", systemImage: "stopwatch")
                .font(.headline)
            Text("Measures how long it takes to toggle the hidden state \(iterations) times for each approach. Lower is better.")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(spacing: 16) {
                timingCell(label: ".isViewHidden", time: hiddenExtTime, color: .blue)
                timingCell(label: "if / else",     time: viewBuilderTime, color: .green)
                timingCell(label: ".opacity",       time: opacityTime,    color: .orange)
            }

            Button(isRunning ? "Running…" : "Run Benchmark") {
                runBenchmark()
            }
            .buttonStyle(.borderedProminent)
            .disabled(isRunning)

            if let h = hiddenExtTime, let v = viewBuilderTime, let o = opacityTime {
                Divider()
                Text("**Winner:** \(winnerLabel(h: h, v: v, o: o))")
                    .font(.caption)
                // Show how many times slower each other approach is vs if/else.
                if v > 0 && o > 0 {
                    Text(String(format: "if/else vs .hidden(): %.2f×  |  if/else vs .opacity(): %.2f×", h / v, o / v))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemGray6)))
    }

    private func timingCell(label: String, time: Double?, color: Color) -> some View {
        VStack(spacing: 4) {
            if let t = time {
                Text(String(format: "%.4f s", t))
                    .font(.system(.body, design: .monospaced).bold())
                    .foregroundColor(color)
            } else {
                Text("—")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            Text(label)
                .font(.caption2)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private func winnerLabel(h: Double, v: Double, o: Double) -> String {
        let m = min(h, v, o)
        if m == v { return "if / else 🏆" }
        if m == h { return ".isViewHidden 🏆" }
        return ".opacity 🏆"
    }

    private func runBenchmark() {
        isRunning = true
        // Run on a background queue so the UI stays responsive.
        DispatchQueue.global(qos: .userInitiated).async {
            // Each benchmark creates a local state variable and measures only
            // the cost of evaluating the branch condition, mimicking what SwiftUI does.
            var state = false

            let tHidden: Double = {
                var view = Text("dummy").isViewHidden(false)
                let start = CFAbsoluteTimeGetCurrent()
                for i in 0..<iterations {
                    state = i.isMultiple(of: 2)
                    view = Text("dummy").isViewHidden(state)
                    _ = view
                }
                return CFAbsoluteTimeGetCurrent() - start
            }()

            let tViewBuilder: Double = {
                let start = CFAbsoluteTimeGetCurrent()
                for i in 0..<iterations {
                    state = i.isMultiple(of: 2)
                    // Use a real @ViewBuilder function — same cost as an inline if/else.
                    let v = viewBuilderBranch(isHidden: state)
                    _ = v
                }
                return CFAbsoluteTimeGetCurrent() - start
            }()

            let tOpacity: Double = {
                let start = CFAbsoluteTimeGetCurrent()
                for i in 0..<iterations {
                    state = i.isMultiple(of: 2)
                    let v = Text("dummy").opacity(state ? 0 : 1)
                    _ = v
                }
                return CFAbsoluteTimeGetCurrent() - start
            }()

            DispatchQueue.main.async {
                hiddenExtTime   = tHidden
                viewBuilderTime = tViewBuilder
                opacityTime     = tOpacity
                isRunning = false
            }
        }
    }
}

// MARK: - Summary / notes

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

// MARK: - Root view

struct RootView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Conditional Hidden — Performance")
                    .font(.title2.bold())
                    .padding(.top)

                HiddenExtRow()
                ViewBuilderRow()
                OpacityRow()
                BenchmarkPanel()
                SummaryView()
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
    }
}

// MARK: - Live View

PlaygroundPage.current.setLiveView(
    RootView()
        .frame(width: 430, height: 900)
)

