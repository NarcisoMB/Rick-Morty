//
//  CharacterRow.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import SwiftUI

struct CharacterRow: View {
    let character: Character
    @Environment(FavoritesManager.self) private var favorites

    var body: some View {
        HStack(spacing: 12) {
            CachedAsyncImage(url: character.image) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(character.name)
                    .font(.headline)
                Text(character.species)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(character.status)
                    .font(.caption)
                    .foregroundStyle(character.statusColor)
            }

            Spacer()

            Button {
                favorites.toggle(character)
            } label: {
                Image(systemName: favorites.isFavorite(character) ? "heart.fill" : "heart")
                    .foregroundStyle(favorites.isFavorite(character) ? .red : .secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.rmCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
