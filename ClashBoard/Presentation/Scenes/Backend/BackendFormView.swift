//
//  BackendFormView.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import SwiftUI

struct BackendFormView: View {
    @Environment(\.dismiss) private var dismiss

    // MARK: - Properties

    let backend: Backend?
    let isInitialSetup: Bool
    let onComplete: () -> Void

    @State private var label = ""
    @State private var host = ""
    @State private var port = "9090"
    @State private var selectedProtocol: BackendScheme = .http
    @State private var secret = ""
    @State private var isTesting = false
    @State private var testResult: TestResult?

    // MARK: - Initialization

    init(
        backend: Backend? = nil,
        isInitialSetup: Bool = false,
        onComplete: @escaping () -> Void
    ) {
        self.backend = backend
        self.isInitialSetup = isInitialSetup
        self.onComplete = onComplete
    }

    var body: some View {
        Form {
            Section("基本信息") {
                TextField("名称", text: $label)
                    .textContentType(.name)

                TextField("主机地址", text: $host)
                    .textContentType(.URL)
                    .autocapitalization(.none)
                    .keyboardType(.URL)

                TextField("端口", text: $port)
                    .keyboardType(.numberPad)

                Picker("协议", selection: $selectedProtocol) {
                    ForEach(BackendScheme.allCases, id: \.self) { proto in
                        Text(proto.displayName).tag(proto)
                    }
                }
            }

            Section("认证") {
                SecureField("Secret（可选）", text: $secret)
                    .textContentType(.password)
            }

            Section {
                // 测试连接按钮
                Button(action: testConnection) {
                    HStack {
                        if isTesting {
                            ProgressView()
                                .scaleEffect(0.8)
                        }

                        Text("测试连接")

                        Spacer()

                        if let result = testResult {
                            Image(systemName: result.isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(result.isSuccess ? .green : .red)
                        }
                    }
                }
                .disabled(host.isEmpty || port.isEmpty || isTesting)
            }

            if let result = testResult, !result.isSuccess {
                Section {
                    Text(result.message)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle(backend == nil ? "添加后端" : "编辑后端")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if !isInitialSetup {
                    Button("取消") { dismiss() }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("保存") {
                    saveBackend()
                }
                .disabled(label.isEmpty || host.isEmpty || port.isEmpty)
                .fontWeight(.semibold)
            }
        }
        .onAppear {
            if let backend = backend {
                label = backend.label
                host = backend.host
                port = backend.port
                selectedProtocol = backend.scheme
                secret = backend.secret ?? ""
            }
        }
    }

    // MARK: - Methods

    private func testConnection() {
        isTesting = true
        testResult = nil

        let urlString = "\(selectedProtocol.rawValue)://\(host):\(port)/version"
        guard let url = URL(string: urlString) else {
            testResult = TestResult(isSuccess: false, message: "无效的 URL")
            isTesting = false
            return
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 5

        if !secret.isEmpty {
            request.setValue("Bearer \(secret)", forHTTPHeaderField: "Authorization")
        }

        Task { @MainActor in
            do {
                let (_, response) = try await URLSession.shared.data(for: request)
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    testResult = TestResult(isSuccess: true, message: "连接成功")
                } else {
                    testResult = TestResult(isSuccess: false, message: "服务器响应异常")
                }
            } catch {
                testResult = TestResult(isSuccess: false, message: error.localizedDescription)
            }
            isTesting = false
        }
    }

    private func saveBackend() {
        let storage = UserDefaultsStorage()

        var backends = storage.load([Backend].self, for: StorageKey.backends) ?? []

        if let existingBackend = backend {
            // 更新
            if let index = backends.firstIndex(where: { $0.id == existingBackend.id }) {
                backends[index] = Backend(
                    id: existingBackend.id,
                    label: label,
                    host: host,
                    port: port,
                    scheme: selectedProtocol,
                    secret: secret.isEmpty ? nil : secret,
                    isActive: existingBackend.isActive,
                    createdAt: existingBackend.createdAt,
                    updatedAt: Date()
                )
            }
        } else {
            // 新增
            let newBackend = Backend(
                label: label,
                host: host,
                port: port,
                scheme: selectedProtocol,
                secret: secret.isEmpty ? nil : secret,
                isActive: backends.isEmpty
            )
            backends.append(newBackend)

            // 如果是第一个后端，自动设为活跃
            if backends.count == 1 {
                storage.save(newBackend.id, for: StorageKey.activeBackendId)
            }
        }

        storage.save(backends, for: StorageKey.backends)
        onComplete()
    }
}

// MARK: - Test Result

struct TestResult {
    let isSuccess: Bool
    let message: String
}

#if DEBUG
#Preview {
    NavigationStack {
        BackendFormView(onComplete: {})
    }
}
#endif
