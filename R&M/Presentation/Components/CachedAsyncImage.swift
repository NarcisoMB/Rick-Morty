//
//  CachedAsyncImage.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import SwiftUI

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    @ViewBuilder let content: (Image) -> Content
    @ViewBuilder let placeholder: () -> Placeholder

    @State private var uiImage: UIImage?

    var body: some View {
        ZStack {
            if let uiImage {
				self.content(Image(uiImage: uiImage))
                    .transition(.opacity.animation(.easeIn(duration: 0.25)))
            } else {
				self.placeholder()
                    .overlay(ShimmerView())
            }
        }
        .task(id: url) { await load() }
    }

    private func load() async {
        guard let url else { return }

        if let cached = ImageCache.shared.image(for: url) {
			self.uiImage = cached
            return
        }

        guard
            let (data, _) = try? await URLSession.shared.data(from: url),
            let loaded = UIImage(data: data)
        else { return }

        ImageCache.shared.store(loaded, for: url)
		self.uiImage = loaded
    }
}
