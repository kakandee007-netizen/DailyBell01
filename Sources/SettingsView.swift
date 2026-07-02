import SwiftUI
import UIKit

struct SettingsView: View {
    @EnvironmentObject var store: ReminderStore
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var notifications = NotificationManager.shared

    @State private var showTestAlert = false
    @State private var showDeleteAllConfirm = false

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Palette.bg.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        notificationSection
                        dataSection
                        aboutSection
                    }
                    .padding(20)
                }
            }
            .navigationTitle("การตั้งค่า")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("เสร็จ") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundColor(Palette.accent)
                }
            }
            .toolbarBackground(Palette.bg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
        .alert("ส่งการแจ้งเตือนทดสอบแล้ว", isPresented: $showTestAlert) {
            Button("ตกลง", role: .cancel) {}
        } message: {
            Text("การแจ้งเตือนจะปรากฏภายใน 5 วินาที")
        }
        .alert("ลบรายการทั้งหมด?", isPresented: $showDeleteAllConfirm) {
            Button("ยกเลิก", role: .cancel) {}
            Button("ลบทั้งหมด", role: .destructive) { store.deleteAll() }
        } message: {
            Text("การแจ้งเตือนทั้งหมดที่ตั้งไว้จะถูกยกเลิกด้วย")
        }
    }

    // MARK: - Sections

    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("การแจ้งเตือน")

            HStack(spacing: 10) {
                Image(systemName: notifications.isDenied ? "bell.slash.fill" : "bell.fill")
                    .foregroundColor(notifications.isDenied ? Palette.red : Palette.accent)
                    .frame(width: 22)
                Text(notifications.isDenied ? "การแจ้งเตือนถูกปิดอยู่" : "การแจ้งเตือนเปิดอยู่")
                    .font(.system(size: 15))
                    .foregroundColor(Palette.ink)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(RoundedRectangle(cornerRadius: 13).fill(Palette.card))
            .overlay(RoundedRectangle(cornerRadius: 13).stroke(Palette.line))

            settingsButton(icon: "gearshape", title: "เปิดการตั้งค่าระบบ") {
                openSystemSettings()
            }

            settingsButton(icon: "bell.badge", title: "ทดสอบแจ้งเตือน") {
                notifications.sendTestNotification()
                showTestAlert = true
            }
        }
    }

    private var dataSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("ข้อมูล")

            settingsButton(icon: "trash", title: "ลบรายการทั้งหมด", tint: Palette.red) {
                showDeleteAllConfirm = true
            }
        }
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("เกี่ยวกับแอป")

            VStack(alignment: .leading, spacing: 4) {
                Text("DailyBell")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Palette.ink)
                Text("เวอร์ชัน \(appVersion)")
                    .font(.system(size: 12))
                    .foregroundColor(Palette.muted)
                Text("แอปเตือนความจำรายวัน เก็บข้อมูลไว้ในเครื่องเท่านั้น")
                    .font(.system(size: 12))
                    .foregroundColor(Palette.muted)
                    .padding(.top, 2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 13).fill(Palette.card))
            .overlay(RoundedRectangle(cornerRadius: 13).stroke(Palette.line))
        }
    }

    // MARK: - Helpers

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .tracking(0.8)
            .textCase(.uppercase)
            .foregroundColor(Palette.muted)
            .padding(.leading, 4)
    }

    private func settingsButton(
        icon: String,
        title: String,
        tint: Color = Palette.accent,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundColor(tint)
                    .frame(width: 22)
                Text(title)
                    .font(.system(size: 15))
                    .foregroundColor(Palette.ink)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Palette.muted)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(RoundedRectangle(cornerRadius: 13).fill(Palette.card))
            .overlay(RoundedRectangle(cornerRadius: 13).stroke(Palette.line))
        }
        .buttonStyle(.plain)
    }

    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
