//
//  IslandMapView.swift
//  LankaQuest
//

import SwiftUI

/// Stylised map of Sri Lanka with the race route, glowing provinces and animated player tokens.
struct IslandMapView: View {
    let players: [Player]
    var currentPlayerID: UUID? = nil
    var showLabels = true

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            ZStack {
                ForEach(0..<3, id: \.self) { ring in
                    SriLankaShape()
                        .stroke(Color.white.opacity(0.10 - Double(ring) * 0.03), lineWidth: 2)
                        .scaleEffect(1.06 + CGFloat(ring) * 0.06)
                }

                SriLankaShape()
                    .fill(LinearGradient(colors: [Color(red: 0.40, green: 0.74, blue: 0.42),
                                                  Color.lqLand,
                                                  Color(red: 0.12, green: 0.38, blue: 0.22)],
                                         startPoint: .top, endPoint: .bottom))
                    .shadow(color: .black.opacity(0.5), radius: 30, y: 20)

                SriLankaShape()
                    .stroke(Color.white.opacity(0.6), lineWidth: 3)

                RoutePath()
                    .stroke(Color.lqGold.opacity(0.85),
                            style: StrokeStyle(lineWidth: 5, lineCap: .round, dash: [12, 12]))

                ForEach(Array(Province.route.enumerated()), id: \.element.id) { index, province in
                    ProvinceMarker(name: province.name,
                                   isFinish: index == GameEngine.finishPosition,
                                   isReached: players.contains { $0.position >= index },
                                   showLabel: showLabels)
                        .position(x: province.x * size.width, y: province.y * size.height)
                }

                ForEach(Array(players.enumerated()), id: \.element.id) { index, player in
                    let province = Province.route[player.position]
                    ZStack {
                        if player.id == currentPlayerID {
                            PulseRing()
                                .frame(width: 60, height: 60)
                        }
                        AvatarBadge(avatar: player.avatar, size: 56)
                    }
                    .offset(tokenOffset(index: index))
                    .position(x: province.x * size.width, y: province.y * size.height)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6), value: player.position)
                }
            }
        }
        .aspectRatio(0.62, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(players.isEmpty
            ? "Map of Sri Lanka"
            : players.map { "\($0.name) at \(Province.route[$0.position].name)" }.joined(separator: ", "))
    }

    /// Spreads tokens around a province so players on the same spot don't overlap.
    private func tokenOffset(index: Int) -> CGSize {
        let offsets = [CGSize(width: -28, height: -36), CGSize(width: 28, height: -36),
                       CGSize(width: -28, height: 32), CGSize(width: 28, height: 32)]
        return offsets[index % offsets.count]
    }
}

/// A simplified teardrop outline of the island, drawn in code.
struct SriLankaShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        path.move(to: CGPoint(x: 0.40 * w, y: 0.02 * h))
        path.addCurve(to: CGPoint(x: 0.90 * w, y: 0.55 * h),
                      control1: CGPoint(x: 0.62 * w, y: 0.12 * h),
                      control2: CGPoint(x: 0.92 * w, y: 0.32 * h))
        path.addCurve(to: CGPoint(x: 0.50 * w, y: 0.98 * h),
                      control1: CGPoint(x: 0.88 * w, y: 0.80 * h),
                      control2: CGPoint(x: 0.70 * w, y: 0.98 * h))
        path.addCurve(to: CGPoint(x: 0.10 * w, y: 0.62 * h),
                      control1: CGPoint(x: 0.28 * w, y: 0.98 * h),
                      control2: CGPoint(x: 0.08 * w, y: 0.82 * h))
        path.addCurve(to: CGPoint(x: 0.40 * w, y: 0.02 * h),
                      control1: CGPoint(x: 0.12 * w, y: 0.38 * h),
                      control2: CGPoint(x: 0.28 * w, y: 0.12 * h))
        path.closeSubpath()
        return path
    }
}

/// Dashed line joining the provinces in race order.
struct RoutePath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        for (index, province) in Province.route.enumerated() {
            let point = CGPoint(x: province.x * rect.width, y: province.y * rect.height)
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        return path
    }
}

/// A dot and label for one province. Reached provinces glow gold; the finish has a flag.
struct ProvinceMarker: View {
    let name: String
    let isFinish: Bool
    var isReached = false
    var showLabel = true

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                if isFinish {
                    Circle()
                        .fill(Color.lqGold)
                        .frame(width: 46, height: 46)
                        .shadow(color: Color.lqGold, radius: 12)
                    Image(systemName: "flag.checkered")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.black)
                } else {
                    Circle()
                        .fill(isReached ? Color.lqGold : Color.white)
                        .frame(width: 20, height: 20)
                        .shadow(color: isReached ? Color.lqGold : Color.clear, radius: 8)
                }
            }
            if showLabel {
                Text(name)
                    .font(.caption2.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.black.opacity(0.45), in: Capsule())
            }
        }
    }
}
