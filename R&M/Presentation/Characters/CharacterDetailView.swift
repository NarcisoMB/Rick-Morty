//
//  CharacterDetailView.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import SwiftUI

struct CharacterDetailView: View {
    let character: Character

    @Environment(FavoritesManager.self) private var favorites
    @State private var contentHeight: CGFloat = 500

    var body: some View {
        VStack(spacing: 16) {
            CachedAsyncImage(url: character.image) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 140, height: 140)
            .clipShape(Circle())
            .padding(.top, 8)

            VStack(spacing: 8) {
                Text(character.name)
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)

                HStack(spacing: 12) {
                    Text(character.status)
                        .font(.subheadline)
                        .foregroundStyle(character.statusColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(character.statusColor.opacity(0.15))
                        .clipShape(Capsule())

                    Button {
                        favorites.toggle(character)
                    } label: {
                        Image(systemName: favorites.isFavorite(character) ? "heart.fill" : "heart")
                            .foregroundStyle(favorites.isFavorite(character) ? .red : .secondary)
                            .font(.title3)
                    }
                }
            }

            VStack(spacing: 1) {
                infoRow(label: "Species",  value: character.species)
                if !character.type.isEmpty {
                    infoRow(label: "Type",     value: character.type)
                }
                infoRow(label: "Gender",   value: character.gender)
                infoRow(label: "Origin",   value: character.originName)
                infoRow(label: "Location", value: character.locationName)
                infoRow(label: "Episodes", value: "\(character.episodeCount)")
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 16)
        .padding(.bottom, 32)
        .fixedSize(horizontal: false, vertical: true)
        .overlay(
            GeometryReader { geo in
                Color.clear
                    .preference(key: ContentHeightKey.self, value: geo.size.height)
            }
        )
        .onPreferenceChange(ContentHeightKey.self) { contentHeight = $0 }
        .colorScheme(.dark)
        .presentationBackground(Color.rmBackground)
        .presentationDragIndicator(.visible)
        .presentationDetents([.height(contentHeight)])
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.rmCard)
    }
}

private struct ContentHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
