//
//  Coordinator.swift
//  Core
//
//  Created by Ivan Tonial IP.TV on 07/10/25.
//

import SwiftUI

/// Protocolo base para implementação do padrão Coordinator
public protocol Coordinator: AnyObject {
    associatedtype Route

    func navigate(to route: Route)
    func start() -> AnyView
}

/// Protocolo para coordenadores filhos
public protocol ChildCoordinator: Coordinator {
    var parent: (any Coordinator)? { get set }
}

/// Enum base para rotas de navegação
public protocol NavigationRoute {
    associatedtype Destination: View
    func destination() -> Destination
}
