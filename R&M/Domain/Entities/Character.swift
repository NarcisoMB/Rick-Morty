//
//  Character.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import Foundation

struct Character: Identifiable, Equatable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let image: URL?
}
