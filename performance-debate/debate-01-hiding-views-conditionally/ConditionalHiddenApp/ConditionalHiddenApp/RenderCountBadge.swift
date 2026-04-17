//
//  RenderCountBadge.swift
//  ConditionalHiddenApp
//
//  Displays the current body-call count.
//

import SwiftUI

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
