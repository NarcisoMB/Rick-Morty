//
//  CharacterRepositoryProtocol.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

protocol CharacterRepositoryProtocol {
    func getCharacters(page: Int) async throws -> CharacterPage
}
