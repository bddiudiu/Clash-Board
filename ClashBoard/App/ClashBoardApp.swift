//
//  ClashBoardApp.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import SwiftUI

@main
struct ClashBoardApp: App {
    @StateObject private var appCoordinator = AppCoordinator()

    init() {
        setupDependencies()
        configureAppearance()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(appCoordinator)
                .preferredColorScheme(appCoordinator.colorScheme)
        }
    }

    // MARK: - Private Methods

    private func setupDependencies() {
        DIContainer.shared.register()
    }

    private func configureAppearance() {
        // 配置全局 UI 样式
    }
}
