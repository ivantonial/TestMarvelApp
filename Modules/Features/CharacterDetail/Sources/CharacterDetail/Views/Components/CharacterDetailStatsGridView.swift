//
//  CharacterDetailStatsGridView.swift
//  CharacterDetail
//
//  Created by Ivan Tonial IP.TV on 10/10/25.
//

import DesignSystem
import SwiftUI

struct CharacterDetailStatsGridView: View {
    let stats: CharacterStatsModel

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(stats.allStats) { stat in
                StatCardComponent(
                    icon: stat.icon,
                    title: stat.title,
                    value: stat.displayValue,
                    color: stat.color.swiftUIColor
                )
            }
        }
    }
}
