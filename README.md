# Clash Board

<div align="center">

![iOS](https://img.shields.io/badge/iOS-26.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0-green.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

iOS native Clash proxy dashboard, inspired by [zashboard](https://github.com/zashboard/zashboard)

</div>

---

## Features

- **Overview** - Real-time upload/download speed chart, memory usage, active connections
- **Proxy** - Proxy group management, node switching, per-group latency testing
- **Connections** - Live connection list with speed calculation, swipe to close
- **Rules** - View and manage routing rules
- **Logs** - Real-time log stream with level filtering and search
- **Settings** - Live Clash config sync (mode, allow-lan, IPv6, TUN, DNS, log-level)
- **DNS Query** - Domain resolution testing
- **Multi-backend** - Manage multiple Clash backends
- **Dark Mode** - System / Light / Dark theme

## Project Structure

```
ClashBoard/
├── App/                       # App entry & coordinator
├── Core/
│   ├── Network/API/           # REST API client
│   ├── Network/WebSocket/     # WebSocket manager
│   ├── Storage/               # UserDefaults & Keychain
│   ├── DependencyInjection/   # DI container
│   └── Utils/                 # Formatters
├── Domain/
│   ├── Entities/              # Models
│   ├── UseCases/              # Business logic
│   └── Repositories/          # Protocols
├── Data/
│   ├── Repositories/          # Implementations
│   └── DataSources/           # Remote & local sources
├── Presentation/
│   └── Scenes/
│       ├── Overview/          # Dashboard + speed chart
│       ├── Proxy/             # Proxy groups & nodes
│       ├── Connection/        # Connection list
│       ├── More/              # Hub: rules, logs, DNS, providers
│       ├── Settings/          # Clash config & preferences
│       ├── Backend/           # Backend management
│       ├── Rule/              # Rule list
│       └── Log/               # Log viewer
└── Resources/
    ├── Assets.xcassets/       # App icon & assets
    └── Localizations/         # i18n
```

## Getting Started

### Requirements

- macOS 15.0+
- Xcode 26.0+
- iOS 26.0+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)

### Build

```bash
git clone https://github.com/bddiudiu/Clash-Board.git
cd Clash-Board
xcodegen generate
open ClashBoard.xcodeproj
```

Select a simulator or device, then `Cmd + R` to run.

### First Launch

1. Add a Clash backend (host, port, secret)
2. Tap "Test Connection" to verify
3. Save — you're in

## Architecture

MVVM + Clean Architecture

| Layer | Tech |
|-------|------|
| UI | SwiftUI |
| Reactive | Combine |
| Network | URLSession + WebSocket |
| Storage | UserDefaults + Keychain |
| DI | Custom container |

## License

MIT - see [LICENSE](LICENSE)

## Acknowledgments

- [zashboard](https://github.com/zashboard/zashboard)
- [Clash](https://github.com/Dreamacro/clash)
