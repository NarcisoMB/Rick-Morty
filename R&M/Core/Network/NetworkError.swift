//
//  NetworkError.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case decodingFailed(Error)
    case serverError(Int)
    case unknown(Error)

    var errorDescription: String? {
        let lang = LanguageManager.shared
        switch self {
        case .invalidURL:
            return lang.localized(LocalizationKeys.Network.invalidUrl)
        case .decodingFailed(let e):
            return lang.localized(LocalizationKeys.Network.decodingFormat, e.localizedDescription)
        case .serverError(let code):
            return lang.localized(LocalizationKeys.Network.serverFormat, code)
        case .unknown(let e):
            return e.localizedDescription
        }
    }

    // 4xx y decodificación no se recuperan con reintentos
    var isRetryable: Bool {
        switch self {
        case .serverError(let code): !(400..<500).contains(code)
        case .decodingFailed, .invalidURL: false
        case .unknown: true
        }
    }
}
