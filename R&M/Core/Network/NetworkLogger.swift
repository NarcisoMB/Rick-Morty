//
//  NetworkLogger.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import Foundation
import OSLog

enum NetworkLogger {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "R&M",
        category: "Network"
    )

    static func logRequest(url: URL) {
        logger.debug("┌── REQUEST ──────────────────────────")
        logger.debug("│ GET \(url.absoluteString)")
        logger.debug("└─────────────────────────────────────")
    }

    static func logResponse(url: URL, statusCode: Int, data: Data) {
        let json = prettyJSON(from: data) ?? String(data: data, encoding: .utf8) ?? "<sin cuerpo>"
        logger.debug("┌── RESPONSE ─────────────────────────")
        logger.debug("│ \(statusCode) \(url.absoluteString)")
        logger.debug("│ \(json)")
        logger.debug("└─────────────────────────────────────")
    }

    static func logRetry(attempt: Int, maxRetries: Int, error: Error) {
        logger.warning("⚠ Reintento \(attempt)/\(maxRetries): \(error.localizedDescription)")
    }

    static func logError(error: Error) {
        logger.error("✗ Error final: \(error.localizedDescription)")
    }

    private static func prettyJSON(from data: Data) -> String? {
        guard
            let obj = try? JSONSerialization.jsonObject(with: data),
            let pretty = try? JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
        else { return nil }
        return String(data: pretty, encoding: .utf8)
    }
}
