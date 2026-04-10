//
//  RenderCounter.swift
//  FrameSizingApp
//
//  Tracks how many times a view's body is evaluated.
//  Mirrors the counter used in ConditionalHiddenApp.
//

import SwiftUI
import os.signpost

/// Observable counter that increments each time a tracked view's body is called.
/// Also emits Instruments signpost events for profiling in Xcode → Product → Profile.
final class RenderCounter: ObservableObject {
    @Published private(set) var count: Int = 0

    let name: String
    private let signposter: OSSignposter
    private let signpostID: OSSignpostID

    init(name: String) {
        self.name = name
        self.signposter = OSSignposter(
            subsystem: "com.benchmark.FrameSizingApp",
            category: "ViewRenders"
        )
        self.signpostID = signposter.makeSignpostID()
    }

    func increment() {
        count += 1
        signposter.emitEvent(
            "BodyEvaluation",
            id: signpostID,
            "\(name) body #\(count)"
        )
    }

    func reset() { count = 0 }
}

// One counter per demo approach.
let rawValueCounter      = RenderCounter(name: "RawValue")
let cgFloatExtCounter    = RenderCounter(name: "CGFloatExt")
let viewExtCounter       = RenderCounter(name: "ViewExt")
let viewModifierCounter  = RenderCounter(name: "ViewModifier")
