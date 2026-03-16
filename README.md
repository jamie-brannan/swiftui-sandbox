# swiftui-layout-sandbox

A personal reference repository for experimenting with and demonstrating
**custom SwiftUI layouts** built purely with SwiftUI's `Layout` protocol
(iOS 16 / macOS 13+).

Intended as a living proof-of-concepts sandbox to explore layout ideas,
share with others, and use as a day-to-day reference.

---

## Contents

| Path | Description |
|------|-------------|
| `Sources/SwiftUILayoutSandbox/Layouts/` | Reusable custom `Layout` implementations |
| `Sources/SwiftUILayoutSandbox/Examples/` | SwiftUI views with `#Preview` that exercise each layout |
| `Playgrounds/SwiftUILayouts.playground/` | Self-contained Xcode Playground with all three layouts |
| `Tests/SwiftUILayoutSandboxTests/` | Unit tests for layout configuration logic |

---

## Custom Layouts

### `FlowLayout`
Arranges subviews **horizontally** and wraps them to a new row when they
overflow the available width — the same behaviour as CSS `flex-wrap`.
Great for tag clouds, chip groups, and keyword lists.

```swift
FlowLayout(horizontalSpacing: 8, verticalSpacing: 8, alignment: .leading) {
    ForEach(tags, id: \.self) { tag in
        TagChip(tag)
    }
}
```

### `RadialLayout`
Distributes subviews **evenly around a circular arc**. `totalAngle` controls
the sweep (360° = full ring, 180° = semicircle, etc.) and `startAngle` sets
the origin point.

```swift
RadialLayout(radius: 110, startAngle: .degrees(-90), totalAngle: .degrees(360)) {
    ForEach(items) { item in
        ItemDot(item)
    }
}
.frame(width: 280, height: 280)
```

### `MasonryLayout`
Staggered **Pinterest-style grid** with a configurable number of columns.
Each new item is placed in the shortest column so that items of varying
heights pack together without gaps.

```swift
MasonryLayout(columns: 2, spacing: 10) {
    ForEach(cards) { card in
        CardView(card)
    }
}
```

---

## Requirements

- Xcode 15+
- iOS 16+ / macOS 13+ (uses the [`Layout`](https://developer.apple.com/documentation/swiftui/layout) protocol)
- Swift 5.9+

---

## Usage

### As a Swift Package
Open the repository root in Xcode — it is a Swift Package and will resolve
automatically. Each layout is importable via `import SwiftUILayoutSandbox`.

### As a Playground
Open `Playgrounds/SwiftUILayouts.playground` in Xcode. The playground is
self-contained; no package import is needed. Switch the demo at the bottom
of `Contents.swift`:

```swift
// Change to FlowDemo(), RadialDemo(), or MasonryDemo()
PlaygroundPage.current.setLiveView(MasonryDemo())
```

---

## License

MIT — see [LICENSE](LICENSE).
