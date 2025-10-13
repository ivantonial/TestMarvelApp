//
//  ShareSheetComponent.swift
//  DesignSystem
//
//  Created by Ivan Tonial IP.TV on 10/10/25.
//

import SwiftUI
import UIKit

/// Componente para exibir o sheet nativo de compartilhamento
public struct ShareSheetComponent: UIViewControllerRepresentable {
    // MARK: - Properties
    public let items: [Any]
    public let excludedActivityTypes: [UIActivity.ActivityType]?

    // MARK: - Initialization
    public init(
        items: [Any],
        excludedActivityTypes: [UIActivity.ActivityType]? = nil
    ) {
        self.items = items
        self.excludedActivityTypes = excludedActivityTypes
    }

    // MARK: - UIViewControllerRepresentable
    public func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        controller.excludedActivityTypes = excludedActivityTypes
        return controller
    }

    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
}
