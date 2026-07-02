# AI PPT Desktop - 快速启动指南

## 🚀 一键启动

本项目提供多种方式快速启动和部署，支持 macOS、Windows 和 Linux 平台。

## 📋 系统要求

| 平台 | 最低要求 | 推荐配置 |
|------|----------|----------|
| **macOS** | macOS 10.15+, Xcode 12+ | macOS 12+, Xcode 14+ |
| **Windows** | Windows 10+, Visual Studio 2019+ | Windows 11+, Visual Studio 2022 |
| **Linux** | Ubuntu 18.04+, Clang | Ubuntu 20.04+, Clang 12+ |
| **通用** | Flutter 3.0+, Dart 3.0+, Git | Flutter 3.24+, Dart 3.5+ |

## 🎯 快速开始

### 方式一：使用 Makefile（推荐）

```bash
# 查看所有可用命令
make help

# 完整流程：安装依赖 + 构建 + 运行
make all

# 或分步执行
make setup    # 安装依赖
make run      # 运行应用
make build    # 构建发布版本
make test     # 运行测试
```

### 方式二：使用平台脚本

#### macOS / Linux

```bash
# 添加执行权限
chmod +x scripts/setup_and_run.sh

# 完整流程
./scripts/setup_and_run.sh

# 或使用选项
./scripts/setup_and_run.sh --setup    # 仅安装依赖
./scripts/setup_and_run.sh --run      # 仅运行应用
./scripts/setup_and_run.sh --build    # 构建发布版本
./scripts/setup_and_run.sh --test     # 运行测试
./scripts/setup_and_run.sh --clean    # 清理缓存
./scripts/setup_and_run.sh --help     # 显示帮助
```

#### Windows (CMD)

```cmd
# 完整流程
scripts\setup_and_run.bat

# 或使用选项
scripts\setup_and_run.bat --setup    # 仅安装依赖
scripts\setup_and_run.bat --run      # 仅运行应用
scripts\setup_and_run.bat --build    # 构建发布版本
```

#### Windows (PowerShell)

```powershell
# 完整流程
.\scripts\setup_and_run.ps1

# 或使用选项
.\scripts\setup_and_run.ps1 -Setup    # 仅安装依赖
.\scripts\setup_and_run.ps1 -Run      # 仅运行应用
.\scripts\setup_and_run.ps1 -Build    # 构建发布版本
```

## 📦 常用命令速查

### 开发相关

```bash
# 安装依赖
make setup
# 或
flutter pub get

# 运行应用
make run
# 或
flutter run

# 运行特定平台
make run-macos      # macOS
make run-windows    # Windows
make run-linux      # Linux
make run-web        # Web (Chrome)
```

### 构建相关

```bash
# 构建当前平台
make build

# 构建特定平台
make build-macos    # macOS .app
make build-windows  # Windows .exe
make build-linux    # Linux 可执行文件
make build-web      # Web 应用
```

### 测试相关

```bash
# 运行所有测试
make test

# 运行单元测试
make test-unit

# 运行集成测试
make test-integration

# 生成覆盖率报告
make test-coverage
```

### 代码质量

```bash
# 格式化代码
make format

# 分析代码
make analyze

# 检查环境
make doctor
```

### 维护相关

```bash
# 清理构建缓存
make clean

# 升级依赖
make upgrade

# 检查过时依赖
make outdated

# 显示环境信息
make info
```

## 🔧 环境配置

### Flutter 安装

#### macOS
```bash
# 使用 Homebrew
brew install --cask flutter

# 或手动安装
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.24.0-stable.zip
unzip flutter_macos_arm64_3.24.0-stable.zip
export PATH="$PWD/flutter/bin:$PATH"
```

#### Windows
```powershell
# 使用 Chocolatey
choco install flutter

# 使用 winget
winget install Flutter.Flutter

# 或手动下载
# https://flutter.dev/docs/get-started/install/windows
```

#### Linux
```bash
# 手动安装
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.0-stable.tar.xz
tar xf flutter_linux_3.24.0-stable.tar.xz
export PATH="$PWD/flutter/bin:$PATH"
```

### 环境验证

```bash
# 检查 Flutter 环境
flutter doctor

# 检查项目依赖
flutter pub deps
```

## 🏗️ 项目结构

```
ai-ppt-desktop/
├── scripts/                    # 启动脚本
│   ├── setup_and_run.sh       # macOS/Linux 脚本
│   ├── setup_and_run.bat      # Windows 批处理脚本
│   └── setup_and_run.ps1      # PowerShell 脚本
├── lib/                        # 源代码
├── test/                       # 测试代码
├── docs/                       # 文档
├── Makefile                    # 构建配置
└── pubspec.yaml                # 项目配置
```

## 🐛 常见问题

### Q: Flutter 命令找不到

**A:** 确保 Flutter 已添加到 PATH 环境变量：

```bash
# macOS/Linux
export PATH="$PATH:/path/to/flutter/bin"

# Windows
set PATH=%PATH%;C:\path\to\flutter\bin
```

### Q: 依赖安装失败

**A:** 尝试清理缓存后重新安装：

```bash
make clean
make setup
```

### Q: macOS 构建失败

**A:** 确保安装了 Xcode 和 CocoaPods：

```bash
xcode-select --install
sudo gem install cocoapods
cd macos && pod install
```

### Q: Windows 构建失败

**A:** 确保安装了 Visual Studio 和 C++ 桌面开发工作负载。

### Q: 权限问题（macOS/Linux）

**A:** 添加执行权限：

```bash
chmod +x scripts/setup_and_run.sh
```

## 📚 更多资源

- **项目文档**: [docs/](docs/)
- **开发指南**: [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md)
- **技术栈**: [TECH_STACK.md](TECH_STACK.md)
- **测试报告**: [docs/full_functional_test_report.md](docs/full_functional_test_report.md)

## 🤝 贡献指南

1. Fork 项目
2. 创建功能分支: `git checkout -b feature/your-feature`
3. 提交更改: `git commit -m 'feat: add your feature'`
4. 推送分支: `git push origin feature/your-feature`
5. 创建 Pull Request

## 📄 许可证

本项目采用 MIT 许可证。

---

**快速开始**: `make all` 或 `./scripts/setup_and_run.sh`