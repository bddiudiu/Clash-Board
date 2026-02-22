//
//  RuleListViewModel.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation
import Combine

final class RuleListViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var rules: [Rule] = []
    @Published private(set) var ruleProviders: [RuleProvider] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?

    // MARK: - Private Properties

    private let apiClient: APIClientProtocol

    // MARK: - Initialization

    init(apiClient: APIClientProtocol? = nil) {
        self.apiClient = apiClient ?? DIContainer.shared.resolve(APIClientProtocol.self)
    }

    // MARK: - Public Methods

    @MainActor
    func fetchRules() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let response: RulesResponse = try await apiClient.request(.getRules)
            rules = response.rules.enumerated().map { index, ruleData in
                Rule(
                    id: "\(index)",
                    type: RuleType(rawValue: ruleData.type) ?? .match,
                    payload: ruleData.payload,
                    proxy: ruleData.proxy
                )
            }
        } catch {
            self.error = error
        }
    }

    func toggleRule(at index: Int) {
        guard index < rules.count else { return }
        rules[index].isDisabled.toggle()

        Task { @MainActor in
            do {
                let _: EmptyResponse = try await apiClient.request(
                    .toggleRule(index: index, disabled: rules[index].isDisabled)
                )
            } catch {
                rules[index].isDisabled.toggle()
                self.error = error
            }
        }
    }
}

// MARK: - API Response Types

struct RulesResponse: Decodable {
    let rules: [RuleData]
}

struct RuleData: Decodable {
    let type: String
    let payload: String
    let proxy: String
}
