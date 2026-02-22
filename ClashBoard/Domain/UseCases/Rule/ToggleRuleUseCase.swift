//
//  ToggleRuleUseCase.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation

final class ToggleRuleUseCase {

    // MARK: - Properties

    private let repository: RuleRepositoryProtocol

    // MARK: - Initialization

    init(repository: RuleRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Execution

    func execute(index: Int, disabled: Bool) async throws {
        try await repository.toggleRule(index: index, disabled: disabled)
    }
}
