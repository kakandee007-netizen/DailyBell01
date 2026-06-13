import Foundation

/// A single daily reminder. Stored locally via Codable + UserDefaults.
struct Reminder: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var note: String = ""
    var hour: Int          // 0...23
    var minute: Int        // 0...59
    var notificationEnabled: Bool = true
    var repeatsDaily: Bool = true

    /// The last time the user marked this task done.
    /// "Done" is considered valid only for the calendar day it was set,
    /// so the done state resets automatically every morning.
    var lastCompletedDate: Date? = nil

    /// "HH:mm" for display, e.g. "08:30".
    var timeString: String {
        String(format: "%02d:%02d", hour, minute)
    }

    /// True only if the task was completed today (auto-resets each day).
    var isDoneToday: Bool {
        guard let date = lastCompletedDate else { return false }
        return Calendar.current.isDateInToday(date)
    }
}
