//
//  ConfigRemoteDataSource.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation

final class ConfigRemoteDataSource {

    // MARK: - Properties

    private let apiClient: APIClientProtocol

    // MARK: - Initialization

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    // MARK: - Public Methods

    func fetchConfig() async throws -> ClashConfig {
        return try await apiClient.request(.getConfig)
    }

    func updateConfig(_ config: [String: Any]) async throws {
        let _: EmptyResponse = try await apiClient.request(.patchConfig(data: config))
    }

    func reloadConfig(path: String, payload: String) async throws {
        let _: EmptyResponse = try await apiClient.request(.reloadConfig(path: path, payload: payload))
    }
}
