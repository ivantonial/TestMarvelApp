//
//  StatCardComponent.swift
//  DesignSystem
//
//  Created by Ivan Tonial IP.TV on 10/10/25.
//

import SwiftUI

public struct StatCardComponent: View {
    public let icon: String
    public let title: String
    public let value: String
    public let color: Color

    public init(icon: String, title: String, value: String, color: Color) {
        self.icon = icon
        self.title = title
        self.value = value
        self.color = color
    }

    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(color.opacity(0.2))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)

                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

#if DEBUG
struct StatCardComponent_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            StatCardComponent(
                icon: "book.fill",
                title: "Comics",
                value: "120",
                color: .red
            )

            StatCardComponent(
                icon: "tv.fill",
                title: "Series",
                value: "45",
                color: .blue
            )
        }
        .padding()
        .background(Color.black)
    }
}
#endif
