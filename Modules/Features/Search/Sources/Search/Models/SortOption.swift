//
//  SortOption.swift
//  Search
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import Foundation
import SwiftUI

public enum SortOption: String, CaseIterable, Identifiable {
    case name = "Name"
    case popularity = "Popularity"
    case recent = "Recent"

    public var id: String { rawValue }

    public var title: String { rawValue }

    public var icon: String {
        switch self {
        case .name: return "textformat.abc"
        case .popularity: return "star.fill"
        case .recent: return "clock.fill"
        }
    }
}
