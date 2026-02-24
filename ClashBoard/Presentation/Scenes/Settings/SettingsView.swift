//
//  SettingsView.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var viewModel = SettingsViewModel()
    @AppStorage("theme") private var theme = "system"

    var body: some View {
        List {
            mihomoConfigSection
            portInfoSection
            proxySettingsSection
            appearanceSection
            backendSection
            aboutSection
        }
        .navigationTitle("设置")
        .task {
            await viewModel.fetchConfig()
            await viewModel.fetchVersion()
        }
        .refreshable {
            await viewModel.fetchConfig()
        }
        .alert("错误", isPresented: .constant(viewModel.error != nil)) {
            Button("确定") { viewModel.clearError() }
        } message: {
            Text(viewModel.error?.localizedDescription ?? "")
        }
    }

    // MARK: - Mihomo 配置

    private var mihomoConfigSection: some View {
        Section {
            // 运行模式
            HStack {
                Label("运行模式", systemImage: viewModel.mode.icon)
                Spacer()
                Picker("", selection: Binding(
                    get: { viewModel.mode },
                    set: { viewModel.updateMode($0) }
                )) {
                    ForEach(ClashMode.allCases, id: \.self) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .pickerStyle(.menu)
            }

            // Allow LAN
            Toggle(isOn: Binding(
                get: { viewModel.allowLan },
                set: { viewModel.updateAllowLan($0) }
            )) {
                Label("允许局域网", systemImage: "wifi")
            }

            // IPv6
            Toggle(isOn: Binding(
                get: { viewModel.ipv6 },
                set: { viewModel.updateIPv6($0) }
            )) {
                Label("IPv6", systemImage: "6.circle")
            }

            // Log Level
            HStack {
                Label("日志等级", systemImage: "doc.text")
                Spacer()
                Picker("", selection: Binding(
                    get: { viewModel.logLevel },
                    set: { viewModel.updateLogLevel($0) }
                )) {
                    ForEach(LogLevel.allCases, id: \.self) { level in
                        Text(level.displayName).tag(level)
                    }
                }
                .pickerStyle(.menu)
            }

            // TUN Mode
            Toggle(isOn: Binding(
                get: { viewModel.tunEnabled },
                set: { viewModel.updateTun($0) }
            )) {
                Label("TUN 模式", systemImage: "network.badge.shield.half.filled")
            }

            // DNS
            Toggle(isOn: Binding(
                get: { viewModel.dnsEnabled },
                set: { viewModel.updateDns($0) }
            )) {
                Label("DNS 增强", systemImage: "server.rack")
            }
        } header: {
            Text("Mihomo 配置")
        } footer: {
            Text("修改会立即同步到 Mihomo 内核")
        }
    }

    // MARK: - 端口信息

    private var portInfoSection: some View {
        Section("端口信息") {
            portRow(title: "HTTP 代理", port: viewModel.httpPort, icon: "globe")
            portRow(title: "SOCKS 代理", port: viewModel.socksPort, icon: "network")
            portRow(title: "混合代理", port: viewModel.mixedPort, icon: "arrow.triangle.merge")
            portRow(title: "透明代理 (Redir)", port: viewModel.redirPort, icon: "arrow.uturn.right")
            portRow(title: "透明代理 (TProxy)", port: viewModel.tproxyPort, icon: "arrow.uturn.left")
        }
    }

    private func portRow(title: String, port: Int, icon: String) -> some View {
        HStack {
            Label(title, systemImage: icon)
            Spacer()
            if port > 0 {
                Text("\(port)")
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            } else {
                Text("未启用")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
        }
    }

    // MARK: - 代理设置

    private var proxySettingsSection: some View {
        Section {
            // 测速 URL
            HStack {
                Label("测速地址", systemImage: "speedometer")
                Spacer()
                TextField("URL", text: $viewModel.speedtestURL)
                    .multilineTextAlignment(.trailing)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }

            // 测速超时
            HStack {
                Label("测速超时", systemImage: "clock")
                Spacer()
                TextField("ms", value: $viewModel.speedtestTimeout, format: .number)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numberPad)
                    .foregroundColor(.secondary)
                    .frame(width: 80)
                Text("ms")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }

            // 低延迟阈值
            HStack {
                Label("低延迟阈值", systemImage: "gauge.with.dots.needle.0percent")
                Spacer()
                TextField("ms", value: $viewModel.latencyLow, format: .number)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numberPad)
                    .foregroundColor(.secondary)
                    .frame(width: 60)
                Text("ms")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }

            // 中延迟阈值
            HStack {
                Label("中延迟阈值", systemImage: "gauge.with.dots.needle.50percent")
                Spacer()
                TextField("ms", value: $viewModel.latencyMedium, format: .number)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numberPad)
                    .foregroundColor(.secondary)
                    .frame(width: 60)
                Text("ms")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }

            // 两列布局
            Toggle(isOn: $viewModel.proxyTwoColumn) {
                Label("节点两列布局", systemImage: "rectangle.grid.2x2")
            }
        } header: {
            Text("代理设置")
        } footer: {
            Text("测速和显示相关的本地设置")
        }
    }

    // MARK: - 外观

    private var appearanceSection: some View {
        Section("外观") {
            Picker(selection: $theme) {
                Text("跟随系统").tag("system")
                Text("浅色").tag("light")
                Text("深色").tag("dark")
            } label: {
                Label("主题", systemImage: "paintbrush")
            }
            .onChange(of: theme) { _, newValue in
                switch newValue {
                case "light": coordinator.colorScheme = .light
                case "dark": coordinator.colorScheme = .dark
                default: coordinator.colorScheme = nil
                }
            }
        }
    }

    // MARK: - 后端管理

    private var backendSection: some View {
        Section("后端") {
            NavigationLink(destination: BackendListView()) {
                Label("后端管理", systemImage: "server.rack")
            }
        }
    }

    // MARK: - 关于

    private var aboutSection: some View {
        Section("关于") {
            if !viewModel.version.isEmpty {
                HStack {
                    Label("内核版本", systemImage: "cpu")
                    Spacer()
                    Text(viewModel.version)
                        .foregroundColor(.secondary)
                }
            }

            HStack {
                Label("客户端版本", systemImage: "app.badge")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.1.0")
                    .foregroundColor(.secondary)
            }

            HStack {
                Label("构建号", systemImage: "hammer")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
                    .foregroundColor(.secondary)
            }

            Link(destination: URL(string: "https://github.com")!) {
                HStack {
                    Label("GitHub", systemImage: "link")
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(AppCoordinator())
    }
}
#endif
