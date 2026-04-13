//
//  TrackedBox.swift
//  FrameSizingApp
//
//  A coloured box that records its body evaluations.
//  The frame is applied externally by each demo row using the approach under test.
//

import SwiftUI

/// A coloured box that increments `counter.count` each time its body is evaluated.
struct TrackedBox: View {
    let color: Color
    let label: String
    let counter: RenderCounter

    var body: some View {
        // Side-effect: record body execution.
        let _ = { counter.increment() }()
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(color)
            Text(label)
                .font(.caption.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(4)
        }
    }
}
