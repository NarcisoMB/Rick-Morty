//
//  LocalizationKeys.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import Foundation

enum LocalizationKeys {
	
	enum CharacterList {
		static let loading = "characterList_loading"
		static let connectionError = "characterList_connectionError"
		static let retry = "characterList_retry"
		static let cancel = "characterList_cancel"
		static let searchPlaceholder = "characterList_searchPlaceholder"
		static let subtitle = "characterList_subtitle"
		static let retryingFormat = "characterList_retryingFormat"
		static let pageIndicatorFormat = "characterList_pageIndicatorFormat"
	}
	
	enum Tab {
		static let characters = "tab_characters"
		static let favorites = "tab_favorites"
	}
	
	enum Favorites {
		static let subtitle = "favorites_subtitle"
		static let emptyTitle = "favorites_emptyTitle"
		static let emptyDescription = "favorites_emptyDescription"
	}
	
	enum Detail {
		static let labelSpecies = "detail_labelSpecies"
		static let labelType = "detail_labelType"
		static let labelGender = "detail_labelGender"
		static let labelOrigin = "detail_labelOrigin"
		static let labelLocation = "detail_labelLocation"
		static let labelEpisodes = "detail_labelEpisodes"
	}
	
	enum Filter {
		static let sectionStatus = "filter_sectionStatus"
		static let sectionSpecies = "filter_sectionSpecies"
		static let all = "filter_all"
	}
	
	enum Network {
		static let invalidUrl = "networkError_invalidUrl"
		static let decodingFormat = "networkError_decodingFormat"
		static let serverFormat = "networkError_serverFormat"
	}
	
	// MARK: - Helpers con formato
	
	static func retrying(attempt: Int, of max: Int, lang: LanguageManager = .shared) -> String {
		lang.localized(CharacterList.retryingFormat, attempt, max)
	}
	
	static func pageIndicator(current: Int, total: Int, lang: LanguageManager = .shared) -> String {
		lang.localized(CharacterList.pageIndicatorFormat, current, total)
	}
}
