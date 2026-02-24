//
//  SettingsViewModel.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-21.
//

import Foundation
import Combine

final class SettingsViewModel: ObservableObject {

    // MARK: - Published Properties (Mihomo Config)

    @Published var mode: ClashMode = .rule
    @Published var allowLan: Bool = false
    @Published var ipv6: Bool = false
    @Published var logLevel: LogLevel = .info
    @Published var tunEnabled: Bool = false
    @Published var dnsEnabled: Bool = true

    @Published var httpPort: Int = 0
    @Published var socksPort: Int = 0
    @Published var mixedPort: Int = 0
    @Published var redirPort: Int = 0
    @Published var tproxyPort: Int = 0

    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published private(set) var version: String = ""

    // MARK: - Published Properties (Local Preferences)

    @Published var speedtestURL: String {
        didSet { UserDefaults.standard.set(speedtestURL, forKey: "speedtestURL") }
    }
    @Published var speedtestTimeout: Int {
        didSet { UserDefaults.standard.set(speedtestTimeout, forKey: "speedtestTimeout") }
    }
    @Published var proxyTwoColumn: Bool {
        didSet { UserDefaults.standard.set(proxyTwoColumn, forKey: "proxyTwoColumn") }
    }
    @Published var latencyLow: Int {
        didSet { UserDefaults.standard.set(latencyLow, forKey: "latencyLow") }
    }
    @Published var latencyMedium: Int {
        didSet { UserDefaults.standard.set(latencyMedium, forKey: "latencyMedium") }
    }

    // MARK: - Private Properties

    private let apiClient: APIClientProtocol
    private var isUpdating = false

    // MARK: - Initialization

    init(apiClient: APIClientProtocol? = nil) {
        self.apiClient = apiClient ?? DIContainer.shared.resolve(APIClientProtocol.self)

        // Load local preferences
        let defaults = UserDefaults.standard
        self.speedtestURL = defaults.string(forKey: "speedtestURL") ?? "http://www.gstatic.com/generate_204"
        self.speedtestTimeout = defaults.object(forKey: "speedtestTimeout") as? Int ?? 5000
        self.proxyTwoColumn = defaults.object(forKey: "proxyTwoColumn") as? Bool ?? true
        self.latencyLow = defaults.object(forKey: "latencyLow") as? Int ?? 100
        self.latencyMedium = defaults.object(forKey: "latencyMedium") as? Int ?? 300
    }

    // MARK: - Public Methods

    @MainActor
    func fetchConfig() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let config: ClashConfig = try await apiClient.request(.getConfig)
            applyConfig(config)
        } catch {
            self.error = error
        }
    }

    @MainActor
    func fetchVersion() async {
        do {
            let data = try await apiClient.requestRaw(.getVersion)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let ver = json["version"] as? String {
                version = ver
            }
        } catch {
            // ignore
        }
    }

    func updateMode(_ newMode: ClashMode) {
        let oldMode = mode
        mode = newMode
        patchConfig(["mode": newMode.rawValue]) { [weak self] success in
            if !success { self?.mode = oldMode }
        }
    }

    func updateAllowLan(_ value: Bool) {
        let old = allowLan
        allowLan = value
        patchConfig(["allow-lan": value]) { [weak self] success in
            if !success { self?.allowLan = old }
        }
    }

    func updateIPv6(_ value: Bool) {
        let old = ipv6
        ipv6 = value
        patchConfig(["ipv6": value]) { [weak self] success in
            if !success { self?.ipv6 = old }
        }
    }

    func updateLogLevel(_ level: LogLevel) {
        let old = logLevel
        logLevel = level
        patchConfig(["log-level": level.rawValue]) { [weak self] success in
            if !success { self?.logLevel = old }
        }
    }

    func updateTun(_ enabled: Bool) {
        let old = tunEnabled
        tunEnabled = enabled
        patchConfig(["tun": ["enable": enabled]]) { [weak self] success in
            if !success { self?.tunEnabled = old }
        }
    }

    func updateDns(_ enabled: Bool) {
        let old = dnsEnabled
        dnsEnabled = enabled
        patchConfig(["dns": ["enable": enabled]]) { [weak self] success in
            if !success { self?.dnsEnabled = old }
        }
    }

    func clearError() {
        error = nil
    }

    func reloadConfig() {
        Task { @MainActor in
            do {
                _ = try await apiClient.requestRaw(.reloadConfig(path: "", payload: ""))
                await fetchConfig()
            } catch {
                self.error = error
            }
        }
    }

    // MARK: - Private Methods

    @MainActor
    private func applyConfig(_ config: ClashConfig) {
        mode = config.mode
        allowLan = config.allowLan
        ipv6 = config.ipv6
        logLevel = config.logLevel
        tunEnabled = config.tun.enable
        dnsEnabled = config.dns?.enable ?? false
        httpPort = config.port
        socksPort = config.socksPort
        mixedPort = config.mixedPort
        redirPort = config.redirPort
        tproxyPort = config.tproxyPort
    }

    private func patchConfig(_ data: [String: Any], completion: @escaping (Bool) -> Void) {
        Task { @MainActor in
            do {
                _ = try await apiClient.requestRaw(.patchConfig(data: data))
                completion(true)
            } catch {
                self.error = error
                completion(false)
            }
        }
    }
}
