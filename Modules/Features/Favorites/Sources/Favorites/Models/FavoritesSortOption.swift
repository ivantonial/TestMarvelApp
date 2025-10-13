//
//  FavoritesSortOption.swift
//  Favorites
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import Foundation

public enum FavoritesSortOption: String, CaseIterable {
    case dateAdded = "Date Added"
    case name = "Name"
    case mostComics = "Most Comics"

    public var title: String { rawValue }

    public var icon: String {
        switch self {
        case .dateAdded:
            return "calendar"
        case .name:
            return "textformat.abc"
        case .mostComics:
            return "book.fill"
        }
    }
}
