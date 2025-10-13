//
//  Event.swift
//  MarvelAPI
//
//  Created by Ivan Tonial IP.TV on 13/10/25.
//

import Foundation

public struct EventList: Decodable, Sendable {
    public let available: Int
    public let collectionURI: String
    public let items: [EventSummary]
    public let returned: Int

    public init(available: Int, collectionURI: String, items: [EventSummary], returned: Int) {
        self.available = available
        self.collectionURI = collectionURI
        self.items = items
        self.returned = returned
    }
}

public struct EventSummary: Decodable, Sendable {
    public let resourceURI: String
    public let name: String

    public init(resourceURI: String, name: String) {
        self.resourceURI = resourceURI
        self.name = name
    }
}
