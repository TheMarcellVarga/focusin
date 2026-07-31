import Foundation

enum BetaFeedbackTemplate {
    static var current: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "unknown"
        let build = info?["CFBundleVersion"] as? String ?? "unknown"
        return text(version: version, build: build)
    }

    static func text(version: String, build: String) -> String {
        "Focusin beta feedback — " + version + " (" + build + ")\n\n" + """
        Please do not include your name, email address, or private work details.

        Try these three scenarios:

        1. Core loop: choose your current state and available time, review the suggestion, start it, then choose Done or Skip.
        2. Restoration: start a focus interval, quit Focusin, reopen it, and confirm the focus state resumes correctly.
        3. Controls: change reminder or quiet-hour settings, then complete the core loop using only the keyboard if that is comfortable for you.

        Tell us what happened:

        1. Did any scenario block you or behave differently from what you expected?
        2. Did reminders feel useful, mistimed, or annoying?
        3. Did recommendations feel specific and suitable for your setting?
        4. Did any activity feel repetitive, awkward, unsafe, or too long/short? Name the activity.
        5. Were any controls, labels, keyboard steps, or VoiceOver announcements unclear?
        6. Would Focusin earn a permanent menu bar spot? Why or why not?

        Test environment:

        - macOS version:
        - Mac model (optional):
        - Keyboard or assistive technology used (optional):
        """
    }
}
