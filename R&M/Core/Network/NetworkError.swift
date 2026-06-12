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
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .decodingFailed(let error):
            return "Decoding failed: \(error.localizedDescription)"
        case .serverError(let code):
            return "Server error: \(code)"
        case .unknown(let error):
            return error.localizedDescription
        }
    }

    func localizedMessage(lang: LanguageManager) -> String {
        switch self {
        case .invalidURL:
            return lang.localized(LocalizationKeys.Network.invalidUrl)
        case .decodingFailed(let error):
            return lang.localized(LocalizationKeys.Network.decodingFormat, error.localizedDescription)
        case .serverError(let code):
            return lang.localized(LocalizationKeys.Network.serverFormat, code)
        case .unknown(let error):
            return error.localizedDescription
        }
    }

    var isRetryable: Bool {
        switch self {
        case .serverError(let code): !(400..<500).contains(code)
        case .decodingFailed, .invalidURL: false
        case .unknown: true
        }
    }
}
