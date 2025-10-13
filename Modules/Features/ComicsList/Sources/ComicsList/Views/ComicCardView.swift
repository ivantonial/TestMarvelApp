//
//  ComicCardView.swift
//  ComicsList
//
//  Created by Ivan Tonial IP.TV on 13/10/25.
//

import DesignSystem
import MarvelAPI
import SwiftUI

public struct ComicCardView: View {
    let model: ComicCardModel
    let onTap: (() -> Void)?

    public init(
        model: ComicCardModel,
        onTap: (() -> Void)? = nil
    ) {
        self.model = model
        self.onTap = onTap
    }

    public var body: some View {
        ContentCardComponent(
            model: model.toContentCardModel(),
            onTap: onTap
        )
    }
}
