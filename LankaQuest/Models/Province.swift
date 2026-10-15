//
//  Province.swift
//  LankaQuest
//

import Foundation

/// A stop on the race route. `x` and `y` are positions on the map from 0 to 1.
struct Province: Identifiable, Hashable {
    let name: String
    let landmark: String
    let x: CGFloat
    let y: CGFloat

    var id: String { name }

    /// The race route: from Colombo in the west, round the south and east, up to Jaffna in the north.
    static let route: [Province] = [
        Province(name: "Western", landmark: "Colombo, the busy capital port", x: 0.24, y: 0.66),
        Province(name: "Sabaragamuwa", landmark: "Ratnapura, the City of Gems", x: 0.42, y: 0.68),
        Province(name: "Southern", landmark: "Galle Fort and golden beaches", x: 0.50, y: 0.88),
        Province(name: "Uva", landmark: "Ella and the Nine Arches Bridge", x: 0.66, y: 0.68),
        Province(name: "Eastern", landmark: "Trincomalee's natural harbour", x: 0.74, y: 0.44),
        Province(name: "Central", landmark: "Kandy and the Temple of the Tooth", x: 0.50, y: 0.54),
        Province(name: "North Western", landmark: "Kurunegala and Elephant Rock", x: 0.28, y: 0.42),
        Province(name: "North Central", landmark: "the ancient city of Anuradhapura", x: 0.50, y: 0.32),
        Province(name: "Northern", landmark: "Jaffna and the Nallur Kovil", x: 0.44, y: 0.10)
    ]
}
