//
//  HTTPClientProtocol.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import Foundation

protocol HTTPClientProtocol {
    func get<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

final class HTTPClient: HTTPClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    func get<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        guard let url = endpoint.url else { throw NetworkError.invalidURL }

        NetworkLogger.logRequest(url: url)

        let (data, response) = try await session.data(from: url)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0

        NetworkLogger.logResponse(url: url, statusCode: statusCode, data: data)

        if !(200..<300).contains(statusCode) {
            throw NetworkError.serverError(statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
}
