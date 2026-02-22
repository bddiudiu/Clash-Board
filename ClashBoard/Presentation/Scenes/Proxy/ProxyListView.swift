//
//  ProxyListView.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import SwiftUI

struct ProxyListView: View {
    @StateObject private var viewModel = ProxyListViewModel()
    @State private var searchText = ""
    @State private var expandedGroups: Set<String> = []

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.proxyGroups.isEmpty {
                LoadingView()
            } else if viewModel.proxyGroups.isEmpty {
                EmptyStateView(
                    icon: "network",
                    title: "没有代理节点",
                    message: "请检查后端配置是否正确",
                    action: { Task { await viewModel.fetchProxies() } }
                )
            } else {
                proxyList
            }
        }
        .navigationTitle("代理")
        .searchable(text: $searchText, prompt: "搜索节点")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { viewModel.testAllLatency() }) {
                    Image(systemName: "speedometer")
                }
            }
        }
        .refreshable {
            await viewModel.fetchProxies()
        }
        .task {
            await viewModel.fetchProxies()
        }
        .alert("错误", isPresented: .constant(viewModel.error != nil)) {
            Button("确定") { viewModel.clearError() }
        } message: {
            Text(viewModel.error?.localizedDescription ?? "")
        }
    }

    // MARK: - Proxy List

    private var proxyList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredGroups) { group in
                    ProxyGroupCard(
                        group: group,
                        isExpanded: expandedGroups.contains(group.name),
                        isTesting: viewModel.testingGroups.contains(group.name),
                        onToggleExpand: { toggleGroup(group.name) },
                        onSelectProxy: { proxyName in
                            viewModel.selectProxy(group: group.name, proxy: proxyName)
                        },
                        onTestLatency: { proxyName in
                            viewModel.testLatency(proxyName: proxyName)
                        },
                        onTestGroupLatency: {
                            viewModel.testGroupLatency(groupName: group.name)
                        }
                    )
                }
            }
            .padding()
        }
    }

    // MARK: - Computed Properties

    private var filteredGroups: [ProxyGroup] {
        if searchText.isEmpty {
            return viewModel.proxyGroups
        }
        return viewModel.proxyGroups.filter { group in
            group.name.localizedCaseInsensitiveContains(searchText) ||
            group.proxies.contains { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    // MARK: - Methods

    private func toggleGroup(_ name: String) {
        if expandedGroups.contains(name) {
            expandedGroups.remove(name)
        } else {
            expandedGroups.insert(name)
        }
    }
}

// MARK: - Proxy Group Card

struct ProxyGroupCard: View {
    let group: ProxyGroup
    let isExpanded: Bool
    let isTesting: Bool
    let onToggleExpand: () -> Void
    let onSelectProxy: (String) -> Void
    let onTestLatency: (String) -> Void
    let onTestGroupLatency: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // 组头部
            groupHeader

            // 展开的代理列表
            if isExpanded {
                Divider()
                    .padding(.horizontal)

                proxyGrid
                    .padding()
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }

    // MARK: - Group Header

    private var groupHeader: some View {
        HStack(spacing: 12) {
            Button(action: onToggleExpand) {
                HStack(spacing: 12) {
                    Image(systemName: group.type.icon)
                        .foregroundColor(.accentColor)
                        .font(.title3)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(group.name)
                            .font(.headline)
                            .foregroundColor(.primary)

                        HStack(spacing: 4) {
                            Text(group.type.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)

                            if let now = group.now {
                                Text("·")
                                    .foregroundColor(.secondary)
                                Text(now)
                                    .font(.caption)
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }

                    Spacer()

                    Text("\(group.proxies.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.tertiarySystemGroupedBackground))
                        .cornerRadius(8)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)

            Button(action: onTestGroupLatency) {
                Group {
                    if isTesting {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "speedometer")
                            .font(.subheadline)
                    }
                }
                .frame(width: 28, height: 28)
                .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)
            .disabled(isTesting)
        }
        .padding()
    }

    // MARK: - Proxy Grid

    private var proxyGrid: some View {
        let columns = [
            GridItem(.flexible(), spacing: 8),
            GridItem(.flexible(), spacing: 8)
        ]

        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(group.proxies) { proxy in
                ProxyNodeCard(
                    proxy: proxy,
                    isSelected: proxy.name == group.now,
                    onTap: { onSelectProxy(proxy.name) },
                    onTestLatency: { onTestLatency(proxy.name) }
                )
            }
        }
    }
}

// MARK: - Proxy Node Card

struct ProxyNodeCard: View {
    let proxy: Proxy
    let isSelected: Bool
    let onTap: () -> Void
    let onTestLatency: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(proxy.name)
                        .font(.subheadline)
                        .fontWeight(isSelected ? .semibold : .regular)
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.accentColor)
                            .font(.caption)
                    }
                }

                HStack {
                    Text(proxy.type.rawValue)
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Spacer()

                    LatencyBadge(latency: proxy.latency)
                }
            }
            .padding(10)
            .background(isSelected ? Color.accentColor.opacity(0.1) : Color(.tertiarySystemGroupedBackground))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(action: onTestLatency) {
                Label("测试延迟", systemImage: "speedometer")
            }
        }
    }
}

// MARK: - Latency Badge

struct LatencyBadge: View {
    let latency: Int?

    var body: some View {
        Text(LatencyFormatter.format(latency))
            .font(.caption2)
            .fontWeight(.medium)
            .monospacedDigit()
            .foregroundColor(latencyColor)
    }

    private var latencyColor: Color {
        guard let latency = latency, latency > 0 else { return .gray }
        switch latency {
        case 0..<100: return .green
        case 100..<300: return .yellow
        case 300..<1000: return .orange
        default: return .red
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        ProxyListView()
    }
}
#endif
