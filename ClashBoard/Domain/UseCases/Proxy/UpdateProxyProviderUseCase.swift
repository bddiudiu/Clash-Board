//
//  UpdateProxyProviderUseCase.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation

final class UpdateProxyProviderUseCase {

    // MARK: - Properties

    private let repository: ProxyRepositoryProtocol

    // MARK: - Initialization

    init(repository: ProxyRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Execution

    func execute(providerName: String) async throws {
        try await repository.updateProvider(name: providerName)
    }
}
