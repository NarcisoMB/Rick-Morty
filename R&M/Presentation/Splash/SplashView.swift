//
//  SplashView.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import SwiftUI

struct SplashView: View {
    @Environment(LanguageManager.self) private var lang

    var body: some View {
        ZStack {
            Color.rmBackground.ignoresSafeArea()
            VStack(spacing: 20) {
                GIFImageView(name: "loadingPortal")
                    .frame(width: 220, height: 220)
                VStack(spacing: 4) {
                    Text("Rick & Morty")
                        .font(.largeTitle).bold()
                        .foregroundStyle(.white)
                    Text(lang.localized(LocalizationKeys.Splash.subtitle))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
        }
    }
}
