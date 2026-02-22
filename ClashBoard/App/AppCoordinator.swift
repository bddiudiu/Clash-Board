//
//  AppCoordinator.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import SwiftUI
import Combine

final class AppCoordinator: ObservableObject {
    // MARK: - Published Properties

    @Published var colorScheme: ColorScheme?
    @Published var selectedTab: MainTab = .overview
    @Published var isBackendConfigured: Bool = false
    @Published var activeBackend: Backend?

    // MARK: - Private Properties

    private let storage = UserDefaultsStorage()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init() {
        loadSettings()
        checkBackendConfiguration()
    }

    // MARK: - Public Methods

    /// 激活指定后端，配置 API 客户端
    func activateBackend(_ backend: Backend) {
        activeBackend = backend

        // 保存为活跃后端
        storage.save(backend.id, for: StorageKey.activeBackendId)

        // 配置 API 客户端
        if let url = backend.baseURL {
            let apiClient = DIContainer.shared.resolve(APIClientProtocol.self)
            apiClient.configure(baseURL: url, secret: backend.secret)
        }

        isBackendConfigured = true
    }

    /// 从存储中恢复活跃后端
    func restoreActiveBackend() {
        guard let backends = storage.load([Backend].self, for: StorageKey.backends),
              let activeId = storage.load(UUID.self, for: StorageKey.activeBackendId),
              let backend = backends.first(where: { $0.id == activeId }) else {
            return
        }
        activateBackend(backend)
    }

    // MARK: - Private Methods

    private func loadSettings() {
        let theme = UserDefaults.standard.string(forKey: "theme") ?? "system"
        switch theme {
        case "light":
            colorScheme = .light
        case "dark":
            colorScheme = .dark
        default:
            colorScheme = nil
        }
    }

    private func checkBackendConfiguration() {
        let backends = storage.load([Backend].self, for: StorageKey.backends) ?? []
        if !backends.isEmpty {
            restoreActiveBackend()
        }
    }
}

// MARK: - MainTab

enum MainTab: String, CaseIterable {
    case overview = "概览"
    case proxy = "代理"
    case connection = "连接"
    case more = "更多"

    var icon: String {
        switch self {
        case .overview: return "chart.bar.fill"
        case .proxy: return "network"
        case .connection: return "arrow.left.arrow.right"
        case .more: return "ellipsis.circle.fill"
        }
    }
}
