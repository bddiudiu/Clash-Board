//
//  TestBackendUseCase.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation

final class TestBackendUseCase {

    // MARK: - Properties

    private let repository: BackendRepositoryProtocol

    // MARK: - Initialization

    init(repository: BackendRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Execution

    func execute(backend: Backend) async throws -> Bool {
        return try await repository.testBackend(backend)
    }
}
