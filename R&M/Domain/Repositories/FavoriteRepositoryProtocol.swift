//
//  FavoriteRepositoryProtocol.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

protocol FavoriteRepositoryProtocol {
    func load() -> [Character]
    func save(_ characters: [Character])
}
