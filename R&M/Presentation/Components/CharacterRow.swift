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
    @State private var favoriteVM = FavoriteActionViewModel()

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
                Task { await favoriteVM.toggleFavorite(character) }
            } label: {
                Image(systemName: favoriteVM.isFavorite(character) ? "heart.fill" : "heart")
                    .foregroundStyle(favoriteVM.isFavorite(character) ? .red : .secondary)
            }
            .accessibilityIdentifier("btn_favorite")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.rmCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("character_row")
        .alert(lang.localized(LocalizationKeys.Biometric.alertTitle), isPresented: .init(
            get: { favoriteVM.showLockedAlert },
            set: { if !$0 { favoriteVM.dismissLockedAlert() } }
        )) {
            Button(lang.localized(LocalizationKeys.CharacterList.cancel), role: .cancel) {
                favoriteVM.dismissLockedAlert()
            }
        } message: {
            Text(LocalizationKeys.biometricAlertMessage(attempts: BiometricAuthManager.maxAttempts, lang: lang))
        }
    }
}
