//
//  ConfigRepository.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation
import Combine

final class ConfigRepository: ConfigRepositoryProtocol {

    // MARK: - Properties

    private let remoteDataSource: ConfigRemoteDataSource

    // MARK: - Initialization

    init(remoteDataSource: ConfigRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    // MARK: - Public Methods

    func fetchConfig() async throws -> ClashConfig {
        return try await remoteDataSource.fetchConfig()
    }

    func updateConfig(_ config: [String: Any]) async throws {
        try await remoteDataSource.updateConfig(config)
    }

    func reloadConfig(path: String, payload: String) async throws {
        try await remoteDataSource.reloadConfig(path: path, payload: payload)
    }
}
