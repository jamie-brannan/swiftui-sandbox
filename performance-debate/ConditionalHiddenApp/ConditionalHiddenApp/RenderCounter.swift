//
//  RenderCounter.swift
//  ConditionalHiddenApp
//
//  Tracks how many times a view's body is called.
//

import SwiftUI
import os.signpost

/// A counter used to record how many times a view's body is called.
/// Also posts signposts for Instruments tracing.
final class RenderCounter: ObservableObject {
    @Published private(set) var count: Int = 0
    
    let name: String
    private let signposter: OSSignposter
    private let signpostID: OSSignpostID
    
    init(name: String) {
        self.name = name
        self.signposter = OSSignposter(subsystem: "com.benchmark.ConditionalHidden", category: "ViewRenders")
        self.signpostID = signposter.makeSignpostID()
    }
    
    func increment() {
        count += 1
        // Post a signpost event for Instruments
        signposter.emitEvent("BodyEvaluation", id: signpostID, "\(self.name) body #\(self.count)")
    }
    
    func reset() {
        count = 0
    }
}

// Three independent counters — one per approach.
let hiddenExtCounter = RenderCounter(name: "HiddenExt")
let viewBuilderCounter = RenderCounter(name: "ViewBuilder")
let opacityCounter = RenderCounter(name: "Opacity")
