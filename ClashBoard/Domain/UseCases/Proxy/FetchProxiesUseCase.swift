//
//  FetchProxiesUseCase.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation

final class FetchProxiesUseCase {

    // MARK: - Properties

    private let repository: ProxyRepositoryProtocol

    // MARK: - Initialization

    init(repository: ProxyRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Execution

    func execute() async throws -> [ProxyGroup] {
        return try await repository.fetchProxies()
    }
}
