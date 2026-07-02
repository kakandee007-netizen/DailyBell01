import SwiftUI

extension Color {
    init(hex: UInt) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}

/// Dark blue, clean palette: navy surfaces, one blue accent.
enum Palette {
    static let bg          = Color(hex: 0x0A0E1A)
    static let card        = Color(hex: 0x121A2C)
    static let ink         = Color(hex: 0xEDEFF5)
    static let ink2        = Color(hex: 0xA8B0C3)
    static let muted       = Color(hex: 0x5B6478)
    static let accent      = Color(hex: 0x4C8DFF)
    static let accentSoft  = Color(hex: 0x8AB4FF)
    static let red         = Color(hex: 0xE0554F)
    static let line        = Color.white.opacity(0.08)
    static let onAccent    = Color(hex: 0x061022)
}

/// A labelled input card used in the add / edit forms.
struct FormField<Content: View>: View {
    let label: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .tracking(0.8)
                .textCase(.uppercase)
                .foregroundColor(Palette.muted)
                .padding(.leading, 4)
            content
                .padding(.horizontal, 14)
                .padding(.vertical, 13)
                .background(RoundedRectangle(cornerRadius: 13).fill(Palette.card))
                .overlay(RoundedRectangle(cornerRadius: 13).stroke(Palette.line))
        }
    }
}

/// A settings toggle row (notification / repeat daily).
struct ToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(Palette.accent)
                .frame(width: 22)
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(Palette.ink)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Palette.accent)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 13).fill(Palette.card))
        .overlay(RoundedRectangle(cornerRadius: 13).stroke(Palette.line))
    }
}
