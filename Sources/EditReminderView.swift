import SwiftUI

struct EditReminderView: View {
    @EnvironmentObject var store: ReminderStore
    @Environment(\.dismiss) private var dismiss

    let reminder: Reminder

    @State private var title: String
    @State private var note: String
    @State private var time: Date
    @State private var notify: Bool
    @State private var repeatDaily: Bool

    init(reminder: Reminder) {
        self.reminder = reminder
        _title = State(initialValue: reminder.title)
        _note = State(initialValue: reminder.note)
        _time = State(initialValue: Calendar.current.date(
            bySettingHour: reminder.hour, minute: reminder.minute, second: 0, of: Date()
        ) ?? Date())
        _notify = State(initialValue: reminder.notificationEnabled)
        _repeatDaily = State(initialValue: reminder.repeatsDaily)
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespaces)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Palette.bg.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        FormField(label: "หัวข้อ") {
                            TextField("เช่น ดื่มน้ำ 1 แก้ว", text: $title)
                                .foregroundColor(Palette.ink)
                                .tint(Palette.gold)
                        }

                        FormField(label: "เวลา") {
                            HStack {
                                DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                    .datePickerStyle(.compact)
                                    .tint(Palette.gold)
                                Spacer()
                            }
                        }

                        FormField(label: "บันทึกช่วยจำ (ไม่บังคับ)") {
                            TextField("เช่น หลังอาหารเช้า", text: $note)
                                .foregroundColor(Palette.ink)
                                .tint(Palette.gold)
                        }

                        VStack(spacing: 10) {
                            ToggleRow(icon: "bell.fill", title: "การแจ้งเตือน", isOn: $notify)
                            ToggleRow(icon: "arrow.triangle.2.circlepath", title: "ทำซ้ำทุกวัน", isOn: $repeatDaily)
                        }

                        Button(role: .destructive) {
                            store.delete(reminder)
                            dismiss()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "trash")
                                Text("ลบรายการนี้")
                                    .font(.system(size: 15, weight: .medium))
                            }
                            .foregroundColor(Palette.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(RoundedRectangle(cornerRadius: 13).stroke(Palette.red.opacity(0.5)))
                        }
                        .padding(.top, 4)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("แก้ไขรายการ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("ยกเลิก") { dismiss() }
                        .foregroundColor(Palette.ink2)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("บันทึก") { save() }
                        .fontWeight(.semibold)
                        .foregroundColor(trimmedTitle.isEmpty ? Palette.muted : Palette.gold)
                        .disabled(trimmedTitle.isEmpty)
                }
            }
            .toolbarBackground(Palette.bg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }

    private func save() {
        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        var updated = reminder
        updated.title = trimmedTitle
        updated.note = note.trimmingCharacters(in: .whitespaces)
        updated.hour = components.hour ?? reminder.hour
        updated.minute = components.minute ?? reminder.minute
        updated.notificationEnabled = notify
        updated.repeatsDaily = repeatDaily
        store.update(updated)
        dismiss()
    }
}
