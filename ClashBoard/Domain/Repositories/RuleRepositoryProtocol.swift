//
//  RuleRepositoryProtocol.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation

protocol RuleRepositoryProtocol {
    func fetchRules() async throws -> [Rule]
    func toggleRule(index: Int, disabled: Bool) async throws
    func fetchRuleProviders() async throws -> [RuleProvider]
    func updateRuleProvider(name: String) async throws
}
