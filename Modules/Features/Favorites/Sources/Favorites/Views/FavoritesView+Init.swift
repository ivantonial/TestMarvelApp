//
//  FavoritesView+Init.swift
//  Favorites
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import MarvelAPI
import SwiftUI

public extension FavoritesView {
    /// Inicializador conveniente que cria o ViewModel com o service padrão
    init(onCharacterSelected: ((Character) -> Void)? = nil) {
        let viewModel = FavoritesViewModel(favoritesService: FavoritesService.shared)
        self.init(viewModel: viewModel, onCharacterSelected: onCharacterSelected)
    }
}
