//
//  MainTabView.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var selectedTab: MainTab = .overview

    var body: some View {
        Group {
            if coordinator.isBackendConfigured {
                tabContent
            } else {
                NavigationStack {
                    BackendFormView(isInitialSetup: true) {
                        // 保存完成后，从存储中恢复活跃后端并进入主页
                        coordinator.restoreActiveBackend()
                    }
                }
            }
        }
    }

    // MARK: - Tab Content

    private var tabContent: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                OverviewView()
            }
            .tabItem {
                Label(MainTab.overview.rawValue, systemImage: MainTab.overview.icon)
            }
            .tag(MainTab.overview)

            NavigationStack {
                ProxyListView()
            }
            .tabItem {
                Label(MainTab.proxy.rawValue, systemImage: MainTab.proxy.icon)
            }
            .tag(MainTab.proxy)

            NavigationStack {
                ConnectionListView()
            }
            .tabItem {
                Label(MainTab.connection.rawValue, systemImage: MainTab.connection.icon)
            }
            .tag(MainTab.connection)

            NavigationStack {
                MoreView()
            }
            .tabItem {
                Label(MainTab.more.rawValue, systemImage: MainTab.more.icon)
            }
            .tag(MainTab.more)
        }
    }
}

#if DEBUG
#Preview {
    MainTabView()
        .environmentObject(AppCoordinator())
}
#endif
