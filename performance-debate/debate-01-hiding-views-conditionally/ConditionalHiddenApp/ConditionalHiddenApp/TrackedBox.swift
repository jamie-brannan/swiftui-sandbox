//
//  TrackedBox.swift
//  ConditionalHiddenApp
//
//  A colored box that tracks body evaluations.
//

import SwiftUI
import os.signpost

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
