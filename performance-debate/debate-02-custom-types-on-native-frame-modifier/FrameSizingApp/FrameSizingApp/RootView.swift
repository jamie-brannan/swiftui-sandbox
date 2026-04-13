//
//  RootView.swift
//  FrameSizingApp
//
//  Main app view.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Frame Sizing — Performance Debate")
                    .font(.title2.bold())
                    .padding(.top)
                Text("Four approaches to bridging a `Sizing` design-token enum with `.frame()`.\nChange the token picker in each row to observe body re-evaluations.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                RawValueRow()
                CGFloatExtRow()
                ViewExtRow()
                ViewModifierRow()
                BenchmarkPanel()
                SummaryView()
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
    }
}

#Preview {
    RootView()
}
