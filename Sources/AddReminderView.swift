import SwiftUI

struct AddReminderView: View {
    @EnvironmentObject var store: ReminderStore
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var note = ""
    @State private var time = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var notify = true
    @State private var repeatDaily = true

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
                                .tint(Palette.accent)
                        }

                        FormField(label: "เวลา") {
                            HStack {
                                DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                    .datePickerStyle(.compact)
                                    .tint(Palette.accent)
                                Spacer()
                            }
                        }

                        FormField(label: "บันทึกช่วยจำ (ไม่บังคับ)") {
                            TextField("เช่น หลังอาหารเช้า", text: $note)
                                .foregroundColor(Palette.ink)
                                .tint(Palette.accent)
                        }

                        VStack(spacing: 10) {
                            ToggleRow(icon: "bell.fill", title: "การแจ้งเตือน", isOn: $notify)
                            ToggleRow(icon: "arrow.triangle.2.circlepath", title: "ทำซ้ำทุกวัน", isOn: $repeatDaily)
                        }

                        Text("เปิด ‘การแจ้งเตือน’ เพื่อให้ iPhone เตือนตามเวลานี้ · ปิด ‘ทำซ้ำทุกวัน’ ได้ถ้าต้องการเตือนครั้งเดียว")
                            .font(.system(size: 12))
                            .foregroundColor(Palette.muted)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("เพิ่มรายการ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("ยกเลิก") { dismiss() }
                        .foregroundColor(Palette.ink2)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("บันทึก") { save() }
                        .fontWeight(.semibold)
                        .foregroundColor(trimmedTitle.isEmpty ? Palette.muted : Palette.accent)
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
        let reminder = Reminder(
            title: trimmedTitle,
            note: note.trimmingCharacters(in: .whitespaces),
            hour: components.hour ?? 8,
            minute: components.minute ?? 0,
            notificationEnabled: notify,
            repeatsDaily: repeatDaily
        )
        store.add(reminder)
        dismiss()
    }
}
