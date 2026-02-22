//
//  BackendListView.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import SwiftUI

struct BackendListView: View {
    @StateObject private var viewModel = BackendListViewModel()
    @State private var showAddForm = false
    @State private var editingBackend: Backend?

    var body: some View {
        List {
            ForEach(viewModel.backends) { backend in
                BackendRow(
                    backend: backend,
                    isActive: backend.id == viewModel.activeBackendId,
                    onSelect: { viewModel.selectBackend(backend) },
                    onEdit: { editingBackend = backend },
                    onTest: { viewModel.testBackend(backend) }
                )
            }
            .onDelete { indexSet in
                for index in indexSet {
                    viewModel.deleteBackend(viewModel.backends[index])
                }
            }
        }
        .navigationTitle("后端管理")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showAddForm = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddForm) {
            NavigationStack {
                BackendFormView(isInitialSetup: false) {
                    showAddForm = false
                    viewModel.loadBackends()
                }
            }
        }
        .sheet(item: $editingBackend) { backend in
            NavigationStack {
                BackendFormView(backend: backend, isInitialSetup: false) {
                    editingBackend = nil
                    viewModel.loadBackends()
                }
            }
        }
        .onAppear {
            viewModel.loadBackends()
        }
    }
}

// MARK: - Backend Row

struct BackendRow: View {
    let backend: Backend
    let isActive: Bool
    let onSelect: () -> Void
    let onEdit: () -> Void
    let onTest: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                Image(systemName: isActive ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isActive ? .green : .secondary)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 4) {
                    Text(backend.label)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text("\(backend.host):\(backend.port)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text(backend.scheme.displayName)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.tertiarySystemGroupedBackground))
                    .cornerRadius(4)
            }
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(action: onEdit) {
                Label("编辑", systemImage: "pencil")
            }
            Button(action: onTest) {
                Label("测试连接", systemImage: "antenna.radiowaves.left.and.right")
            }
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        BackendListView()
    }
}
#endif
