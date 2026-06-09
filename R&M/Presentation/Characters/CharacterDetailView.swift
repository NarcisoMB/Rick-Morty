//
//  CharacterDetailView.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import SwiftUI

struct CharacterDetailView: View {
	let character: Character
	
	@Environment(LanguageManager.self) private var lang
	@Environment(FavoritesManager.self) private var favorites
	@State private var contentHeight: CGFloat = 500
	
	var body: some View {
		VStack(spacing: 16) {
			CachedAsyncImage(url: self.character.image) { image in
				image.resizable().scaledToFill()
			} placeholder: {
				Color.gray.opacity(0.3)
			}
			.frame(width: 140, height: 140)
			.clipShape(Circle())
			.padding(.top, 8)
			
			VStack(spacing: 8) {
				Text(self.character.name)
					.font(.title2)
					.bold()
					.multilineTextAlignment(.center)
				
				HStack(spacing: 12) {
					Text(self.character.status)
						.font(.subheadline)
						.foregroundStyle(self.character.statusColor)
						.padding(.horizontal, 12)
						.padding(.vertical, 4)
						.background(self.character.statusColor.opacity(0.15))
						.clipShape(Capsule())
					
					Button {
						self.favorites.toggle(self.character)
					} label: {
						Image(systemName: self.favorites.isFavorite(character) ? "heart.fill" : "heart")
							.foregroundStyle(self.favorites.isFavorite(character) ? .red : .secondary)
							.font(.title3)
					}
				}
			}
			
			VStack(spacing: 1) {
				infoRow(
					label: self.lang.localized(LocalizationKeys.Detail.labelSpecies),
					value: self.character.species
				)
				if !character.type.isEmpty {
					infoRow(
						label: self.lang.localized(LocalizationKeys.Detail.labelType),
						value: self.character.type
					)
				}
				infoRow(
					label: self.lang.localized(LocalizationKeys.Detail.labelGender),
					value: self.character.gender
				)
				infoRow(
					label: self.lang.localized(LocalizationKeys.Detail.labelOrigin),
					value: self.character.originName
				)
				infoRow(
					label: self.lang.localized(LocalizationKeys.Detail.labelLocation),
					value: self.character.locationName
				)
				infoRow(
					label: self.lang.localized(LocalizationKeys.Detail.labelEpisodes),
					value: "\(self.character.episodeCount)"
				)
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
		.onPreferenceChange(ContentHeightKey.self) { self.contentHeight = $0 }
		.colorScheme(.dark)
		.presentationBackground(Color.rmBackground)
		.presentationDragIndicator(.visible)
		.presentationDetents([.height(self.contentHeight)])
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
