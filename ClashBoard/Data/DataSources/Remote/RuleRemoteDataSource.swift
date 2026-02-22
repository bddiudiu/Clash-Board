//
//  RuleRemoteDataSource.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation

final class RuleRemoteDataSource {

    // MARK: - Properties

    private let apiClient: APIClientProtocol

    // MARK: - Initialization

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    // MARK: - Public Methods

    func fetchRules() async throws -> [Rule] {
        let response: RulesResponse = try await apiClient.request(.getRules)
        return response.rules.enumerated().map { index, ruleData in
            Rule(
                id: "\(index)",
                type: RuleType(rawValue: ruleData.type) ?? .match,
                payload: ruleData.payload,
                proxy: ruleData.proxy
            )
        }
    }

    func toggleRule(index: Int, disabled: Bool) async throws {
        let _: EmptyResponse = try await apiClient.request(.toggleRule(index: index, disabled: disabled))
    }

    func fetchRuleProviders() async throws -> [RuleProvider] {
        let response: RuleProvidersResponse = try await apiClient.request(.getRuleProviders)
        return response.providers.map { name, data in
            RuleProvider(
                name: name,
                vehicleType: data.vehicleType,
                behavior: data.behavior,
                ruleCount: data.ruleCount,
                updatedAt: data.updatedAt
            )
        }
    }

    func updateRuleProvider(name: String) async throws {
        let _: EmptyResponse = try await apiClient.request(.updateRuleProvider(name: name))
    }
}

// MARK: - Response Types

struct RuleProvidersResponse: Decodable {
    let providers: [String: RuleProviderData]
}

struct RuleProviderData: Decodable {
    let vehicleType: String
    let behavior: String
    let ruleCount: Int
    let updatedAt: Date
}
