//
//  CharacterCardView.swift
//  CharacterList
//
//  Created by Ivan Tonial IP.TV on 07/10/25.
//

//import DesignSystem
//import MarvelAPI
//import SwiftUI
//
//public struct CharacterCardView: View {
//    let model: CharacterCardModel
//
//    public init(model: CharacterCardModel) {
//        self.model = model
//    }
//
//    public var body: some View {
//        ContentCardComponent(
//            model: model.toContentCardModel(),
//            onTap: nil // O tap será tratado pelo CharacterListView
//        )
//    }
//}
//
//// MARK: - Model Extension
//private extension CharacterCardModel {
//    func toContentCardModel() -> ContentCardModel {
//        ContentCardModel(
//            id: id,
//            title: name,
//            subtitle: nil,
//            imageURL: imageURL,
//            aspectRatio: 1.0, // Quadrado para personagens
//            badge: ContentCardModel.BadgeModel(
//                icon: "book.fill",
//                text: "\(comicsCount) comics",
//                color: .red
//            )
//        )
//    }
//}
import DesignSystem
import MarvelAPI
import SwiftUI

public struct CharacterCardView: View {
    let model: CharacterCardModel
    let onTap: (() -> Void)?

    public init(
        model: CharacterCardModel,
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

// MARK: - Model Extension
private extension CharacterCardModel {
    func toContentCardModel() -> ContentCardModel {
        ContentCardModel(
            id: id,
            title: name,
            subtitle: nil,
            imageURL: imageURL,
            aspectRatio: 1.0, // Quadrado para personagens
            badge: ContentCardModel.BadgeModel(
                icon: "book.fill",
                text: "\(comicsCount) comics",
                color: .red
            )
        )
    }
}
