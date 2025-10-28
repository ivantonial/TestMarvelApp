//
//  SearchFilter.swift
//  Search
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import Foundation
import SwiftUI

public enum SearchFilter: String, CaseIterable, Identifiable, Sendable {
    case all = "All"
    case heroes = "Heroes"
    case villains = "Villains"
    case teams = "Teams"

    // Para quadrinhos
    case ongoing = "Ongoing"
    case completed = "Completed"
    case special = "Special"

    public var id: String { rawValue }
    public var title: String { rawValue }

    public var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .heroes: return "person.fill.badge.plus"
        case .villains: return "person.fill.xmark"
        case .teams: return "person.3.sequence.fill"
        case .ongoing: return "arrow.right.circle"
        case .completed: return "checkmark.circle"
        case .special: return "star.circle"
        }
    }

    public static func filters(for type: SearchType) -> [SearchFilter] {
        switch type {
        case .characters:
            return [.all, .heroes, .villains, .teams]
        case .comics:
            return [.all, .ongoing, .completed, .special]
        }
    }
}
