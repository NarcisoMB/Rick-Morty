//
//  MapNavigationManager.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import Observation

@Observable final class MapNavigationManager {
    static let shared = MapNavigationManager()
    private init() {}
    var pendingCharacter: Character?
}
