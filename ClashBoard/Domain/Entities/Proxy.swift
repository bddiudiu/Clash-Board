//
//  Proxy.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation

struct ProxyGroup: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let type: ProxyGroupType
    let now: String?
    let all: [String]
    let proxies: [Proxy]

    init(
        id: String = UUID().uuidString,
        name: String,
        type: ProxyGroupType,
        now: String? = nil,
        all: [String] = [],
        proxies: [Proxy] = []
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.now = now
        self.all = all
        self.proxies = proxies
    }
}

enum ProxyGroupType: String, Codable {
    case selector = "Selector"
    case urlTest = "URLTest"
    case fallback = "Fallback"
    case loadBalance = "LoadBalance"
    case relay = "Relay"
    case direct = "Direct"
    case reject = "Reject"

    var icon: String {
        switch self {
        case .selector: return "hand.point.up.left.fill"
        case .urlTest: return "speedometer"
        case .fallback: return "arrow.triangle.branch"
        case .loadBalance: return "scale.3d"
        case .relay: return "arrow.right.arrow.left"
        case .direct: return "arrow.forward"
        case .reject: return "xmark.circle.fill"
        }
    }
}

struct Proxy: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let type: ProxyType
    let latency: Int?
    let history: [LatencyHistory]

    init(
        id: String = UUID().uuidString,
        name: String,
        type: ProxyType,
        latency: Int? = nil,
        history: [LatencyHistory] = []
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.latency = latency
        self.history = history
    }

    var latencyLevel: LatencyLevel {
        guard let latency = latency else { return .timeout }

        switch latency {
        case 0..<100:
            return .excellent
        case 100..<300:
            return .good
        case 300..<1000:
            return .poor
        default:
            return .bad
        }
    }
}

enum ProxyType: String, Codable {
    case shadowsocks = "Shadowsocks"
    case vmess = "Vmess"
    case trojan = "Trojan"
    case snell = "Snell"
    case http = "Http"
    case socks5 = "Socks5"
    case direct = "Direct"
    case reject = "Reject"

    var icon: String {
        switch self {
        case .shadowsocks: return "shield.fill"
        case .vmess: return "v.circle.fill"
        case .trojan: return "t.circle.fill"
        case .snell: return "s.circle.fill"
        case .http: return "h.circle.fill"
        case .socks5: return "5.circle.fill"
        case .direct: return "arrow.forward.circle.fill"
        case .reject: return "xmark.circle.fill"
        }
    }
}

struct LatencyHistory: Codable, Equatable {
    let time: Date
    let delay: Int
}

enum LatencyLevel {
    case excellent  // < 100ms
    case good       // 100-300ms
    case poor       // 300-1000ms
    case bad        // > 1000ms
    case timeout    // nil

    var color: String {
        switch self {
        case .excellent: return "green"
        case .good: return "yellow"
        case .poor: return "orange"
        case .bad: return "red"
        case .timeout: return "gray"
        }
    }

    var displayText: String {
        switch self {
        case .excellent: return "优秀"
        case .good: return "良好"
        case .poor: return "较差"
        case .bad: return "很差"
        case .timeout: return "超时"
        }
    }
}

// MARK: - Mock Data

#if DEBUG
extension ProxyGroup {
    static func mock() -> ProxyGroup {
        ProxyGroup(
            name: "🚀 节点选择",
            type: .selector,
            now: "香港 01",
            all: ["香港 01", "香港 02", "日本 01"],
            proxies: [
                Proxy.mock(name: "香港 01", latency: 50),
                Proxy.mock(name: "香港 02", latency: 120),
                Proxy.mock(name: "日本 01", latency: 80)
            ]
        )
    }
}

extension Proxy {
    static func mock(name: String = "香港 01", latency: Int? = 50) -> Proxy {
        Proxy(
            name: name,
            type: .shadowsocks,
            latency: latency,
            history: []
        )
    }
}
#endif
