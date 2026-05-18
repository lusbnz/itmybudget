import Foundation
import SwiftData

@Model
final class UserSettings {
    var pushNotificationsEnabled: Bool
    var reminderTime: Date
    var autoDetectLocation: Bool
    var currency: String
    var language: String
    
    init(
        pushNotificationsEnabled: Bool = true,
        reminderTime: Date = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date(),
        autoDetectLocation: Bool = true,
        currency: String = "USD",
        language: String = "en"
    ) {
        self.pushNotificationsEnabled = pushNotificationsEnabled
        self.reminderTime = reminderTime
        self.autoDetectLocation = autoDetectLocation
        self.currency = currency
        self.language = language
    }
}
