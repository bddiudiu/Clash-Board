//
//  AddBackendUseCase.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation

final class AddBackendUseCase {

    // MARK: - Properties

    private let repository: BackendRepositoryProtocol

    // MARK: - Initialization

    init(repository: BackendRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Execution

    func execute(backend: Backend) async throws {
        try await repository.addBackend(backend)
    }
}
