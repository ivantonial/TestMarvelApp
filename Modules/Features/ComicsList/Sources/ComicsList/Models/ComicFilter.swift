//
//  ComicFilter.swift
//  ComicsList
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import Foundation

public enum ComicFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case recent = "Recent"
    case popular = "Popular"
    case classic = "Classic"

    public var id: String { rawValue }

    public var title: String { rawValue }
}
