//
//  RenderCountBadge.swift
//  FrameSizingApp
//
//  Displays the current body-call count for a RenderCounter.
//

import SwiftUI

struct RenderCountBadge: View {
    @ObservedObject var counter: RenderCounter

    var body: some View {
        VStack(spacing: 2) {
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
