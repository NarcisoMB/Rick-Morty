//
//  EpisodeListView.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import SwiftUI

struct EpisodeListView: View {
    let episodeIDs: [Int]

    @Environment(LanguageManager.self) private var lang
    @State private var isExpanded = false
    @State private var episodes: [Episode] = []
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 0) {
            header
            if self.isExpanded {
                Divider().background(Color.rmBackground)
                content
            }
        }
        .background(Color.rmCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
        .animation(.easeInOut(duration: 0.2), value: self.isExpanded)
        .task { await fetchEpisodes() }
    }

    private var header: some View {
        HStack {
            Text(self.lang.localized(LocalizationKeys.Detail.labelEpisodes))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text("\(self.episodeIDs.count)")
                .font(.subheadline)
            Image(systemName: "chevron.down")
                .font(.caption)
                .rotationEffect(.degrees(self.isExpanded ? 180 : 0))
                .animation(.easeInOut(duration: 0.2), value: self.isExpanded)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .onTapGesture {
            self.isExpanded.toggle()
        }
    }
	
	@ViewBuilder
	private var content: some View {
        if isLoading {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
        } else {
            LazyVStack(spacing: 0) {
                ForEach(episodes) { episode in
                    VStack(spacing: 0) {
                        if episode.id != episodes.first?.id {
                            Divider()
                                .padding(.leading, 16)
                                .background(Color.rmBackground)
                        }
                        HStack(spacing: 12) {
                            Text(episode.code)
                                .font(.caption.monospaced())
                                .foregroundStyle(Color.accentColor)
                                .frame(width: 60, alignment: .leading)
                            Text(episode.name)
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }
                }
            }
        }
    }

    private func fetchEpisodes() async {
        guard !episodeIDs.isEmpty else { return }
        isLoading = true
        do {
            let response: EpisodeResponseDTO = try await HTTPClient().get(.episodes(ids: episodeIDs))
            episodes = response.items.map { $0.toDomain() }
        } catch {
            episodes = []
        }
        isLoading = false
    }
}
