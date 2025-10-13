//
//  SearchFilter.swift
//  Search
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import Foundation
import SwiftUI

public enum SearchFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case heroes = "Heroes"
    case villains = "Villains"
    case teams = "Teams"

    public var id: String { rawValue }

    public var title: String { rawValue }

    public var icon: String {
        switch self {
        case .all: return "person.3.fill"
        case .heroes: return "person.fill.badge.plus"
        case .villains: return "person.fill.xmark"
        case .teams: return "person.3.sequence.fill"
        }
    }
}
