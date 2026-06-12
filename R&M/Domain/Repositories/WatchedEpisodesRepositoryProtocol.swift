//
//  WatchedEpisodesRepositoryProtocol.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

protocol WatchedEpisodesRepositoryProtocol {
    func load() -> Set<Int>
    func save(_ episodes: Set<Int>)
}
