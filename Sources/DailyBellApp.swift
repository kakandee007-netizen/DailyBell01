import SwiftUI

@main
struct DailyBellApp: App {
    @StateObject private var store = ReminderStore()
    @ObservedObject private var notifications = NotificationManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
                .onAppear {
                    // Ask for notification permission on first launch.
                    notifications.requestPermission()
                    // Make sure scheduled notifications match stored reminders.
                    store.rescheduleNotifications()
                }
        }
    }
}
