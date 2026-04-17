//
//  RootView.swift
//  ConditionalHiddenApp
//
//  Main app view.
//

import SwiftUI

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

#Preview {
    RootView()
}
