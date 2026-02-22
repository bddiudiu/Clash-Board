//
//  ConnectionListView.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import SwiftUI

struct ConnectionListView: View {
    @StateObject private var viewModel = ConnectionListViewModel()
    @State private var searchText = ""
    @State private var selectedConnection: Connection?

    var body: some View {
        Group {
            if viewModel.connections.isEmpty && !viewModel.isLoading {
                EmptyStateView(
                    icon: "arrow.left.arrow.right",
                    title: "没有活跃连接",
                    message: "当前没有活跃的网络连接",
                    action: nil
                )
            } else {
                connectionList
            }
        }
        .navigationTitle("连接")
        .searchable(text: $searchText, prompt: "搜索连接")
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Text("\(filteredConnections.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.tertiarySystemGroupedBackground))
                    .cornerRadius(8)

                Menu {
                    sortMenu
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }

                Button(role: .destructive, action: viewModel.closeAllConnections) {
                    Image(systemName: "xmark.circle")
                }
            }
        }
        .sheet(item: $selectedConnection) { connection in
            ConnectionDetailView(connection: connection)
        }
        .onAppear {
            viewModel.startMonitoring()
        }
        .onDisappear {
            viewModel.stopMonitoring()
        }
    }

    // MARK: - Connection List

    private var connectionList: some View {
        List {
            ForEach(filteredConnections) { connection in
                ConnectionCard(connection: connection)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .listRowSeparator(.hidden)
                    .onTapGesture {
                        selectedConnection = connection
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            viewModel.closeConnection(id: connection.id)
                        } label: {
                            Label("关闭", systemImage: "xmark")
                        }
                    }
            }
        }
        .listStyle(.plain)
    }

    // MARK: - Sort Menu

    private var sortMenu: some View {
        Group {
            Button(action: { viewModel.sortBy = .speed }) {
                Label("按速度排序", systemImage: "speedometer")
            }
            Button(action: { viewModel.sortBy = .traffic }) {
                Label("按流量排序", systemImage: "arrow.up.arrow.down.circle")
            }
            Button(action: { viewModel.sortBy = .time }) {
                Label("按时间排序", systemImage: "clock")
            }
            Button(action: { viewModel.sortBy = .host }) {
                Label("按主机排序", systemImage: "globe")
            }
        }
    }

    // MARK: - Computed Properties

    private var filteredConnections: [Connection] {
        if searchText.isEmpty {
            return viewModel.connections
        }
        return viewModel.connections.filter { connection in
            connection.metadata.host.localizedCaseInsensitiveContains(searchText) ||
            connection.metadata.destinationIP.localizedCaseInsensitiveContains(searchText) ||
            connection.rule.localizedCaseInsensitiveContains(searchText) ||
            connection.chains.contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

// MARK: - Connection Card

struct ConnectionCard: View {
    let connection: Connection

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 主机和规则
            HStack {
                Text(connection.metadata.displayHost)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Spacer()

                Text(connection.metadata.network.uppercased())
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.accentColor.opacity(0.1))
                    .foregroundColor(.accentColor)
                    .cornerRadius(4)
            }

            // 链路
            if !connection.chains.isEmpty {
                HStack(spacing: 4) {
                    ForEach(connection.chains.reversed(), id: \.self) { chain in
                        Text(chain)
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        if chain != connection.chains.first {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 8))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }

            // 速度和流量
            HStack {
                // 上传速度
                HStack(spacing: 2) {
                    Image(systemName: "arrow.up")
                        .font(.caption2)
                        .foregroundColor(.blue)
                    Text(ByteFormatter.formatSpeed(connection.uploadSpeed))
                        .font(.caption2)
                        .monospacedDigit()
                        .foregroundColor(.secondary)
                }

                // 下载速度
                HStack(spacing: 2) {
                    Image(systemName: "arrow.down")
                        .font(.caption2)
                        .foregroundColor(.green)
                    Text(ByteFormatter.formatSpeed(connection.downloadSpeed))
                        .font(.caption2)
                        .monospacedDigit()
                        .foregroundColor(.secondary)
                }

                Spacer()

                // 规则
                Text(connection.rule)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
}

// MARK: - Connection Detail View

struct ConnectionDetailView: View {
    let connection: Connection
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("基本信息") {
                    detailRow(title: "主机", value: connection.metadata.displayHost)
                    detailRow(title: "网络", value: connection.metadata.network)
                    detailRow(title: "类型", value: connection.metadata.type)
                    detailRow(title: "规则", value: connection.rule)
                    if !connection.rulePayload.isEmpty {
                        detailRow(title: "规则负载", value: connection.rulePayload)
                    }
                }

                Section("地址信息") {
                    detailRow(title: "源地址", value: connection.metadata.displaySource)
                    detailRow(title: "目标地址", value: connection.metadata.displayDestination)
                    if !connection.metadata.destinationIP.isEmpty {
                        detailRow(title: "目标 IP", value: connection.metadata.destinationIP)
                    }
                }

                Section("流量统计") {
                    detailRow(title: "上传", value: ByteFormatter.format(connection.upload))
                    detailRow(title: "下载", value: ByteFormatter.format(connection.download))
                    detailRow(title: "上传速度", value: ByteFormatter.formatSpeed(connection.uploadSpeed))
                    detailRow(title: "下载速度", value: ByteFormatter.formatSpeed(connection.downloadSpeed))
                }

                if !connection.chains.isEmpty {
                    Section("代理链路") {
                        ForEach(connection.chains.reversed(), id: \.self) { chain in
                            Text(chain)
                        }
                    }
                }
            }
            .navigationTitle("连接详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("关闭") { dismiss() }
                }
            }
        }
    }

    private func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(.primary)
                .multilineTextAlignment(.trailing)
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        ConnectionListView()
    }
}
#endif
