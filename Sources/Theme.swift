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

/// Dark, premium-minimal palette: black/charcoal surfaces, one gold accent.
enum Palette {
    static let bg       = Color(hex: 0x0C0C10)
    static let card     = Color(hex: 0x16161B)
    static let ink      = Color(hex: 0xECEAE4)
    static let ink2     = Color(hex: 0xA6A39C)
    static let muted    = Color(hex: 0x6C6964)
    static let gold     = Color(hex: 0xD9A441)
    static let goldSoft = Color(hex: 0xE8C272)
    static let red      = Color(hex: 0x9C443B)
    static let line     = Color.white.opacity(0.08)
    static let onGold   = Color(hex: 0x1A1407)
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
                .foregroundColor(Palette.gold)
                .frame(width: 22)
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(Palette.ink)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Palette.gold)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 13).fill(Palette.card))
        .overlay(RoundedRectangle(cornerRadius: 13).stroke(Palette.line))
    }
}
