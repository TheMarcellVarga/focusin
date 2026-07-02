import Foundation
import AppKit
import UserNotifications

@MainActor
protocol NotificationScheduling: AnyObject {
    var onReminderOpened: (() -> Void)? { get set }
    func authorizationStatus(_ completion: @escaping @MainActor @Sendable (NotificationPermissionStatus) -> Void)
    func requestAuthorization(_ completion: @escaping @MainActor @Sendable (NotificationPermissionStatus) -> Void)
    func scheduleBreakReminder(after seconds: TimeInterval)
    func clearBreakReminder()
}

enum NotificationPermissionStatus: Equatable, Sendable {
    case notDetermined
    case denied
    case authorized
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

    func authorizationStatus(_ completion: @escaping @MainActor @Sendable (NotificationPermissionStatus) -> Void) {
        Task {
            let settings = await center.notificationSettings()
            let status = Self.permissionStatus(from: settings.authorizationStatus)
            completion(status)
        }
    }

    func requestAuthorization(_ completion: @escaping @MainActor @Sendable (NotificationPermissionStatus) -> Void) {
        Task {
            _ = try? await center.requestAuthorization(options: [.alert, .sound])
            let settings = await center.notificationSettings()
            completion(Self.permissionStatus(from: settings.authorizationStatus))
        }
    }

    private nonisolated static func permissionStatus(from status: UNAuthorizationStatus) -> NotificationPermissionStatus {
        switch status {
        case .notDetermined: .notDetermined
        case .denied: .denied
        case .authorized, .provisional, .ephemeral: .authorized
        @unknown default: .denied
        }
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
