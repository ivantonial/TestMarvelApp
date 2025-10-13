//
//  CharacterDetailDescriptionView.swift
//  CharacterDetail
//
//  Created by Ivan Tonial IP.TV on 10/10/25.
//

import SwiftUI

struct CharacterDetailDescriptionView: View {
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ABOUT")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.red)
                .tracking(2)

            Text(description)
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
