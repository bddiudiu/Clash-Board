//
//  APIEndpoint.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation

enum APIEndpoint {
    // MARK: - Proxy
    case getProxies
    case getProxy(name: String)
    case selectProxy(group: String, name: String)
    case getProxyDelay(name: String, url: String, timeout: Int)

    // MARK: - Proxy Provider
    case getProxyProviders
    case updateProxyProvider(name: String)
    case healthCheckProxyProvider(name: String)

    // MARK: - Connection
    case getConnections
    case closeConnection(id: String)
    case closeAllConnections

    // MARK: - Rule
    case getRules
    case toggleRule(index: Int, disabled: Bool)

    // MARK: - Rule Provider
    case getRuleProviders
    case updateRuleProvider(name: String)

    // MARK: - Config
    case getConfig
    case patchConfig(data: [String: Any])
    case reloadConfig(path: String, payload: String)

    // MARK: - Log
    case getLogs(level: String)

    // MARK: - Traffic
    case getTraffic

    // MARK: - Memory
    case getMemory

    // MARK: - Version
    case getVersion

    // MARK: - DNS
    case dnsQuery(name: String, type: String)

    // MARK: - Properties

    var path: String {
        switch self {
        case .getProxies:
            return "/proxies"
        case .getProxy(let name):
            return "/proxies/\(name.urlEncoded)"
        case .selectProxy(let group, _):
            return "/proxies/\(group.urlEncoded)"
        case .getProxyDelay(let name, _, _):
            return "/proxies/\(name.urlEncoded)/delay"
        case .getProxyProviders:
            return "/providers/proxies"
        case .updateProxyProvider(let name):
            return "/providers/proxies/\(name.urlEncoded)"
        case .healthCheckProxyProvider(let name):
            return "/providers/proxies/\(name.urlEncoded)/healthcheck"
        case .getConnections:
            return "/connections"
        case .closeConnection(let id):
            return "/connections/\(id)"
        case .closeAllConnections:
            return "/connections"
        case .getRules:
            return "/rules"
        case .toggleRule:
            return "/rules"
        case .getRuleProviders:
            return "/providers/rules"
        case .updateRuleProvider(let name):
            return "/providers/rules/\(name.urlEncoded)"
        case .getConfig:
            return "/configs"
        case .patchConfig:
            return "/configs"
        case .reloadConfig:
            return "/configs"
        case .getLogs:
            return "/logs"
        case .getTraffic:
            return "/traffic"
        case .getMemory:
            return "/memory"
        case .getVersion:
            return "/version"
        case .dnsQuery:
            return "/dns/query"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .selectProxy:
            return .put
        case .closeConnection, .closeAllConnections:
            return .delete
        case .patchConfig:
            return .patch
        case .reloadConfig, .toggleRule:
            return .put
        case .updateProxyProvider, .healthCheckProxyProvider, .updateRuleProvider:
            return .put
        case .dnsQuery:
            return .post
        default:
            return .get
        }
    }

    var body: Data? {
        switch self {
        case .selectProxy(_, let name):
            return try? JSONEncoder().encode(["name": name])
        case .patchConfig(let data):
            return try? JSONSerialization.data(withJSONObject: data)
        case .toggleRule(let index, let disabled):
            let payload: [String: Any] = [
                "index": index,
                "disabled": disabled
            ]
            return try? JSONSerialization.data(withJSONObject: payload)
        case .dnsQuery(let name, let type):
            return try? JSONSerialization.data(withJSONObject: ["name": name, "type": type])
        default:
            return nil
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .getProxyDelay(_, let url, let timeout):
            return [
                URLQueryItem(name: "url", value: url),
                URLQueryItem(name: "timeout", value: String(timeout))
            ]
        case .getLogs(let level):
            return [
                URLQueryItem(name: "level", value: level)
            ]
        default:
            return nil
        }
    }

    var isWebSocket: Bool {
        switch self {
        case .getTraffic, .getMemory, .getLogs, .getConnections:
            return true
        default:
            return false
        }
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// MARK: - String Extension

private extension String {
    var urlEncoded: String {
        addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? self
    }
}
