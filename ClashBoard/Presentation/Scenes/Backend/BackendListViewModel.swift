//
//  BackendListViewModel.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation
import Combine

final class BackendListViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var backends: [Backend] = []
    @Published private(set) var activeBackendId: UUID?
    @Published private(set) var error: Error?

    // MARK: - Private Properties

    private let storage: UserDefaultsStorageProtocol

    // MARK: - Initialization

    init(storage: UserDefaultsStorageProtocol? = nil) {
        self.storage = storage ?? DIContainer.shared.resolve(UserDefaultsStorageProtocol.self)
    }

    // MARK: - Public Methods

    func loadBackends() {
        backends = storage.load([Backend].self, for: StorageKey.backends) ?? []
        activeBackendId = storage.load(UUID.self, for: StorageKey.activeBackendId)
    }

    func selectBackend(_ backend: Backend) {
        activeBackendId = backend.id
        storage.save(backend.id, for: StorageKey.activeBackendId)

        // 通知 API 客户端切换后端
        if let url = backend.baseURL {
            let apiClient = DIContainer.shared.resolve(APIClientProtocol.self)
            apiClient.configure(baseURL: url, secret: backend.secret)
        }
    }

    func deleteBackend(_ backend: Backend) {
        backends.removeAll { $0.id == backend.id }
        storage.save(backends, for: StorageKey.backends)

        if activeBackendId == backend.id {
            activeBackendId = backends.first?.id
            if let id = activeBackendId {
                storage.save(id, for: StorageKey.activeBackendId)
            } else {
                storage.remove(for: StorageKey.activeBackendId)
            }
        }
    }

    func testBackend(_ backend: Backend) {
        guard let url = backend.baseURL else {
            error = NetworkError.invalidURL
            return
        }

        Task { @MainActor in
            var request = URLRequest(url: url.appendingPathComponent("/version"))
            request.timeoutInterval = 5

            if let secret = backend.secret, !secret.isEmpty {
                request.setValue("Bearer \(secret)", forHTTPHeaderField: "Authorization")
            }

            do {
                let (_, response) = try await URLSession.shared.data(for: request)
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    // 连接成功
                } else {
                    error = NetworkError.invalidResponse
                }
            } catch {
                self.error = error
            }
        }
    }
}
