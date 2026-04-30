import SwiftUI

/// VannaQ-inspired design system — dark navy + vivid green accent.
/// All colors should flow through here so we have one source of truth.
public enum Theme {
    // MARK: - Colors
    public static let bg          = Color(hex: 0x0A0F1C)
    public static let bg2         = Color(hex: 0x10162A)
    public static let cardBg      = Color.white.opacity(0.04)
    public static let cardBgHover = Color.white.opacity(0.06)
    public static let line        = Color.white.opacity(0.08)
    public static let lineStrong  = Color.white.opacity(0.14)

    public static let ink         = Color(hex: 0xF5F5F7)
    public static let inkSoft     = Color(hex: 0xC8CCD6)
    public static let mute        = Color(hex: 0x6E7484)

    public static let accent      = Color(hex: 0x00C805)       // signature green
    public static let accentSoft  = Color(red: 0/255, green: 200/255, blue: 5/255, opacity: 0.16)
    public static let accentGlow  = Color(red: 0/255, green: 200/255, blue: 5/255, opacity: 0.5)

    public static let warn        = Color(hex: 0xFFB02E)
    public static let danger      = Color(hex: 0xFF453A)
    public static let purple      = Color(hex: 0x8B5CF6)

    // MARK: - Fonts (use system font but apply tight tracking like Inter)
    public static func display(_ size: CGFloat) -> Font {
        .system(size: size, weight: .heavy, design: .rounded)
    }
    public static func headline(_ size: CGFloat = 17) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
    public static func mono(_ size: CGFloat = 13) -> Font {
        .system(size: size, weight: .medium, design: .monospaced)
    }
    public static let eyebrow: Font = .system(size: 10, weight: .bold, design: .default)
    public static let bodyText: Font = .system(size: 14, weight: .regular)
    public static let caption: Font = .system(size: 12, weight: .regular)
}

extension Color {
    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1.0)
    }
}

// MARK: - View modifiers

extension View {
    /// Standard card surface — translucent panel with subtle hairline border.
    func vqCard(padding: CGFloat = 16) -> some View {
        self
            .padding(padding)
            .background(Theme.cardBg)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Theme.line, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    /// Pill-shaped eyebrow label (small uppercase tracker above stats).
    func vqEyebrow(color: Color = Theme.mute) -> some View {
        self
            .font(Theme.eyebrow)
            .tracking(1.2)
            .textCase(.uppercase)
            .foregroundStyle(color)
    }
}

/// Status pill: small tag with colored background, used everywhere.
struct VQTag: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(Theme.eyebrow)
            .tracking(1.0)
            .textCase(.uppercase)
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
            .overlay(
                Capsule().strokeBorder(color.opacity(0.3), lineWidth: 1)
            )
    }
}

/// Pulsing dot — for "live" indicators.
struct VQPulseDot: View {
    let color: Color
    @State private var phase: CGFloat = 0

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 7, height: 7)
            .overlay(
                Circle()
                    .stroke(color.opacity(0.5 - 0.5 * phase), lineWidth: 2)
                    .scaleEffect(1 + phase * 1.4)
            )
            .onAppear {
                withAnimation(.easeOut(duration: 1.6).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}
