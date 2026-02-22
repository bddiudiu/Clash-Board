//
//  BackendRepository.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation
import Combine

final class BackendRepository: BackendRepositoryProtocol {

    // MARK: - Properties

    private let localStorage: BackendLocalDataSource
    private let keychainStorage: KeychainStorageProtocol
    private let apiClient: APIClientProtocol

    // MARK: - Initialization

    init(
        localStorage: BackendLocalDataSource,
        keychainStorage: KeychainStorageProtocol,
        apiClient: APIClientProtocol
    ) {
        self.localStorage = localStorage
        self.keychainStorage = keychainStorage
        self.apiClient = apiClient
    }

    // MARK: - Public Methods

    func fetchBackends() async throws -> [Backend] {
        return localStorage.loadBackends()
    }

    func addBackend(_ backend: Backend) async throws {
        // 保存密钥到 Keychain
        if let secret = backend.secret, !secret.isEmpty {
            try keychainStorage.saveString(secret, for: "backend_secret_\(backend.id.uuidString)")
        }

        // 保存后端配置（不包含密钥）
        var backendToSave = backend
        backendToSave.secret = nil
        localStorage.saveBackend(backendToSave)
    }

    func updateBackend(_ backend: Backend) async throws {
        // 更新密钥
        if let secret = backend.secret, !secret.isEmpty {
            try keychainStorage.saveString(secret, for: "backend_secret_\(backend.id.uuidString)")
        }

        // 更新后端配置
        var backendToSave = backend
        backendToSave.secret = nil
        localStorage.updateBackend(backendToSave)
    }

    func deleteBackend(_ backendId: UUID) async throws {
        // 删除密钥
        try? keychainStorage.delete(for: "backend_secret_\(backendId.uuidString)")

        // 删除后端配置
        localStorage.deleteBackend(backendId)
    }

    func getActiveBackend() async throws -> Backend? {
        guard let backend = localStorage.getActiveBackend() else {
            return nil
        }

        // 从 Keychain 加载密钥
        var backendWithSecret = backend
        if let secret = try? keychainStorage.loadString(for: "backend_secret_\(backend.id.uuidString)") {
            backendWithSecret.secret = secret
        }

        return backendWithSecret
    }

    func setActiveBackend(_ backendId: UUID) async throws {
        localStorage.setActiveBackend(backendId)

        // 配置 API 客户端
        if let backend = try await getActiveBackend(),
           let baseURL = backend.baseURL {
            apiClient.configure(baseURL: baseURL, secret: backend.secret)
        }
    }

    func testBackend(_ backend: Backend) async throws -> Bool {
        guard let baseURL = backend.baseURL else {
            throw NetworkError.invalidURL
        }

        // 临时配置 API 客户端
        let tempClient = ClashAPIClient()
        tempClient.configure(baseURL: baseURL, secret: backend.secret)

        // 测试连接
        do {
            let _: VersionResponse = try await tempClient.request(.getVersion)
            return true
        } catch {
            return false
        }
    }
}

// MARK: - Version Response

struct VersionResponse: Decodable {
    let version: String
    let premium: Bool?
}
