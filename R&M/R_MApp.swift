//
//  R_MApp.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import SwiftUI

@main
struct R_MApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(LanguageManager.shared)
                .environment(FavoritesManager.shared)
                .environment(BiometricAuthManager.shared)
        }
    }
}
