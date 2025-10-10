//
//  ShareSheetView.swift
//  Settings
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import SwiftUI
import UIKit

public struct ShareSheetView: UIViewControllerRepresentable {
    let items: [Any]

    public init(items: [Any]) {
        self.items = items
    }

    public func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
