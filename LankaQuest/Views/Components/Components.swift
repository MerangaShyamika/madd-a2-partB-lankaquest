//
//  Components.swift
//  LankaQuest
//
//  Reusable building blocks for the LankaQuest look:
//  animated background, glass cards, gold focus buttons, title text and badges.
//

import SwiftUI

/// Soft colour glows that drift slowly behind every screen.
struct AnimatedBackground: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                ZStack {
                    LinearGradient(colors: [Color(red: 0.03, green: 0.18, blue: 0.30),
                                            Color(red: 0.01, green: 0.05, blue: 0.10)],
                                   startPoint: .top, endPoint: .bottom)
                    glow(Color.lqSea.opacity(0.9), size: 1100)
                        .position(x: w * (0.6 + 0.1 * sin(t / 10)), y: h * (0.3 + 0.08 * sin(t / 11)))
                    glow(Color.lqGold.opacity(0.28), size: 900)
                        .position(x: w * (0.2 + 0.08 * sin(t / 7)), y: h * (0.25 + 0.06 * cos(t / 9)))
                    glow(Color.lqMaroon.opacity(0.6), size: 1100)
                        .position(x: w * (0.85 + 0.06 * cos(t / 8)), y: h * (0.85 + 0.05 * sin(t / 6)))
                }
            }
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }

    private func glow(_ color: Color, size: CGFloat) -> some View {
        Circle()
            .fill(RadialGradient(colors: [color, color.opacity(0)], center: .center,
                                 startRadius: 0, endRadius: size / 2))
            .frame(width: size, height: size)
    }
}

/// Frosted glass panel with a thin border (gold when highlighted).
struct GlassCard: ViewModifier {
    var highlighted = false

    func body(content: Content) -> some View {
        content
            .padding(28)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(highlighted ? Color.lqGold : Color.white.opacity(0.15),
                            lineWidth: highlighted ? 4 : 1.5)
            )
    }
}

extension View {
    /// Wraps the view in a LankaQuest glass panel.
    func glassCard(highlighted: Bool = false) -> some View {
        modifier(GlassCard(highlighted: highlighted))
    }
}

/// Capsule button that glows gold and grows when focused with the Siri Remote.
struct LQButtonStyle: ButtonStyle {
    var prominent = false
    var compact = false

    func makeBody(configuration: Configuration) -> some View {
        LQButtonContent(configuration: configuration, prominent: prominent, compact: compact)
    }
}

struct LQButtonContent: View {
    let configuration: ButtonStyleConfiguration
    let prominent: Bool
    let compact: Bool

    @Environment(\.isFocused) private var isFocused
    @Environment(\.isEnabled) private var isEnabled

    private var fill: AnyShapeStyle {
        if isFocused {
            return AnyShapeStyle(LinearGradient(colors: [Color(red: 1, green: 0.85, blue: 0.35), .lqGold, .orange],
                                                startPoint: .topLeading, endPoint: .bottomTrailing))
        }
        return AnyShapeStyle(prominent ? Color.lqGold.opacity(0.3) : Color.white.opacity(0.1))
    }

    var body: some View {
        configuration.label
            .font(compact ? .headline : .title3.weight(.bold))
            .foregroundStyle(isFocused ? Color.black : Color.white)
            .padding(.horizontal, compact ? 26 : 44)
            .padding(.vertical, compact ? 12 : 22)
            .background(fill, in: Capsule())
            .overlay(Capsule().stroke(Color.lqGold.opacity(isFocused ? 0 : 0.5), lineWidth: 2))
            .scaleEffect(configuration.isPressed ? 0.95 : (isFocused ? 1.08 : 1.0))
            .shadow(color: isFocused ? Color.lqGold.opacity(0.55) : .clear, radius: 24, y: 10)
            .opacity(isEnabled ? 1 : 0.35)
            .animation(.spring(duration: 0.25), value: isFocused)
            .animation(.spring(duration: 0.15), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == LQButtonStyle {
    static var lq: LQButtonStyle { LQButtonStyle() }
    static var lqProminent: LQButtonStyle { LQButtonStyle(prominent: true) }
    static var lqCompact: LQButtonStyle { LQButtonStyle(compact: true) }
}

/// Big rounded title with a gold gradient.
struct GradientTitle: View {
    let text: String
    var size: CGFloat = 90

    var body: some View {
        Text(text)
            .font(.system(size: size, weight: .black, design: .rounded))
            .foregroundStyle(LinearGradient(colors: [Color(red: 1, green: 0.9, blue: 0.5), .lqGold, .orange],
                                            startPoint: .top, endPoint: .bottom))
            .shadow(color: .black.opacity(0.4), radius: 12, y: 6)
            .multilineTextAlignment(.center)
    }
}

/// Round coloured badge showing a player's avatar.
struct AvatarBadge: View {
    let avatar: Avatar
    var size: CGFloat = 60

    var body: some View {
        Image(systemName: avatar.symbol)
            .font(.system(size: size * 0.5, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(
                Circle().fill(LinearGradient(colors: [avatar.color.opacity(0.8), avatar.color],
                                             startPoint: .top, endPoint: .bottom))
            )
            .overlay(Circle().stroke(.white, lineWidth: max(2, size * 0.05)))
            .shadow(color: avatar.color.opacity(0.6), radius: size * 0.15)
            .accessibilityHidden(true)
    }
}

/// Coloured label showing a question's category.
struct CategoryChip: View {
    let category: QuestionCategory

    var body: some View {
        Label(category.rawValue, systemImage: category.icon)
            .font(.callout.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(category.color.opacity(0.85), in: Capsule())
    }
}

/// Gold ring that keeps growing and fading, used to mark the current player's token.
struct PulseRing: View {
    @State private var animate = false

    var body: some View {
        Circle()
            .stroke(Color.lqGold, lineWidth: 4)
            .scaleEffect(animate ? 1.9 : 1)
            .opacity(animate ? 0 : 0.9)
            .onAppear {
                withAnimation(.easeOut(duration: 1.2).repeatForever(autoreverses: false)) {
                    animate = true
                }
            }
            .accessibilityHidden(true)
    }
}

/// Falling confetti drawn with Canvas, used on the results screen.
struct ConfettiView: View {
    private struct Piece {
        let x: Double
        let speed: Double
        let drift: Double
        let size: Double
        let color: Color
        let spin: Double
        let delay: Double
    }

    @State private var pieces: [Piece] = ConfettiView.makePieces(count: 140)
    @State private var start = Date()

    private static func makePieces(count: Int) -> [Piece] {
        let colors: [Color] = [.lqGold, .orange, .red, .green, .blue, .pink, .white]
        return (0..<count).map { _ in
            Piece(x: Double.random(in: 0...1),
                  speed: Double.random(in: 0.08...0.2),
                  drift: Double.random(in: -0.05...0.05),
                  size: Double.random(in: 12...24),
                  color: colors.randomElement() ?? .white,
                  spin: Double.random(in: 1...4),
                  delay: Double.random(in: 0...3))
        }
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { context in
            let elapsed = context.date.timeIntervalSince(start)
            Canvas { ctx, size in
                for piece in pieces {
                    let t = elapsed - piece.delay
                    if t <= 0 { continue }
                    let y = (t * piece.speed).truncatingRemainder(dividingBy: 1.2) - 0.1
                    let x = piece.x + piece.drift * sin(t * piece.spin)
                    var pieceContext = ctx
                    pieceContext.translateBy(x: x * size.width, y: y * size.height)
                    pieceContext.rotate(by: .radians(t * piece.spin))
                    let rect = CGRect(x: -piece.size / 2, y: -piece.size / 4, width: piece.size, height: piece.size / 2)
                    pieceContext.fill(Path(rect), with: .color(piece.color))
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
