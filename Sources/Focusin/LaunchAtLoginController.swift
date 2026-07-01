import Foundation
import ServiceManagement

@MainActor
protocol LaunchAtLoginControlling {
    func setEnabled(_ enabled: Bool)
}

struct LaunchAtLoginController: LaunchAtLoginControlling {
    func setEnabled(_ enabled: Bool) {
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
        } catch {
            assertionFailure("Unable to update launch at login: \(error)")
        }
    }
}
