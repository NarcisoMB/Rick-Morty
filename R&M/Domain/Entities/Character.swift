//
//  Character.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import Foundation

struct Character: Identifiable, Equatable, Codable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let type: String
    let gender: String
    let originName: String
    let locationName: String
    let image: URL?
    let episodes: [Int]

    var episodeCount: Int { episodes.count }
}
