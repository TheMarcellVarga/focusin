import Foundation
import ServiceManagement

@MainActor
protocol LaunchAtLoginControlling {
    func status() -> LaunchAtLoginStatus
    func setEnabled(_ enabled: Bool) -> LaunchAtLoginStatus
}

enum LaunchAtLoginStatus: Equatable {
    case disabled, enabled, requiresApproval, unavailable, failed
}

struct LaunchAtLoginController: LaunchAtLoginControlling {
    func status() -> LaunchAtLoginStatus {
        Self.map(SMAppService.mainApp.status)
    }

    func setEnabled(_ enabled: Bool) -> LaunchAtLoginStatus {
        do {
            if enabled {
                if SMAppService.mainApp.status != .enabled {
                    try SMAppService.mainApp.register()
                }
            } else {
                if SMAppService.mainApp.status == .enabled {
                    try SMAppService.mainApp.unregister()
                }
            }
            return status()
        } catch {
            return .failed
        }
    }

    private static func map(_ status: SMAppService.Status) -> LaunchAtLoginStatus {
        switch status {
        case .notRegistered: .disabled
        case .enabled: .enabled
        case .requiresApproval: .requiresApproval
        case .notFound: .unavailable
        @unknown default: .unavailable
        }
    }
}
