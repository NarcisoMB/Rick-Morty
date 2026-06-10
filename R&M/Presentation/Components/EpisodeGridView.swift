//
//  EpisodeGridView.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import SwiftUI

private struct TopLeftTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: rect.minX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            p.closeSubpath()
        }
    }
}

struct EpisodeGridView: View {
    let episodes: [Int]

    @Environment(WatchedEpisodesManager.self) private var watchedManager
    @Environment(ToastManager.self) private var toast
    @Environment(LanguageManager.self) private var lang
    private var episodeSet: Set<Int> { Set(episodes) }

    private static let seasons: [(label: String, range: ClosedRange<Int>)] = [
        ("S1", 1...11),
        ("S2", 12...21),
        ("S3", 22...31),
        ("S4", 32...41),
        ("S5", 42...51),
        ("S6", 52...61),
        ("S7", 62...71),
    ]

    private var visibleSeasons: [(label: String, range: ClosedRange<Int>)] {
        let maxEp = episodes.max() ?? 0
        return Self.seasons.filter { $0.range.lowerBound <= maxEp }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(self.visibleSeasons, id: \.label) { season in
                seasonRow(season)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.rmCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
    }

    private func seasonRow(_ season: (label: String, range: ClosedRange<Int>)) -> some View {
        HStack(spacing: 3) {
            Text(season.label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 22, alignment: .leading)

            ForEach(Array(season.range), id: \.self) { ep in
                let active = self.episodeSet.contains(ep)
                let watched = self.watchedManager.isWatched(ep)
                let label = ep - season.range.lowerBound + 1
                ZStack {
                    if active && watched {
                        RoundedRectangle(cornerRadius: 4).fill(Color.green)
                        TopLeftTriangle()
                            .fill(Color.accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    } else {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(watched ? Color.green : (active ? Color.accentColor : Color.rmBackground))
                    }
                    Text("\(label)")
                        .font(.system(size: 9, weight: (active || watched) ? .bold : .regular))
                        .foregroundStyle((active || watched) ? .white : Color(.systemGray3))
                }
                .frame(width: 22, height: 22)
                .onTapGesture {
                    let wasWatched = self.watchedManager.isWatched(ep)
                    self.watchedManager.toggle(ep)
                    let key = wasWatched
                        ? LocalizationKeys.Toast.episodeUnwatchedFormat
                        : LocalizationKeys.Toast.episodeWatchedFormat
                    let msg = self.lang.localized(key, ep)
                    Task { await MainActor.run { self.toast.show(msg) } }
                }
            }
        }
    }
}
