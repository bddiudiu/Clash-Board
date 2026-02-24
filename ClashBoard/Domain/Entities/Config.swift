//
//  Config.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation

struct ClashConfig: Codable, Equatable {
    var port: Int
    var socksPort: Int
    var redirPort: Int
    var tproxyPort: Int
    var mixedPort: Int
    var mode: ClashMode
    var logLevel: LogLevel
    var allowLan: Bool
    var ipv6: Bool
    var tun: TunConfig
    var dns: DNSConfig?

    enum CodingKeys: String, CodingKey {
        case port
        case socksPort = "socks-port"
        case redirPort = "redir-port"
        case tproxyPort = "tproxy-port"
        case mixedPort = "mixed-port"
        case mode
        case logLevel = "log-level"
        case allowLan = "allow-lan"
        case ipv6
        case tun
        case dns
    }

    init(
        port: Int = 7890,
        socksPort: Int = 7891,
        redirPort: Int = 0,
        tproxyPort: Int = 0,
        mixedPort: Int = 0,
        mode: ClashMode = .rule,
        logLevel: LogLevel = .info,
        allowLan: Bool = false,
        ipv6: Bool = false,
        tun: TunConfig = TunConfig(),
        dns: DNSConfig? = nil
    ) {
        self.port = port
        self.socksPort = socksPort
        self.redirPort = redirPort
        self.tproxyPort = tproxyPort
        self.mixedPort = mixedPort
        self.mode = mode
        self.logLevel = logLevel
        self.allowLan = allowLan
        self.ipv6 = ipv6
        self.tun = tun
        self.dns = dns
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        port = try container.decodeIfPresent(Int.self, forKey: .port) ?? 7890
        socksPort = try container.decodeIfPresent(Int.self, forKey: .socksPort) ?? 0
        redirPort = try container.decodeIfPresent(Int.self, forKey: .redirPort) ?? 0
        tproxyPort = try container.decodeIfPresent(Int.self, forKey: .tproxyPort) ?? 0
        mixedPort = try container.decodeIfPresent(Int.self, forKey: .mixedPort) ?? 0
        mode = try container.decodeIfPresent(ClashMode.self, forKey: .mode) ?? .rule
        logLevel = try container.decodeIfPresent(LogLevel.self, forKey: .logLevel) ?? .info
        allowLan = try container.decodeIfPresent(Bool.self, forKey: .allowLan) ?? false
        ipv6 = try container.decodeIfPresent(Bool.self, forKey: .ipv6) ?? false
        tun = try container.decodeIfPresent(TunConfig.self, forKey: .tun) ?? TunConfig()
        dns = try container.decodeIfPresent(DNSConfig.self, forKey: .dns)
    }
}

enum ClashMode: String, Codable, CaseIterable {
    case global = "global"
    case rule = "rule"
    case direct = "direct"

    var displayName: String {
        switch self {
        case .global: return "全局"
        case .rule: return "规则"
        case .direct: return "直连"
        }
    }

    var icon: String {
        switch self {
        case .global: return "globe"
        case .rule: return "list.bullet"
        case .direct: return "arrow.forward"
        }
    }

    var description: String {
        switch self {
        case .global: return "所有流量通过代理"
        case .rule: return "根据规则分流"
        case .direct: return "所有流量直连"
        }
    }
}

// MARK: - Mihomo Compatibility Aliases

typealias MihomoConfig = ClashConfig
typealias MihomoMode = ClashMode

struct TunConfig: Codable, Equatable {
    var enable: Bool
    var stack: String
    var dnsHijack: [String]
    var autoRoute: Bool
    var autoDetectInterface: Bool

    enum CodingKeys: String, CodingKey {
        case enable, stack
        case dnsHijack = "dns-hijack"
        case autoRoute = "auto-route"
        case autoDetectInterface = "auto-detect-interface"
    }

    init(
        enable: Bool = false,
        stack: String = "system",
        dnsHijack: [String] = [],
        autoRoute: Bool = true,
        autoDetectInterface: Bool = true
    ) {
        self.enable = enable
        self.stack = stack
        self.dnsHijack = dnsHijack
        self.autoRoute = autoRoute
        self.autoDetectInterface = autoDetectInterface
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        enable = try container.decodeIfPresent(Bool.self, forKey: .enable) ?? false
        stack = try container.decodeIfPresent(String.self, forKey: .stack) ?? "system"
        dnsHijack = try container.decodeIfPresent([String].self, forKey: .dnsHijack) ?? []
        autoRoute = try container.decodeIfPresent(Bool.self, forKey: .autoRoute) ?? true
        autoDetectInterface = try container.decodeIfPresent(Bool.self, forKey: .autoDetectInterface) ?? true
    }
}

struct DNSConfig: Codable, Equatable {
    var enable: Bool
    var ipv6: Bool
    var enhancedMode: String
    var nameserver: [String]
    var fallback: [String]

    enum CodingKeys: String, CodingKey {
        case enable, ipv6
        case enhancedMode = "enhanced-mode"
        case nameserver, fallback
    }

    init(
        enable: Bool = true,
        ipv6: Bool = false,
        enhancedMode: String = "fake-ip",
        nameserver: [String] = ["223.5.5.5", "119.29.29.29"],
        fallback: [String] = ["8.8.8.8", "1.1.1.1"]
    ) {
        self.enable = enable
        self.ipv6 = ipv6
        self.enhancedMode = enhancedMode
        self.nameserver = nameserver
        self.fallback = fallback
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        enable = try container.decodeIfPresent(Bool.self, forKey: .enable) ?? true
        ipv6 = try container.decodeIfPresent(Bool.self, forKey: .ipv6) ?? false
        enhancedMode = try container.decodeIfPresent(String.self, forKey: .enhancedMode) ?? "fake-ip"
        nameserver = try container.decodeIfPresent([String].self, forKey: .nameserver) ?? []
        fallback = try container.decodeIfPresent([String].self, forKey: .fallback) ?? []
    }
}

// MARK: - Mock Data

#if DEBUG
extension ClashConfig {
    static func mock() -> ClashConfig {
        ClashConfig(
            mode: .rule,
            logLevel: .info,
            allowLan: false,
            ipv6: false
        )
    }
}
#endif
