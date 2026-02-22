# Contributing to Merlin Clash iOS

感谢您对 Merlin Clash iOS 项目的关注！我们欢迎任何形式的贡献。

## 📋 目录

- [行为准则](#行为准则)
- [如何贡献](#如何贡献)
- [开发流程](#开发流程)
- [代码规范](#代码规范)
- [提交规范](#提交规范)
- [问题反馈](#问题反馈)

---

## 行为准则

### 我们的承诺

为了营造一个开放和友好的环境，我们承诺：

- 使用友好和包容的语言
- 尊重不同的观点和经验
- 优雅地接受建设性批评
- 关注对社区最有利的事情
- 对其他社区成员表示同理心

### 不可接受的行为

- 使用性化的语言或图像
- 人身攻击或侮辱性评论
- 公开或私下的骚扰
- 未经许可发布他人的私人信息
- 其他不道德或不专业的行为

---

## 如何贡献

### 报告 Bug

如果您发现了 Bug，请：

1. 检查 [Issues](https://github.com/merlin-clash/ios/issues) 是否已有相同问题
2. 如果没有，创建新 Issue，包含：
   - 清晰的标题和描述
   - 重现步骤
   - 预期行为和实际行为
   - 截图（如果适用）
   - 设备信息（iOS 版本、设备型号）
   - 应用版本

### 建议新功能

如果您有新功能建议：

1. 检查 [Issues](https://github.com/merlin-clash/ios/issues) 是否已有类似建议
2. 创建新 Issue，标记为 `enhancement`
3. 详细描述功能需求和使用场景
4. 如果可能，提供设计草图或原型

### 提交代码

1. Fork 本仓库
2. 创建特性分支
3. 编写代码和测试
4. 提交 Pull Request

---

## 开发流程

### 1. 环境准备

```bash
# 克隆仓库
git clone https://github.com/YOUR_USERNAME/merlin-clash-ios.git
cd merlin-clash-ios

# 安装依赖（如果有）
# pod install  # 如果使用 CocoaPods
```

### 2. 创建分支

```bash
# 从 main 分支创建新分支
git checkout -b feature/your-feature-name

# 或修复 Bug
git checkout -b fix/bug-description
```

### 3. 开发

- 遵循代码规范
- 编写清晰的注释
- 添加必要的测试
- 保持提交粒度合理

### 4. 测试

```bash
# 运行单元测试
# Cmd + U in Xcode

# 运行 UI 测试
# Cmd + U in Xcode (UI Tests scheme)

# 运行 SwiftLint
swiftlint
```

### 5. 提交

```bash
# 添加更改
git add .

# 提交（遵循提交规范）
git commit -m "feat: add new feature"

# 推送到远程
git push origin feature/your-feature-name
```

### 6. 创建 Pull Request

1. 访问 GitHub 仓库
2. 点击 "New Pull Request"
3. 选择您的分支
4. 填写 PR 描述：
   - 更改内容
   - 相关 Issue
   - 测试情况
   - 截图（如果适用）
5. 提交 PR

---

## 代码规范

### Swift 代码风格

遵循 [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)

#### 命名规范

```swift
// 类型：PascalCase
class ProxyManager { }
struct ProxyGroup { }
enum LogLevel { }

// 变量和函数：camelCase
var proxyList: [Proxy] = []
func fetchProxies() { }

// 常量：camelCase
let maxRetryCount = 3
let defaultTimeout: TimeInterval = 30

// 协议：名词或形容词
protocol ProxyRepositoryProtocol { }
protocol Loadable { }
```

#### 代码组织

```swift
// MARK: - Properties
// MARK: - Initialization
// MARK: - Lifecycle
// MARK: - Public Methods
// MARK: - Private Methods
// MARK: - Actions
```

#### 注释规范

```swift
/// 获取代理列表
///
/// - Returns: 代理组数组
/// - Throws: NetworkError 如果网络请求失败
func fetchProxies() async throws -> [ProxyGroup] {
    // 实现
}
```

### SwiftUI 规范

```swift
struct MyView: View {
    // MARK: - Properties
    @StateObject private var viewModel = MyViewModel()
    @State private var isPresented = false

    // MARK: - Body
    var body: some View {
        content
    }

    // MARK: - Views
    private var content: some View {
        VStack {
            // 内容
        }
    }
}
```

### SwiftLint

项目使用 SwiftLint 进行代码检查：

```bash
# 安装 SwiftLint
brew install swiftlint

# 运行检查
swiftlint

# 自动修复
swiftlint --fix
```

---

## 提交规范

### Commit Message 格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type 类型

- `feat`: 新功能
- `fix`: 修复 Bug
- `docs`: 文档更新
- `style`: 代码格式（不影响代码运行）
- `refactor`: 重构
- `perf`: 性能优化
- `test`: 测试相关
- `chore`: 构建/工具相关
- `revert`: 回滚

### 示例

```bash
# 新功能
git commit -m "feat(proxy): add latency test feature"

# 修复 Bug
git commit -m "fix(connection): fix connection list crash"

# 文档更新
git commit -m "docs: update README with installation guide"

# 重构
git commit -m "refactor(network): simplify API client implementation"
```

---

## 问题反馈

### Bug 报告模板

```markdown
**描述**
简要描述 Bug

**重现步骤**
1. 打开应用
2. 点击 xxx
3. 看到错误

**预期行为**
应该发生什么

**实际行为**
实际发生了什么

**截图**
如果适用，添加截图

**环境**
- iOS 版本：
- 设备型号：
- 应用版本：

**额外信息**
其他相关信息
```

### 功能建议模板

```markdown
**功能描述**
清晰简洁地描述您想要的功能

**使用场景**
描述这个功能的使用场景

**替代方案**
描述您考虑过的替代方案

**额外信息**
其他相关信息或截图
```

---

## Pull Request 检查清单

提交 PR 前，请确保：

- [ ] 代码遵循项目规范
- [ ] 通过 SwiftLint 检查
- [ ] 添加必要的注释
- [ ] 编写单元测试
- [ ] 所有测试通过
- [ ] 更新相关文档
- [ ] PR 描述清晰完整
- [ ] 关联相关 Issue

---

## 代码审查

### 审查重点

1. **代码质量**
   - 是否遵循规范
   - 是否有明显的 Bug
   - 是否有性能问题

2. **架构设计**
   - 是否符合项目架构
   - 是否有过度设计
   - 是否易于维护

3. **测试覆盖**
   - 是否有足够的测试
   - 测试是否有效

4. **文档完整性**
   - 是否更新了文档
   - 注释是否清晰

### 审查流程

1. 自动检查（CI/CD）
2. 代码审查（至少 1 人）
3. 测试验证
4. 合并到主分支

---

## 发布流程

### 版本号规范

遵循 [语义化版本](https://semver.org/lang/zh-CN/)：

- **主版本号**：不兼容的 API 修改
- **次版本号**：向下兼容的功能性新增
- **修订号**：向下兼容的问题修正

示例：`1.2.3`

### 发布步骤

1. 更新版本号
2. 更新 CHANGELOG
3. 创建 Release Tag
4. 构建和测试
5. 提交到 App Store
6. 发布 Release Notes

---

## 获取帮助

如果您有任何问题：

- 查看 [文档](https://github.com/merlin-clash/ios/wiki)
- 搜索 [Issues](https://github.com/merlin-clash/ios/issues)
- 加入 [讨论区](https://github.com/merlin-clash/ios/discussions)
- 联系维护者

---

## 致谢

感谢所有贡献者的付出！

您的贡献将被记录在 [Contributors](https://github.com/merlin-clash/ios/graphs/contributors) 页面。

---

**再次感谢您的贡献！** 🎉
