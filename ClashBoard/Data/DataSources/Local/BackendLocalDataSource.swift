//
//  BackendLocalDataSource.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation

final class BackendLocalDataSource {

    // MARK: - Properties

    private let storage: UserDefaultsStorageProtocol
    private let backendsKey = StorageKey.backends
    private let activeBackendIdKey = StorageKey.activeBackendId

    // MARK: - Initialization

    init(storage: UserDefaultsStorageProtocol) {
        self.storage = storage
    }

    // MARK: - Public Methods

    func loadBackends() -> [Backend] {
        return storage.load([Backend].self, for: backendsKey) ?? []
    }

    func saveBackend(_ backend: Backend) {
        var backends = loadBackends()
        backends.append(backend)
        storage.save(backends, for: backendsKey)
    }

    func updateBackend(_ backend: Backend) {
        var backends = loadBackends()
        if let index = backends.firstIndex(where: { $0.id == backend.id }) {
            backends[index] = backend
            storage.save(backends, for: backendsKey)
        }
    }

    func deleteBackend(_ backendId: UUID) {
        var backends = loadBackends()
        backends.removeAll { $0.id == backendId }
        storage.save(backends, for: backendsKey)

        // 如果删除的是活跃后端，清除活跃状态
        if let activeId = storage.load(UUID.self, for: activeBackendIdKey),
           activeId == backendId {
            storage.remove(for: activeBackendIdKey)
        }
    }

    func getActiveBackend() -> Backend? {
        guard let activeId = storage.load(UUID.self, for: activeBackendIdKey) else {
            return nil
        }

        let backends = loadBackends()
        return backends.first { $0.id == activeId }
    }

    func setActiveBackend(_ backendId: UUID) {
        storage.save(backendId, for: activeBackendIdKey)
    }
}
