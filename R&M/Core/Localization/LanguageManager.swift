//
//  LanguageManager.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import Foundation
import Observation

@Observable
final class LanguageManager {
    static let shared = LanguageManager()

    private(set) var language: String {
        didSet { UserDefaults.standard.set(language, forKey: "app_language") }
    }

    private init() {
        language = UserDefaults.standard.string(forKey: "app_language")
            ?? Locale.current.language.languageCode?.identifier
            ?? "en"
    }

    func setLanguage(_ code: String) {
        language = code
    }

    func localized(_ key: String) -> String {
        guard
            let path = Bundle.main.path(forResource: language, ofType: "lproj"),
            let bundle = Bundle(path: path)
        else {
            return NSLocalizedString(key, comment: "")
        }
        return NSLocalizedString(key, bundle: bundle, comment: "")
    }

    func localized(_ key: String, _ args: CVarArg...) -> String {
        String(format: localized(key), arguments: args)
    }
}
