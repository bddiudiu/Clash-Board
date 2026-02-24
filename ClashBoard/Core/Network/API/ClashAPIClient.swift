//
//  ClashAPIClient.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation
import Combine

protocol APIClientProtocol {
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
    func requestRaw(_ endpoint: APIEndpoint) async throws -> Data
    func configure(baseURL: URL, secret: String?)
}

final class ClashAPIClient: APIClientProtocol {

    // MARK: - Properties

    private var baseURL: URL?
    private var secret: String?
    private let session: URLSession
    private let decoder: JSONDecoder

    // MARK: - Initialization

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - Configuration

    func configure(baseURL: URL, secret: String?) {
        self.baseURL = baseURL
        self.secret = secret
    }

    // MARK: - Public Methods

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let data = try await requestRaw(endpoint)
        // 对于空响应体，尝试直接返回 EmptyResponse
        if data.isEmpty, let empty = EmptyResponse() as? T {
            return empty
        }
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }

    func requestRaw(_ endpoint: APIEndpoint) async throws -> Data {
        guard let baseURL = baseURL else {
            throw NetworkError.notConfigured
        }

        let request = try buildRequest(for: endpoint, baseURL: baseURL)

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            switch httpResponse.statusCode {
            case 200..<300:
                return data
            case 401:
                throw NetworkError.unauthorized
            case 404:
                throw NetworkError.notFound
            case 500..<600:
                throw NetworkError.serverError(httpResponse.statusCode)
            default:
                throw NetworkError.unexpectedStatusCode(httpResponse.statusCode)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }

    // MARK: - Private Methods

    private func buildRequest(for endpoint: APIEndpoint, baseURL: URL) throws -> URLRequest {
        var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: false)

        if let queryItems = endpoint.queryItems {
            components?.queryItems = queryItems
        }

        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let secret = secret, !secret.isEmpty {
            request.setValue("Bearer \(secret)", forHTTPHeaderField: "Authorization")
        }

        if let body = endpoint.body {
            request.httpBody = body
        }

        request.timeoutInterval = 30

        return request
    }
}

// Mihomo exposes a Clash-compatible control API. Keep a Mihomo-first alias.
typealias MihomoAPIClient = ClashAPIClient
