//
//  CharacterRow.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import SwiftUI

struct CharacterRow: View {
    let character: Character
    @Environment(LanguageManager.self) private var lang
    @Environment(FavoritesManager.self) private var favorites
    @Environment(BiometricAuthManager.self) private var biometricAuth
    @Environment(ToastManager.self) private var toast

    @State private var showLockedAlert = false

    var body: some View {
        HStack(spacing: 12) {
			CachedAsyncImage(url: self.character.image) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
				Text(self.character.name)
                    .font(.headline)
				Text(self.character.species)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
				Text(self.character.status)
                    .font(.caption)
					.foregroundStyle(self.character.statusColor)
            }

            Spacer()

            Button {
				if self.favorites.isFavorite(self.character) {
					Task { await self.removeWithAuth() }
                } else {
					self.favorites.toggle(self.character)
					let msg = self.lang.localized(LocalizationKeys.Toast.addedFavoriteFormat, self.character.name)
					Task { await MainActor.run { self.toast.show(msg) } }
                }
            } label: {
				Image(systemName: self.favorites.isFavorite(self.character) ? "heart.fill" : "heart")
					.foregroundStyle(self.favorites.isFavorite(self.character) ? .red : .secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.rmCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
		.alert(self.lang.localized(LocalizationKeys.Biometric.alertTitle), isPresented: self.$showLockedAlert) {
			Button(self.lang.localized(LocalizationKeys.CharacterList.cancel), role: .cancel) {
				self.biometricAuth.resetLock()
            }
        } message: {
			Text(LocalizationKeys.biometricAlertMessage(attempts: BiometricAuthManager.maxAttempts, lang: self.lang))
        }
    }

    private func removeWithAuth() async {
        let reason = self.lang.localized(LocalizationKeys.Biometric.removeReason)
        let authorized = await self.biometricAuth.authorizeRemoval(reason: reason)
        if authorized {
            self.favorites.toggle(character)
            let msg = self.lang.localized(LocalizationKeys.Toast.removedFavoriteFormat, self.character.name)
            await MainActor.run { self.toast.show(msg) }
        } else if self.biometricAuth.isLocked {
            self.showLockedAlert = true
        }
    }
}
