import Foundation
import UserNotifications

/// Handles notification permission and scheduling of local notifications.
final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private init() {
        refreshStatus()
    }

    var isDenied: Bool { authorizationStatus == .denied }

    /// Asks for permission. iOS only shows the system prompt the first time.
    func requestPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] _, _ in
                self?.refreshStatus()
            }
    }

    func refreshStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.authorizationStatus = settings.authorizationStatus
            }
        }
    }

    /// Rebuilds all pending notifications from the current reminders.
    func sync(_ reminders: [Reminder]) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        for reminder in reminders where reminder.notificationEnabled {
            let content = UNMutableNotificationContent()
            content.title = reminder.title
            content.body = reminder.note.isEmpty ? "ถึงเวลาแล้ว" : "ถึงเวลาแล้ว · \(reminder.note)"
            content.sound = .default

            var components = DateComponents()
            components.hour = reminder.hour
            components.minute = reminder.minute

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: components,
                repeats: reminder.repeatsDaily
            )
            let request = UNNotificationRequest(
                identifier: reminder.id.uuidString,
                content: content,
                trigger: trigger
            )
            center.add(request)
        }
    }

    /// Fires a one-off test notification a few seconds from now.
    func sendTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "DailyBell"
        content.body = "นี่คือการทดสอบแจ้งเตือน 🔔"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(
            identifier: "dailybell.test.\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }
}
