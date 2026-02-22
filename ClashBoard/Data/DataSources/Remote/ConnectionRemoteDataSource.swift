//
//  ConnectionRemoteDataSource.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation

final class ConnectionRemoteDataSource {

    // MARK: - Properties

    private let apiClient: APIClientProtocol

    // MARK: - Initialization

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    // MARK: - Public Methods

    func fetchConnections() async throws -> ConnectionsResponse {
        let data = try await apiClient.requestRaw(.getConnections)
        return try JSONDecoder().decode(ConnectionsResponse.self, from: data)
    }

    func closeConnection(id: String) async throws {
        _ = try await apiClient.requestRaw(.closeConnection(id: id))
    }

    func closeAllConnections() async throws {
        _ = try await apiClient.requestRaw(.closeAllConnections)
    }
}

// MARK: - Response Types

struct ConnectionsResponse: Decodable {
    let connections: [Connection]
    let downloadTotal: Int64
    let uploadTotal: Int64

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        connections = try container.decodeIfPresent([Connection].self, forKey: .connections) ?? []
        downloadTotal = try container.decodeIfPresent(Int64.self, forKey: .downloadTotal) ?? 0
        uploadTotal = try container.decodeIfPresent(Int64.self, forKey: .uploadTotal) ?? 0
    }

    enum CodingKeys: String, CodingKey {
        case connections, downloadTotal, uploadTotal
    }
}
