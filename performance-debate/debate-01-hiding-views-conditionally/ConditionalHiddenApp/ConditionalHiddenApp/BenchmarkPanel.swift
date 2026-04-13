//
//  BenchmarkPanel.swift
//  ConditionalHiddenApp
//
//  Timing benchmark with Instruments signpost support.
//

import SwiftUI
import os.signpost

// MARK: - Benchmark helper — @ViewBuilder branch (no AnyView overhead)

/// Mirrors a real `@ViewBuilder` if/else without the type-erasure cost of `AnyView`.
@ViewBuilder
private func viewBuilderBranch(isHidden: Bool) -> some View {
    if !isHidden {
        Text("dummy")
    }
}

// MARK: - Benchmark Panel

struct BenchmarkPanel: View {
    @State private var hiddenExtTime:   Double? = nil
    @State private var viewBuilderTime: Double? = nil
    @State private var opacityTime:     Double? = nil
    @State private var isRunning = false

    private let iterations = 10_000
    
    // Signposter for Instruments integration
    private let signposter = OSSignposter(subsystem: "com.benchmark.ConditionalHidden", category: "Benchmark")

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
        
        DispatchQueue.global(qos: .userInitiated).async {
            var state = false
            let signpostID = signposter.makeSignpostID()

            // Benchmark .isViewHidden
            let tHidden: Double = {
                let intervalState = signposter.beginInterval("isViewHidden Benchmark", id: signpostID)
                var view = Text("dummy").isViewHidden(false)
                let start = CFAbsoluteTimeGetCurrent()
                for i in 0..<iterations {
                    state = i.isMultiple(of: 2)
                    view = Text("dummy").isViewHidden(state)
                    _ = view
                }
                let elapsed = CFAbsoluteTimeGetCurrent() - start
                signposter.endInterval("isViewHidden Benchmark", intervalState)
                return elapsed
            }()

            // Benchmark @ViewBuilder if/else
            let tViewBuilder: Double = {
                let intervalState = signposter.beginInterval("ViewBuilder Benchmark", id: signpostID)
                let start = CFAbsoluteTimeGetCurrent()
                for i in 0..<iterations {
                    state = i.isMultiple(of: 2)
                    let v = viewBuilderBranch(isHidden: state)
                    _ = v
                }
                let elapsed = CFAbsoluteTimeGetCurrent() - start
                signposter.endInterval("ViewBuilder Benchmark", intervalState)
                return elapsed
            }()

            // Benchmark .opacity
            let tOpacity: Double = {
                let intervalState = signposter.beginInterval("Opacity Benchmark", id: signpostID)
                let start = CFAbsoluteTimeGetCurrent()
                for i in 0..<iterations {
                    state = i.isMultiple(of: 2)
                    let v = Text("dummy").opacity(state ? 0 : 1)
                    _ = v
                }
                let elapsed = CFAbsoluteTimeGetCurrent() - start
                signposter.endInterval("Opacity Benchmark", intervalState)
                return elapsed
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
