//
//  LocalizationKeys.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import Foundation

enum LocalizationKeys {

    enum CharacterList {
        static let loading              = "characterList_loading"
        static let connectionError      = "characterList_connectionError"
        static let retry                = "characterList_retry"
        static let cancel               = "characterList_cancel"
        static let searchPlaceholder    = "characterList_searchPlaceholder"
        static let subtitle             = "characterList_subtitle"
        static let retryingFormat       = "characterList_retryingFormat"
        static let pageIndicatorFormat  = "characterList_pageIndicatorFormat"
    }

    enum Network {
        static let invalidUrl       = "networkError_invalidUrl"
        static let decodingFormat   = "networkError_decodingFormat"
        static let serverFormat     = "networkError_serverFormat"
    }

    // MARK: - Helpers con formato

    static func retrying(attempt: Int, of max: Int, lang: LanguageManager = .shared) -> String {
        lang.localized(CharacterList.retryingFormat, attempt, max)
    }

    static func pageIndicator(current: Int, total: Int, lang: LanguageManager = .shared) -> String {
        lang.localized(CharacterList.pageIndicatorFormat, current, total)
    }
}
