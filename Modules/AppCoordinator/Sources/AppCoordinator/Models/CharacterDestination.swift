//
//  CharacterDestination.swift
//  AppCoordinator
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import Foundation
import MarvelAPI

/// Destinos de navegação controlados pelo AppCoordinator
public enum CharacterDestination: Hashable {
    case detail(Character)
    case comics(Character)
}
