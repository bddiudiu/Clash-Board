//
//  MoreView.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-21.
//

import SwiftUI

struct MoreView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var kernelVersion: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                backendInfoCard
                featureGrid
                systemSection
            }
            .padding()
        }
        .navigationTitle("更多")
        .task {
            await fetchVersion()
        }
    }

    // MARK: - Backend Info

    private var backendInfoCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "server.rack")
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 44, height: 44)
                .background(Color.accentColor.opacity(0.12))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                Text(coordinator.activeBackend?.label ?? "未连接")
                    .font(.headline)

                HStack(spacing: 6) {
                    if let backend = coordinator.activeBackend {
                        Text("\(backend.host):\(backend.port)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    if !kernelVersion.isEmpty {
                        Text("·")
                            .foregroundColor(.secondary)
                        Text(kernelVersion)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            Circle()
                .fill(coordinator.activeBackend != nil ? Color.green : Color.red)
                .frame(width: 8, height: 8)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }

    // MARK: - Feature Grid

    private var featureGrid: some View {
        let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]

        return LazyVGrid(columns: columns, spacing: 12) {
            NavigationLink(destination: RuleListView()) {
                MoreFeatureCard(
                    icon: "list.bullet.rectangle",
                    title: "规则",
                    subtitle: "分流规则管理",
                    color: .orange
                )
            }

            NavigationLink(destination: LogView()) {
                MoreFeatureCard(
                    icon: "doc.text.magnifyingglass",
                    title: "日志",
                    subtitle: "实时日志查看",
                    color: .purple
                )
            }

            NavigationLink(destination: ProviderListView()) {
                MoreFeatureCard(
                    icon: "shippingbox",
                    title: "订阅",
                    subtitle: "代理与规则提供者",
                    color: .cyan
                )
            }

            NavigationLink(destination: DNSQueryView()) {
                MoreFeatureCard(
                    icon: "network.badge.shield.half.filled",
                    title: "DNS 查询",
                    subtitle: "域名解析测试",
                    color: .teal
                )
            }
        }
    }

    // MARK: - System Section

    private var systemSection: some View {
        VStack(spacing: 0) {
            NavigationLink(destination: SettingsView()) {
                systemRow(icon: "gearshape.fill", title: "设置", color: .gray)
            }

            Divider().padding(.leading, 56)

            NavigationLink(destination: BackendListView()) {
                systemRow(icon: "server.rack", title: "后端管理", color: .blue)
            }

            Divider().padding(.leading, 56)

            Button {
                reloadConfig()
            } label: {
                systemRow(icon: "arrow.clockwise", title: "重载配置", color: .green)
            }

            Divider().padding(.leading, 56)

            systemRow(icon: "info.circle.fill", title: "版本", color: .secondary, trailing: {
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.1.0")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            })
        }
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }

    // MARK: - Helpers

    private func systemRow(
        icon: String,
        title: String,
        color: Color,
        @ViewBuilder trailing: () -> some View = { Image(systemName: "chevron.right").font(.caption).foregroundColor(.secondary) }
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(color)
                .cornerRadius(7)

            Text(title)
                .font(.body)
                .foregroundColor(.primary)

            Spacer()

            trailing()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }

    private func fetchVersion() async {
        let apiClient = DIContainer.shared.resolve(APIClientProtocol.self)
        if let data = try? await apiClient.requestRaw(.getVersion),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let ver = json["version"] as? String {
            await MainActor.run { kernelVersion = ver }
        }
    }

    private func reloadConfig() {
        Task {
            let apiClient = DIContainer.shared.resolve(APIClientProtocol.self)
            _ = try? await apiClient.requestRaw(.reloadConfig(path: "", payload: ""))
        }
    }
}

// MARK: - Feature Card

struct MoreFeatureCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.12))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

// MARK: - Placeholder Views

struct ProviderListView: View {
    var body: some View {
        List {
            Section("代理提供者") {
                Text("暂无数据")
                    .foregroundColor(.secondary)
            }
            Section("规则提供者") {
                Text("暂无数据")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("订阅")
    }
}

struct DNSQueryView: View {
    @State private var domain = ""
    @State private var result = ""
    @State private var isQuerying = false

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                TextField("输入域名", text: $domain)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                Button {
                    queryDNS()
                } label: {
                    if isQuerying {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Text("查询")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(domain.isEmpty || isQuerying)
            }
            .padding(.horizontal)

            if !result.isEmpty {
                ScrollView {
                    Text(result)
                        .font(.system(size: 13, design: .monospaced))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .padding(.horizontal)
            }

            Spacer()
        }
        .padding(.top)
        .navigationTitle("DNS 查询")
    }

    private func queryDNS() {
        isQuerying = true
        result = ""
        Task {
            let apiClient = DIContainer.shared.resolve(APIClientProtocol.self)
            do {
                let data = try await apiClient.requestRaw(.dnsQuery(name: domain, type: "A"))
                if let json = try? JSONSerialization.jsonObject(with: data),
                   let pretty = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
                   let str = String(data: pretty, encoding: .utf8) {
                    await MainActor.run { result = str }
                } else if let str = String(data: data, encoding: .utf8) {
                    await MainActor.run { result = str }
                }
            } catch {
                await MainActor.run { result = "查询失败: \(error.localizedDescription)" }
            }
            await MainActor.run { isQuerying = false }
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        MoreView()
            .environmentObject(AppCoordinator())
    }
}
#endif
