//
//  CharacterListSheet.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import SwiftUI

struct CharacterListSheet: View {
    let annotations: [CharacterAnnotation]
    let isLoading: Bool
    @Binding var isExpanded: Bool
    @Binding var liveOffset: CGFloat
    let onMinimize: () -> Void
    let onFocus: (CharacterAnnotation) -> Void

    @Environment(LanguageManager.self) private var lang

    var body: some View {
        VStack(spacing: 0) {
            handle
            header
            Divider().background(Color.white.opacity(0.08))
            content
        }
        .background(Color.rmBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.35), radius: 12, y: -4)
        .colorScheme(.dark)
    }

    private var handle: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color.white.opacity(0.3))
            .frame(width: 36, height: 5)
            .padding(.top, 10)
            .padding(.bottom, 6)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    isExpanded.toggle()
                }
            }
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onChanged { value in
                        liveOffset = value.translation.height
                    }
                    .onEnded { value in
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            liveOffset = 0
                            if value.translation.height > 50 {
                                if isExpanded {
                                    isExpanded = false
                                } else {
                                    onMinimize()
                                }
                            } else if value.translation.height < -50 {
                                isExpanded = true
                            }
                        }
                    }
            )
    }

    private var header: some View {
        HStack {
            Text(lang.localized(LocalizationKeys.Tab.characters))
                .font(.title2).bold()
                .foregroundStyle(.white)
            Spacer()
            if !isLoading {
                Text("\(annotations.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }

    @ViewBuilder
    private var content: some View {
        if isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(annotations) { annotation in
                        Button {
                            onFocus(annotation)
                        } label: {
                            CharacterMapRow(annotation: annotation)
                        }
                        .buttonStyle(.plain)

                        if annotation.id != annotations.last?.id {
                            Divider()
                                .padding(.leading, 82)
                                .background(Color.white.opacity(0.06))
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

private struct CharacterMapRow: View {
    let annotation: CharacterAnnotation

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .strokeBorder(annotation.character.statusColor, lineWidth: 2.5)
                    .frame(width: 52, height: 52)
                CachedAsyncImage(url: annotation.character.image) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 47, height: 47)
                .clipShape(Circle())
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(annotation.character.name)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text("\(annotation.character.locationName) · \(annotation.character.species)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 10)
    }
}
