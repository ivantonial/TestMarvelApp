//
//  ImageQuality.swift
//  Settings
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import Foundation

public enum ImageQuality: String, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"

    public var title: String {
        rawValue
    }

    public var description: String {
        switch self {
        case .low:
            return "Saves data, lower quality"
        case .medium:
            return "Balanced quality and data"
        case .high:
            return "Best quality, uses more data"
        }
    }
}
