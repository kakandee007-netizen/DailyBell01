import Foundation
import Combine

/// Owns the list of reminders, persists them locally (Codable + UserDefaults),
/// and keeps scheduled notifications in sync.
final class ReminderStore: ObservableObject {
    @Published var reminders: [Reminder] = [] {
        didSet { save() }
    }

    private let storageKey = "dailybell.reminders.v1"

    init() {
        load()
    }

    /// Reminders sorted by time of day (earliest first).
    var sortedReminders: [Reminder] {
        reminders.sorted { ($0.hour, $0.minute) < ($1.hour, $1.minute) }
    }

    // MARK: - Mutations

    func add(_ reminder: Reminder) {
        reminders.append(reminder)
        rescheduleNotifications()
    }

    func update(_ reminder: Reminder) {
        guard let index = reminders.firstIndex(where: { $0.id == reminder.id }) else { return }
        reminders[index] = reminder
        rescheduleNotifications()
    }

    func delete(_ reminder: Reminder) {
        reminders.removeAll { $0.id == reminder.id }
        rescheduleNotifications()
    }

    /// Toggle today's done state. Setting it marks completion now; clearing removes it.
    func toggleDone(_ reminder: Reminder) {
        guard let index = reminders.firstIndex(where: { $0.id == reminder.id }) else { return }
        reminders[index].lastCompletedDate = reminders[index].isDoneToday ? nil : Date()
    }

    /// Enable/disable the reminder's notification without opening the edit screen.
    func toggleNotification(_ reminder: Reminder) {
        guard let index = reminders.firstIndex(where: { $0.id == reminder.id }) else { return }
        reminders[index].notificationEnabled.toggle()
        rescheduleNotifications()
    }

    /// Removes all reminders and cancels their scheduled notifications.
    func deleteAll() {
        reminders.removeAll()
        rescheduleNotifications()
    }

    func rescheduleNotifications() {
        NotificationManager.shared.sync(reminders)
    }

    // MARK: - Persistence

    private func save() {
        guard let data = try? JSONEncoder().encode(reminders) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([Reminder].self, from: data)
        else { return }
        reminders = decoded
    }
}
