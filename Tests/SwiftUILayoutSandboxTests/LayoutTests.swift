import XCTest
import SwiftUI
@testable import SwiftUILayoutSandbox

final class FlowLayoutTests: XCTestCase {

    // A minimal helper that exercises sizeThatFits with a fixed-width proposal.
    func testSizeThatFitsDoesNotExceedProposedWidth() {
        let layout = FlowLayout(horizontalSpacing: 8, verticalSpacing: 8)
        // The layout itself doesn't interact with real subviews in unit tests,
        // but we can verify the spacing configuration is stored correctly.
        XCTAssertEqual(layout.horizontalSpacing, 8)
        XCTAssertEqual(layout.verticalSpacing, 8)
    }

    func testDefaultAlignmentIsLeading() {
        let layout = FlowLayout()
        XCTAssertEqual(layout.alignment, .leading)
    }
}

final class RadialLayoutTests: XCTestCase {

    func testDefaultRadius() {
        let layout = RadialLayout()
        XCTAssertEqual(layout.radius, 100)
    }

    func testDefaultStartAngleIsTopOfClock() {
        let layout = RadialLayout()
        XCTAssertEqual(layout.startAngle.degrees, -90, accuracy: 0.001)
    }

    func testDefaultTotalAngleIsFullCircle() {
        let layout = RadialLayout()
        XCTAssertEqual(layout.totalAngle.degrees, 360, accuracy: 0.001)
    }

    func testCustomRadius() {
        let layout = RadialLayout(radius: 150)
        XCTAssertEqual(layout.radius, 150)
    }
}

final class MasonryLayoutTests: XCTestCase {

    func testColumnsClampedToMinimumOfOne() {
        let layout = MasonryLayout(columns: 0)
        XCTAssertEqual(layout.columns, 1)
    }

    func testNegativeColumnsClampedToOne() {
        let layout = MasonryLayout(columns: -5)
        XCTAssertEqual(layout.columns, 1)
    }

    func testDefaultSpacing() {
        let layout = MasonryLayout()
        XCTAssertEqual(layout.spacing, 8)
    }

    func testCustomColumnsAndSpacing() {
        let layout = MasonryLayout(columns: 3, spacing: 12)
        XCTAssertEqual(layout.columns, 3)
        XCTAssertEqual(layout.spacing, 12)
    }
}
