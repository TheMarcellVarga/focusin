import XCTest
@testable import Focusin

final class BetaFeedbackTemplateTests: XCTestCase {
    func testTemplateIdentifiesBuildAndThreeTaskScenarios() {
        let template = BetaFeedbackTemplate.text(version: "1.2.3", build: "45")

        XCTAssertTrue(template.contains("Focusin beta feedback — 1.2.3 (45)"))
        XCTAssertTrue(template.contains("1. Core loop:"))
        XCTAssertTrue(template.contains("2. Restoration:"))
        XCTAssertTrue(template.contains("3. Controls:"))
    }

    func testTemplateRequestsAnonymousAccessibilityAndSafetyFeedback() {
        let template = BetaFeedbackTemplate.text(version: "1.2.3", build: "45")

        XCTAssertTrue(template.contains("do not include your name, email address, or private work details"))
        XCTAssertTrue(template.contains("repetitive, awkward, unsafe"))
        XCTAssertTrue(template.contains("keyboard steps, or VoiceOver announcements"))
        XCTAssertTrue(template.contains("macOS version:"))
    }
}
