import Testing
import XCTest
@testable import CoreMCPKit

@Test func example() async throws {
    let pkg = CoreMCPKit()
    XCTAssertEqual(pkg.greet(name: "İsa"), "Hello, İsa!")
}
