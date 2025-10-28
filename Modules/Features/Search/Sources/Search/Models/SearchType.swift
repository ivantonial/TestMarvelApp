//
//  SearchType.swift
//  Search
//
//  Created by Ivan Tonial IP.TV on 13/10/25.
//

import Foundation
import SwiftUI

public enum SearchType: String, CaseIterable, Identifiable {
    case characters = "Characters"
    case comics = "Comics"

    public var id: String { rawValue }

    public var icon: String {
        switch self {
        case .characters: return "person.3.fill"
        case .comics: return "book.fill"
        }
    }
}
