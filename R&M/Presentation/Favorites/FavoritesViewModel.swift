//
//  FavoritesViewModel.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import Observation

@Observable
final class FavoritesViewModel {
    private(set) var isUnlocked = false

    private var authTask: Task<Void, Never>?
    private let biometricAuth: BiometricAuthManager
    private let lang: LanguageManager

    init(
        biometricAuth: BiometricAuthManager = .shared,
        lang: LanguageManager = .shared
    ) {
        self.biometricAuth = biometricAuth
        self.lang = lang
    }

    func onTabSelected(_ selected: Bool) {
        if selected {
            self.authTask?.cancel()
            self.authTask = Task { await self.attemptUnlock() }
        } else {
            self.authTask?.cancel()
            self.authTask = nil
            self.isUnlocked = false
        }
    }

    func retryUnlock() {
        self.authTask?.cancel()
        self.authTask = Task { await self.attemptUnlock() }
    }

    private func attemptUnlock() async {
        switch ProcessInfo.processInfo.environment["UI_TESTING_BYPASS_AUTH"] {
        case "1": self.isUnlocked = true; return
        case "0": return
        default: break
        }
        let reason = self.lang.localized(LocalizationKeys.Favorites.authReason)
        let result = await self.biometricAuth.authenticate(reason: reason)
        guard !Task.isCancelled else { return }
        self.isUnlocked = result
    }
}
