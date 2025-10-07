//
//  MarvelApp.swift
//  MarvelApp
//
//  Created by Ivan Tonial IP.TV on 07/10/25.
//

import SwiftUI
import AppCoordinator

@main
struct MarvelApp: App {
    @StateObject private var coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            coordinator.start()
                .preferredColorScheme(.dark)
        }
    }
}
