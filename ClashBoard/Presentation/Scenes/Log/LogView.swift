//
//  LogView.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import SwiftUI

struct LogView: View {
    @StateObject private var viewModel = LogViewModel()
    @State private var searchText = ""
    @State private var autoScroll = true

    var body: some View {
        VStack(spacing: 0) {
            // 日志级别过滤器
            logLevelFilter

            Divider()

            // 日志列表
            if viewModel.logs.isEmpty {
                EmptyStateView(
                    icon: "doc.text",
                    title: "没有日志",
                    message: "等待日志数据...",
                    action: nil
                )
            } else {
                logList
            }
        }
        .navigationTitle("日志")
        .searchable(text: $searchText, prompt: "搜索日志")
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(action: { viewModel.isPaused.toggle() }) {
                    Image(systemName: viewModel.isPaused ? "play.fill" : "pause.fill")
                }

                Button(action: { viewModel.clearLogs() }) {
                    Image(systemName: "trash")
                }
            }
        }
        .onAppear {
            viewModel.startMonitoring()
        }
        .onDisappear {
            viewModel.stopMonitoring()
        }
    }

    // MARK: - Log Level Filter

    private var logLevelFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(LogLevel.allCases.filter { $0 != .silent }, id: \.self) { level in
                    Button(action: {
                        viewModel.toggleLevel(level)
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: level.icon)
                                .font(.caption2)
                            Text(level.displayName)
                                .font(.caption)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            viewModel.selectedLevels.contains(level)
                                ? Color(level.color).opacity(0.2)
                                : Color(.tertiarySystemGroupedBackground)
                        )
                        .foregroundColor(
                            viewModel.selectedLevels.contains(level)
                                ? Color(level.color)
                                : .secondary
                        )
                        .cornerRadius(16)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    // MARK: - Log List

    private var logList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 2) {
                    ForEach(filteredLogs) { log in
                        LogRow(log: log)
                            .id(log.id)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .onChange(of: viewModel.logs.count) { _, _ in
                if autoScroll, let lastLog = filteredLogs.last {
                    withAnimation {
                        proxy.scrollTo(lastLog.id, anchor: .bottom)
                    }
                }
            }
        }
        .font(.system(size: 13, design: .monospaced))
    }

    // MARK: - Computed Properties

    private var filteredLogs: [Log] {
        var result = viewModel.logs.filter { viewModel.selectedLevels.contains($0.type) }

        if !searchText.isEmpty {
            result = result.filter { $0.payload.localizedCaseInsensitiveContains(searchText) }
        }

        return result
    }
}

// MARK: - Log Row

struct LogRow: View {
    let log: Log

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(timeFormatter.string(from: log.timestamp))
                .font(.caption2.monospaced())
                .foregroundColor(.secondary)
                .frame(width: 56, alignment: .leading)

            Text(log.type.rawValue.prefix(1).uppercased())
                .font(.caption2.monospaced().bold())
                .foregroundColor(Color(log.type.color))
                .frame(width: 12)

            Text(log.payload)
                .font(.caption.monospaced())
                .foregroundColor(.primary)
                .textSelection(.enabled)
        }
        .padding(.vertical, 2)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        LogView()
    }
}
#endif
