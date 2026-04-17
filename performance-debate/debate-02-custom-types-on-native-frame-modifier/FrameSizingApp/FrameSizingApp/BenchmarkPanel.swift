//
//  BenchmarkPanel.swift
//  FrameSizingApp
//
//  Micro-benchmark: measures the time to construct 10,000 framed views using
//  each of the four approaches. Emits Instruments signposts for deeper profiling.
//

import SwiftUI
import os.signpost

struct BenchmarkPanel: View {
    @State private var rawValueTime:      Double? = nil
    @State private var cgFloatExtTime:    Double? = nil
    @State private var viewExtTime:       Double? = nil
    @State private var viewModifierTime:  Double? = nil
    @State private var isRunning = false

    private let iterations = 10_000

    private let signposter = OSSignposter(
        subsystem: "com.benchmark.FrameSizingApp",
        category: "Benchmark"
    )

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Construction Benchmark (\(iterations) views)", systemImage: "stopwatch")
                .font(.headline)
            Text("Measures the time to construct \(iterations) framed views with each approach. All four approaches ultimately call `.frame(width:height:alignment:)` — differences reflect type-construction overhead. Lower is better.")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(spacing: 8) {
                timingCell(label: "A\n.rawValue",    time: rawValueTime,     color: .red)
                timingCell(label: "B\nCGFloat ext",  time: cgFloatExtTime,   color: .orange)
                timingCell(label: "C\nView ext",     time: viewExtTime,      color: .green)
                timingCell(label: "D\nViewModifier", time: viewModifierTime, color: .purple)
            }

            Button(isRunning ? "Running…" : "Run Benchmark") {
                runBenchmark()
            }
            .buttonStyle(.borderedProminent)
            .disabled(isRunning)

            if let a = rawValueTime,
               let b = cgFloatExtTime,
               let c = viewExtTime,
               let d = viewModifierTime {
                Divider()
                Text("**Winner:** \(winnerLabel(a: a, b: b, c: c, d: d))")
                    .font(.caption)
                if b > 0 {
                    Text(String(
                        format: "vs A — B: %.2f×  C: %.2f×  D: %.2f×",
                        a / b, c / b, d / b
                    ))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14).fill(Color(.systemGray6))
        )
    }

    // MARK: - Helpers

    private func timingCell(label: String, time: Double?, color: Color) -> some View {
        VStack(spacing: 4) {
            if let t = time {
                Text(String(format: "%.4f s", t))
                    .font(.system(.caption, design: .monospaced).bold())
                    .foregroundColor(color)
            } else {
                Text("—")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            Text(label)
                .font(.caption2)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private func winnerLabel(a: Double, b: Double, c: Double, d: Double) -> String {
        let m = min(a, b, c, d)
        if m == a { return "A (.rawValue) 🏆" }
        if m == b { return "B (CGFloat ext) 🏆" }
        if m == c { return "C (View ext) 🏆" }
        return "D (ViewModifier) 🏆"
    }

    // MARK: - Benchmark runner

    private func runBenchmark() {
        isRunning = true
        DispatchQueue.global(qos: .userInitiated).async {
            var state = false
            let sid = signposter.makeSignpostID()

            // A — .rawValue
            let tA: Double = {
                let s = signposter.beginInterval("Approach-A rawValue", id: sid)
                let start = CFAbsoluteTimeGetCurrent()
                for i in 0..<iterations {
                    state = i.isMultiple(of: 2)
                    let sz: CGFloat = state ? Sizing.s48.rawValue : Sizing.s32.rawValue
                    let v = Color.blue.frame(width: sz, height: sz)
                    _ = v
                }
                let elapsed = CFAbsoluteTimeGetCurrent() - start
                signposter.endInterval("Approach-A rawValue", s)
                return elapsed
            }()

            // B — CGFloat static extension
            let tB: Double = {
                let s = signposter.beginInterval("Approach-B CGFloatExt", id: sid)
                let start = CFAbsoluteTimeGetCurrent()
                for i in 0..<iterations {
                    state = i.isMultiple(of: 2)
                    let sz: CGFloat = state ? .s48 : .s32
                    let v = Color.orange.frame(width: sz, height: sz)
                    _ = v
                }
                let elapsed = CFAbsoluteTimeGetCurrent() - start
                signposter.endInterval("Approach-B CGFloatExt", s)
                return elapsed
            }()

            // C — extension View
            let tC: Double = {
                let s = signposter.beginInterval("Approach-C ViewExt", id: sid)
                let start = CFAbsoluteTimeGetCurrent()
                for i in 0..<iterations {
                    state = i.isMultiple(of: 2)
                    let sz: Sizing = state ? .s48 : .s32
                    let v = Color.green.squareFrame(sz)
                    _ = v
                }
                let elapsed = CFAbsoluteTimeGetCurrent() - start
                signposter.endInterval("Approach-C ViewExt", s)
                return elapsed
            }()

            // D — ViewModifier
            let tD: Double = {
                let s = signposter.beginInterval("Approach-D ViewModifier", id: sid)
                let start = CFAbsoluteTimeGetCurrent()
                for i in 0..<iterations {
                    state = i.isMultiple(of: 2)
                    let sz: Sizing = state ? .s48 : .s32
                    let v = Color.purple.squareFrameViaModifier(sz)
                    _ = v
                }
                let elapsed = CFAbsoluteTimeGetCurrent() - start
                signposter.endInterval("Approach-D ViewModifier", s)
                return elapsed
            }()

            DispatchQueue.main.async {
                rawValueTime      = tA
                cgFloatExtTime    = tB
                viewExtTime       = tC
                viewModifierTime  = tD
                isRunning = false
            }
        }
    }
}
