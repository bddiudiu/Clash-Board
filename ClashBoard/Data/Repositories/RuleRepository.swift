//
//  RuleRepository.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation
import Combine

final class RuleRepository: RuleRepositoryProtocol {

    // MARK: - Properties

    private let remoteDataSource: RuleRemoteDataSource

    // MARK: - Initialization

    init(remoteDataSource: RuleRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    // MARK: - Public Methods

    func fetchRules() async throws -> [Rule] {
        return try await remoteDataSource.fetchRules()
    }

    func toggleRule(index: Int, disabled: Bool) async throws {
        try await remoteDataSource.toggleRule(index: index, disabled: disabled)
    }

    func fetchRuleProviders() async throws -> [RuleProvider] {
        return try await remoteDataSource.fetchRuleProviders()
    }

    func updateRuleProvider(name: String) async throws {
        try await remoteDataSource.updateRuleProvider(name: name)
    }
}
