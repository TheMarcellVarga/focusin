import Foundation
import AppKit
import UserNotifications

@MainActor
protocol NotificationScheduling: AnyObject {
    var onReminderOpened: (() -> Void)? { get set }
    func requestAuthorization()
    func scheduleBreakReminder(after seconds: TimeInterval)
    func clearBreakReminder()
}

@MainActor
final class NotificationScheduler: NSObject, UNUserNotificationCenterDelegate, NotificationScheduling {
    static let shared = NotificationScheduler()

    private let center = UNUserNotificationCenter.current()
    private let reminderIdentifier = "focusin.break-due"

    var onReminderOpened: (() -> Void)?

    private override init() {
        super.init()
        center.delegate = self
    }

    func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func scheduleBreakReminder(after seconds: TimeInterval) {
        center.removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])

        let content = UNMutableNotificationContent()
        content.title = "Break due"
        content.body = "Open Focusin for a quick reset matched to your state."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(seconds, 1), repeats: false)
        let request = UNNotificationRequest(identifier: reminderIdentifier, content: content, trigger: trigger)
        center.add(request)
    }

    func clearBreakReminder() {
        center.removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])
        center.removeDeliveredNotifications(withIdentifiers: [reminderIdentifier])
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        await MainActor.run {
            NSApplication.shared.activate()
            onReminderOpened?()
        }
    }
}
