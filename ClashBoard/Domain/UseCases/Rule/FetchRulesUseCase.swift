//
//  FetchRulesUseCase.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation

final class FetchRulesUseCase {

    // MARK: - Properties

    private let repository: RuleRepositoryProtocol

    // MARK: - Initialization

    init(repository: RuleRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Execution

    func execute() async throws -> [Rule] {
        return try await repository.fetchRules()
    }
}
