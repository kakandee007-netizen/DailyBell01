import SwiftUI
import UIKit

struct ContentView: View {
    @EnvironmentObject var store: ReminderStore
    @ObservedObject private var notifications = NotificationManager.shared
    @Environment(\.scenePhase) private var scenePhase

    @State private var showingAdd = false
    @State private var editing: Reminder?
    @State private var showingSettings = false

    private var pending: [Reminder] { store.sortedReminders.filter { !$0.isDoneToday } }
    private var done: [Reminder] { store.sortedReminders.filter { $0.isDoneToday } }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Palette.bg.ignoresSafeArea()
                mainContent
                addButton
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .tint(Palette.accent)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingAdd) {
            AddReminderView().environmentObject(store)
        }
        .sheet(item: $editing) { reminder in
            EditReminderView(reminder: reminder).environmentObject(store)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView().environmentObject(store)
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active { notifications.refreshStatus() }
        }
    }

    // MARK: - Sections

    private var mainContent: some View {
        VStack(spacing: 0) {
            header
            if notifications.isDenied { warningBanner }
            if store.reminders.isEmpty {
                emptyState
            } else {
                listView
            }
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text(Self.thaiDate())
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Palette.muted)
                Text("วันนี้")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundColor(Palette.ink)
            }
            Spacer()
            Button {
                showingSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Palette.ink2)
                    .frame(width: 38, height: 38)
                    .background(Circle().fill(Palette.card))
                    .overlay(Circle().stroke(Palette.line))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 14)
    }

    private var warningBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(Palette.accent)
            VStack(alignment: .leading, spacing: 2) {
                Text("การแจ้งเตือนถูกปิดอยู่")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Palette.ink)
                Text("เปิดการแจ้งเตือนในการตั้งค่า เพื่อให้ DailyBell เตือนคุณได้")
                    .font(.system(size: 12))
                    .foregroundColor(Palette.ink2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            Button("ตั้งค่า") { openSettings() }
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Palette.accentSoft)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(Palette.card))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Palette.accent.opacity(0.35)))
        .padding(.horizontal, 16)
        .padding(.bottom, 6)
    }

    private var listView: some View {
        List {
            if !pending.isEmpty {
                Section {
                    ForEach(pending) { reminderRow($0) }
                } header: {
                    sectionHeader("กำลังจะถึง")
                }
            }
            if !done.isEmpty {
                Section {
                    ForEach(done) { reminderRow($0) }
                } header: {
                    sectionHeader("เสร็จแล้ว · \(done.count) รายการ")
                }
            }
            Color.clear
                .frame(height: 80)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Palette.bg)
    }

    private func reminderRow(_ reminder: Reminder) -> some View {
        ReminderRow(
            reminder: reminder,
            onToggleDone: { store.toggleDone(reminder) },
            onToggleNotification: { store.toggleNotification(reminder) }
        )
        .contentShape(Rectangle())
        .onTapGesture { editing = reminder }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 4, leading: 14, bottom: 4, trailing: 14))
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                store.delete(reminder)
            } label: {
                Label("ลบ", systemImage: "trash")
            }
        }
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .tracking(0.8)
            .textCase(.uppercase)
            .foregroundColor(Palette.muted)
            .padding(.top, 6)
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Spacer()
            Image(systemName: "bell")
                .font(.system(size: 40))
                .foregroundColor(Palette.muted)
            Text("ยังไม่มีรายการวันนี้")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(Palette.ink2)
            Text("แตะ ‘เพิ่มรายการ’ เพื่อเริ่มเตือนความจำ")
                .font(.system(size: 13))
                .foregroundColor(Palette.muted)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var addButton: some View {
        Button { showingAdd = true } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                Text("เพิ่มรายการ")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(Palette.onAccent)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Capsule().fill(Palette.accent))
            .shadow(color: Palette.accent.opacity(0.35), radius: 12, y: 6)
        }
        .padding(.trailing, 18)
        .padding(.bottom, 22)
    }

    // MARK: - Helpers

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    static func thaiDate() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "th_TH")
        formatter.calendar = Calendar(identifier: .buddhist)
        formatter.setLocalizedDateFormatFromTemplate("EEEEdMMMMy")
        return formatter.string(from: Date())
    }
}

/// A single reminder row in the today list.
struct ReminderRow: View {
    let reminder: Reminder
    var onToggleDone: () -> Void
    var onToggleNotification: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text(reminder.timeString)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(reminder.isDoneToday ? Palette.muted : Palette.ink)
                .frame(width: 46)

            VStack(alignment: .leading, spacing: 3) {
                Text(reminder.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(reminder.isDoneToday ? Palette.muted : Palette.ink)
                    .strikethrough(reminder.isDoneToday)
                    .lineLimit(1)

                if reminder.repeatsDaily || !reminder.note.isEmpty {
                    HStack(spacing: 6) {
                        if reminder.repeatsDaily {
                            Label("ทุกวัน", systemImage: "arrow.triangle.2.circlepath")
                                .font(.system(size: 11))
                                .foregroundColor(Palette.accent.opacity(0.85))
                        }
                        if !reminder.note.isEmpty {
                            Text(reminder.repeatsDaily ? "· \(reminder.note)" : reminder.note)
                                .font(.system(size: 11))
                                .foregroundColor(Palette.muted)
                                .lineLimit(1)
                        }
                    }
                }
            }

            Spacer()

            Button(action: onToggleNotification) {
                Image(systemName: reminder.notificationEnabled ? "bell.fill" : "bell.slash")
                    .font(.system(size: 13))
                    .foregroundColor(reminder.notificationEnabled ? Palette.accent : Palette.muted.opacity(0.5))
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)

            Button(action: onToggleDone) {
                ZStack {
                    Circle()
                        .fill(reminder.isDoneToday ? Palette.accent : Color.clear)
                        .overlay(
                            Circle().stroke(
                                reminder.isDoneToday ? Palette.accent : Color.white.opacity(0.25),
                                lineWidth: 1.6
                            )
                        )
                        .frame(width: 26, height: 26)
                    if reminder.isDoneToday {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Palette.onAccent)
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 11)
        .padding(.horizontal, 13)
        .background(RoundedRectangle(cornerRadius: 16).fill(Palette.card))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Palette.line))
        .opacity(reminder.isDoneToday ? 0.65 : 1)
    }
}
