# 🚀 AI PPT Desktop - 一键启动

## 快速开始

### 最简单的方式

**macOS / Linux:**
```bash
./start
```

**Windows:**
```cmd
start.bat
```

**任何平台 (需要Python):**
```bash
python3 start.py
```

就这么简单！脚本会自动：
1. ✅ 检查 Flutter 环境
2. ✅ 安装项目依赖
3. ✅ 启动应用

---

## 命令选项

### 基本命令

| 命令 | 说明 | macOS/Linux | Windows | Python |
|------|------|-------------|---------|--------|
| (无) | 完整流程 | `./start` | `start.bat` | `python3 start.py` |
| setup | 仅安装依赖 | `./start setup` | `start.bat setup` | `python3 start.py setup` |
| run | 仅运行应用 | `./start run` | `start.bat run` | `python3 start.py run` |
| build | 构建发布版本 | `./start build` | `start.bat build` | `python3 start.py build` |
| test | 运行测试 | `./start test` | `start.bat test` | `python3 start.py test` |
| clean | 清理缓存 | `./start clean` | `start.bat clean` | `python3 start.py clean` |
| help | 显示帮助 | `./start help` | `start.bat help` | `python3 start.py help` |

---

## 使用场景

### 🆕 首次运行

第一次使用项目，需要安装所有依赖：

```bash
# macOS / Linux
./start

# Windows
start.bat

# Python
python3 start.py
```

脚本会自动：
1. 检查 Flutter 是否安装
2. 安装项目依赖
3. 启动应用

### 🔄 日常开发

依赖已安装，快速启动应用：

```bash
# macOS / Linux
./start run

# Windows
start.bat run

# Python
python3 start.py run
```

### 📦 构建发布版本

构建可分发的应用程序：

```bash
# macOS / Linux
./start build

# Windows
start.bat build

# Python
python3 start.py build
```

构建产物位置：
- **macOS**: `build/macos/Build/Products/Release/`
- **Windows**: `build/windows/x64/runner/Release/`
- **Linux**: `build/linux/x64/release/bundle/`
- **Web**: `build/web/`

### 🧪 运行测试

执行项目测试：

```bash
./start test
```

### 🧹 清理缓存

遇到问题时，清理缓存重新开始：

```bash
./start clean
./start setup
```

---

## 快捷方式

### macOS

1. **终端方式**:
   ```bash
   cd /path/to/ai-ppt-desktop
   ./start
   ```

2. **Finder 方式**:
   - 右键点击 `start` 文件
   - 选择 "打开方式" → "终端"

### Windows

1. **CMD 方式**:
   ```cmd
   cd C:\path\to\ai-ppt-desktop
   start.bat
   ```

2. **资源管理器方式**:
   - 双击 `start.bat` 文件

3. **PowerShell 方式**:
   ```powershell
   .\start.bat
   ```

### Linux

1. **终端方式**:
   ```bash
   cd /path/to/ai-ppt-desktop
   ./start
   ```

2. **文件管理器方式**:
   - 右键点击 `start` 文件
   - 选择 "在终端中运行"

---

## 环境要求

### 必需

- **Flutter**: 3.0.0 或更高版本
- **Dart**: 3.0.0 或更高版本
- **Git**: 任意版本

### 可选

- **Python**: 3.6+ (用于 start.py)
- **Make**: (用于 Makefile)

### 平台特定

**macOS:**
- Xcode 12+
- CocoaPods (自动安装)

**Windows:**
- Visual Studio 2019+ (带 C++ 桌面开发工作负载)

**Linux:**
- clang
- cmake
- ninja-build
- pkg-config
- libgtk-3-dev

---

## 常见问题

### Q: 提示 "Flutter 未安装"

**A:** 请先安装 Flutter:

```bash
# macOS
brew install --cask flutter

# Windows
choco install flutter
# 或
winget install Flutter.Flutter

# Linux
# 下载解压并添加到 PATH
```

### Q: 权限被拒绝 (macOS/Linux)

**A:** 添加执行权限：

```bash
chmod +x start
```

### Q: 依赖安装失败

**A:** 清理缓存后重试：

```bash
./start clean
./start setup
```

### Q: macOS 构建失败

**A:** 安装 Xcode 命令行工具：

```bash
xcode-select --install
```

### Q: Windows 构建失败

**A:** 确保安装了 Visual Studio 和 C++ 桌面开发工作负载。

---

## 高级用法

### 使用 Makefile

如果你安装了 `make`，也可以使用 Makefile：

```bash
make help    # 查看所有命令
make all     # 完整流程
make setup   # 仅安装依赖
make run     # 仅运行应用
make build   # 构建发布版本
make test    # 运行测试
make clean   # 清理缓存
```

### 使用详细脚本

如果需要更多控制，可以使用详细脚本：

```bash
# macOS / Linux
./scripts/setup_and_run.sh --help

# Windows
scripts\setup_and_run.bat --help
```

---

## 文件说明

```
ai-ppt-desktop/
├── start              # macOS/Linux 启动脚本
├── start.bat          # Windows 启动脚本
├── start.py           # Python 跨平台启动脚本
├── Makefile           # Make 构建配置
├── scripts/           # 详细脚本目录
│   ├── setup_and_run.sh     # macOS/Linux 详细脚本
│   ├── setup_and_run.bat    # Windows 批处理详细脚本
│   └── setup_and_run.ps1    # PowerShell 详细脚本
└── ...
```

---

## 获取帮助

```bash
./start help
```

或查看详细文档：
- [快速启动指南](QUICK_START.md)
- [开发指南](DEVELOPMENT_GUIDE.md)
- [技术栈](TECH_STACK.md)

---

**一句话启动**: `./start` (macOS/Linux) 或 `start.bat` (Windows)