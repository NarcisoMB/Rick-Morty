//
//  FavoriteActionViewModel.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import Observation

@Observable
final class FavoriteActionViewModel {
    private(set) var showLockedAlert = false

    private let biometricAuth: BiometricAuthManager
    private let favorites: FavoritesManager
    private let toast: ToastManager
    private let lang: LanguageManager

    init(
        biometricAuth: BiometricAuthManager = .shared,
        favorites: FavoritesManager = .shared,
        toast: ToastManager = .shared,
        lang: LanguageManager = .shared
    ) {
        self.biometricAuth = biometricAuth
        self.favorites = favorites
        self.toast = toast
        self.lang = lang
    }

    func isFavorite(_ character: Character) -> Bool {
        self.favorites.isFavorite(character)
    }

    func toggleFavorite(_ character: Character) async {
        if self.favorites.isFavorite(character) {
            await self.removeWithAuth(character)
        } else {
            self.favorites.toggle(character)
            let msg = self.lang.localized(LocalizationKeys.Toast.addedFavoriteFormat, character.name)
            await MainActor.run { self.toast.show(msg) }
        }
    }

    func dismissLockedAlert() {
        self.showLockedAlert = false
        self.biometricAuth.resetLock()
    }

    private func removeWithAuth(_ character: Character) async {
        let reason = self.lang.localized(LocalizationKeys.Biometric.removeReason)
        let authorized = await self.biometricAuth.authorizeRemoval(reason: reason)
        if authorized {
            self.favorites.toggle(character)
            let msg = self.lang.localized(LocalizationKeys.Toast.removedFavoriteFormat, character.name)
            await MainActor.run { self.toast.show(msg) }
        } else if self.biometricAuth.isLocked {
            self.showLockedAlert = true
        }
    }
}
