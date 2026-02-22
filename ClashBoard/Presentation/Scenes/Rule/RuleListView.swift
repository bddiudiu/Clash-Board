//
//  RuleListView.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import SwiftUI

struct RuleListView: View {
    @StateObject private var viewModel = RuleListViewModel()
    @State private var searchText = ""

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.rules.isEmpty {
                LoadingView()
            } else if viewModel.rules.isEmpty {
                EmptyStateView(
                    icon: "list.bullet",
                    title: "没有规则",
                    message: "请检查后端配置",
                    action: { Task { await viewModel.fetchRules() } }
                )
            } else {
                ruleList
            }
        }
        .navigationTitle("规则")
        .searchable(text: $searchText, prompt: "搜索规则")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Text("\(filteredRules.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.tertiarySystemGroupedBackground))
                    .cornerRadius(8)
            }
        }
        .refreshable {
            await viewModel.fetchRules()
        }
        .task {
            await viewModel.fetchRules()
        }
    }

    // MARK: - Rule List

    private var ruleList: some View {
        List(filteredRules) { rule in
            HStack(spacing: 12) {
                Image(systemName: rule.type.icon)
                    .foregroundColor(Color(rule.type.color))
                    .font(.body)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 4) {
                    Text(rule.payload)
                        .font(.subheadline)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        Text(rule.type.rawValue)
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        Text(rule.proxy)
                            .font(.caption2)
                            .foregroundColor(.accentColor)
                    }
                }

                Spacer()

                if rule.hitCount > 0 {
                    Text("\(rule.hitCount)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .monospacedDigit()
                }
            }
            .padding(.vertical, 2)
        }
        .listStyle(.plain)
    }

    // MARK: - Computed Properties

    private var filteredRules: [Rule] {
        if searchText.isEmpty {
            return viewModel.rules
        }
        return viewModel.rules.filter { rule in
            rule.payload.localizedCaseInsensitiveContains(searchText) ||
            rule.type.rawValue.localizedCaseInsensitiveContains(searchText) ||
            rule.proxy.localizedCaseInsensitiveContains(searchText)
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        RuleListView()
    }
}
#endif
