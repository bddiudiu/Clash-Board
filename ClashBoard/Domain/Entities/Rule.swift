//
//  Rule.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation

struct Rule: Identifiable, Codable, Equatable {
    let id: String
    let type: RuleType
    let payload: String
    let proxy: String
    var isDisabled: Bool
    var hitCount: Int
    var missCount: Int

    init(
        id: String = UUID().uuidString,
        type: RuleType,
        payload: String,
        proxy: String,
        isDisabled: Bool = false,
        hitCount: Int = 0,
        missCount: Int = 0
    ) {
        self.id = id
        self.type = type
        self.payload = payload
        self.proxy = proxy
        self.isDisabled = isDisabled
        self.hitCount = hitCount
        self.missCount = missCount
    }

    var totalCount: Int {
        hitCount + missCount
    }

    var hitRate: Double {
        guard totalCount > 0 else { return 0 }
        return Double(hitCount) / Double(totalCount)
    }
}

enum RuleType: String, Codable, CaseIterable {
    case domain = "DOMAIN"
    case domainSuffix = "DOMAIN-SUFFIX"
    case domainKeyword = "DOMAIN-KEYWORD"
    case geoip = "GEOIP"
    case ipCidr = "IP-CIDR"
    case ipCidr6 = "IP-CIDR6"
    case srcIpCidr = "SRC-IP-CIDR"
    case srcPort = "SRC-PORT"
    case dstPort = "DST-PORT"
    case processName = "PROCESS-NAME"
    case processPath = "PROCESS-PATH"
    case match = "MATCH"

    var icon: String {
        switch self {
        case .domain, .domainSuffix, .domainKeyword:
            return "globe"
        case .geoip:
            return "location.fill"
        case .ipCidr, .ipCidr6, .srcIpCidr:
            return "network"
        case .srcPort, .dstPort:
            return "arrow.left.arrow.right"
        case .processName, .processPath:
            return "app.fill"
        case .match:
            return "checkmark.circle.fill"
        }
    }

    var color: String {
        switch self {
        case .domain, .domainSuffix, .domainKeyword:
            return "blue"
        case .geoip:
            return "green"
        case .ipCidr, .ipCidr6, .srcIpCidr:
            return "orange"
        case .srcPort, .dstPort:
            return "purple"
        case .processName, .processPath:
            return "pink"
        case .match:
            return "gray"
        }
    }
}

struct RuleProvider: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let vehicleType: String
    let behavior: String
    let ruleCount: Int
    let updatedAt: Date

    init(
        id: String = UUID().uuidString,
        name: String,
        vehicleType: String,
        behavior: String,
        ruleCount: Int,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.vehicleType = vehicleType
        self.behavior = behavior
        self.ruleCount = ruleCount
        self.updatedAt = updatedAt
    }
}

// MARK: - Mock Data

#if DEBUG
extension Rule {
    static func mock() -> Rule {
        Rule(
            type: .domainSuffix,
            payload: "google.com",
            proxy: "🚀 节点选择",
            hitCount: 150,
            missCount: 10
        )
    }
}

extension RuleProvider {
    static func mock() -> RuleProvider {
        RuleProvider(
            name: "reject",
            vehicleType: "HTTP",
            behavior: "domain",
            ruleCount: 1000
        )
    }
}
#endif
