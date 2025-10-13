//
//  APIStatus.swift
//  Settings
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import SwiftUI

public enum APIStatus {
    case online
    case offline
    case checking

    public var color: Color {
        switch self {
        case .online: return .green
        case .offline: return .red
        case .checking: return .yellow
        }
    }

    public var text: String {
        switch self {
        case .online: return "Connected"
        case .offline: return "Disconnected"
        case .checking: return "Checking..."
        }
    }
}
