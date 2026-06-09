//
//  Endpoint.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import Foundation

struct Endpoint {
    let path: String
    let queryItems: [URLQueryItem]

    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "rickandmortyapi.com"
        components.path = "/api" + path
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        return components.url
    }
}

extension Endpoint {
    static func characters(page: Int = 1) -> Endpoint {
        Endpoint(path: "/character", queryItems: [URLQueryItem(name: "page", value: "\(page)")])
    }
}
