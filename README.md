# AI PPT Desktop

> 🎯 一款基于 Flutter Desktop 的 AI 驱动演示文稿制作工具，面向企业团队，让每一份 PPT 都专业高效。

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/Platform-macOS%20%7C%20Windows%20%7C%20Linux-brightgreen" alt="Platform">
  <img src="https://img.shields.io/badge/AI-TensorFlow%20Lite-FF6F00?logo=tensorflow" alt="AI Engine">
  <img src="https://img.shields.io/badge/License-MIT-blue" alt="License">
</p>

---

## ✨ 核心功能

### 🤖 AI 智能生成
- **一键生成 PPT**：输入主题，AI 自动规划结构、撰写内容、生成完整演示文稿
- **多种内容风格**：商务汇报、学术课件、产品介绍、创意展示 — 选择风格即刻生成
- **智能演讲备注**：为每张幻灯片自动生成演讲要点和引导话术

### 🎤 语音转 PPT
- **实时录音**：直接在应用内录制演讲音频，AI 自动提取关键信息生成幻灯片
- **音频导入**：支持导入已有音频文件，自动识别语音内容并结构化

### 🎬 视频转 PPT
- **智能提取**：导入视频文件，AI 提取音频轨道和关键帧，自动生成对应的幻灯片
- **多格式支持**：兼容 MP4、AVI、MOV 等主流视频格式

### 🎨 智能模板推荐
- **内容匹配**：基于生成内容的主题和风格，自动推荐最合适的 PPT 模板
- **企业品牌库**：支持导入和管理企业品牌模板，确保输出一致性

### 👥 团队协作
- **多人实时编辑**：支持团队成员同时编辑同一份演示文稿
- **评论与反馈**：内置评论系统，方便团队沟通修改意见

### 🏢 企业品牌管理
- **品牌配置**：定义企业专属配色方案、字体规范、Logo 样式
- **一键应用**：将品牌规范一键应用到所有幻灯片，确保视觉统一
- **品牌导入/导出**：支持 JSON 格式的品牌配置文件导入导出

### 📦 多格式导出
- **PPTX**：标准 PowerPoint 格式，完美兼容 Microsoft Office
- **Markdown**：纯文本导出，方便二次编辑和分享

---

## 🏗️ 技术架构

```
┌─────────────────────────────────────────────────┐
│              表现层 (Flutter Desktop UI)          │
│    Riverpod 状态管理 · Google Fonts · 动画系统    │
├─────────────────────────────────────────────────┤
│              业务逻辑层                           │
│  PPT 服务 · 音频服务 · 视频服务 · 品牌服务 · 协作  │
├─────────────────────────────────────────────────┤
│              AI 引擎层                           │
│  TensorFlow Lite · ONNX Runtime · 本地模型推理   │
├─────────────────────────────────────────────────┤
│              数据层                               │
│  Hive (KV) · SQLite (关系) · 本地文件系统         │
└─────────────────────────────────────────────────┘
```

| 模块 | 技术选型 |
|------|---------|
| 框架 | Flutter Desktop (macOS / Windows / Linux) |
| 语言 | Dart 3.x |
| 状态管理 | Riverpod |
| 本地存储 | Hive + SQLite |
| AI 推理 | TensorFlow Lite + ONNX Runtime |
| PPT 生成 | flutter_pptx / dart_pptx |
| 音频处理 | flutter_sound + just_audio |
| 视频处理 | video_player |
| 窗口管理 | window_manager |

---

## 🚀 快速开始

### 环境要求

| 依赖 | 版本 | 说明 |
|------|------|------|
| Flutter SDK | ≥ 3.10 | `flutter --version` 查看 |
| Dart SDK | ≥ 3.0 | 随 Flutter 自带 |
| Xcode | 最新版 | macOS 开发必需（仅 macOS） |
| Visual Studio | 最新版 | Windows 开发必需，需安装 C++ 桌面开发工作负载（仅 Windows） |

### 方式一：一键启动（推荐）

```bash
# 克隆项目
git clone https://github.com/Doesking/ai-ppt-desktop.git
cd ai-ppt-desktop

# 赋予执行权限并运行
chmod +x start
./start
```

脚本会自动检测环境、安装依赖、启动应用。

### 方式二：手动运行

```bash
# 安装依赖
flutter pub get

# 启动应用（自动检测当前平台）
flutter run -d macos    # macOS
flutter run -d windows  # Windows
flutter run -d linux    # Linux
```

### 方式三：Makefile

```bash
make setup    # 安装依赖
make run      # 启动应用
make build    # 构建发布版本
make test     # 运行测试
```

---

## 📖 使用指南

### 1. 创建 AI PPT

1. 启动应用，进入 **Editor** 页面
2. 在左侧输入 **主题**（如 "2026年度市场分析报告"）
3. 选择 **内容风格**：Business / Academic / Creative / Minimalist
4. 调整 **幻灯片数量**（5-20 张）
5. 可选：在内容框中输入额外指令或大纲
6. 点击 **Generate with AI** 按钮
7. 等待 AI 生成完成，中间区域预览所有幻灯片
8. 右侧面板查看幻灯片列表和属性
9. 点击 **Save as PPTX** 导出文件

### 2. 语音转 PPT

1. 进入 **Voice** 页面
2. 点击 **Start Recording** 开始录音
3. 完成演讲后停止录音
4. AI 自动识别语音内容并生成幻灯片
5. 也可点击 **Import Audio** 导入已有音频文件

### 3. 视频转 PPT

1. 进入 **Video** 页面
2. 点击 **Import Video** 选择视频文件
3. AI 自动提取音频和关键帧
4. 生成对应的演示文稿

### 4. 品牌管理

1. 进入 **Brands** 页面
2. 创建新品牌配置：设置配色、字体、Logo
3. 应用品牌到 PPT，确保输出符合企业规范
4. 支持导入/导出品牌配置文件

### 5. 团队协作

1. 进入 **Collaborate** 页面
2. 邀请团队成员加入
3. 多人实时编辑、评论、反馈

---

## 📦 构建发布版本

```bash
# macOS
flutter build macos --release
# 产物路径: build/macos/Build/Products/Release/

# Windows
flutter build windows --release
# 产物路径: build/windows/x64/runner/Release/

# Linux
flutter build linux --release
# 产物路径: build/linux/x64/release/bundle/
```

---

## 🧪 测试

```bash
# 运行全部测试
flutter test

# 运行单元测试
flutter test test/unit/

# 运行集成测试
flutter test integration_test/

# 生成覆盖率报告
flutter test --coverage
```

---

## 📁 项目结构

```
ai-ppt-desktop/
├── lib/
│   ├── main.dart                    # 应用入口
│   ├── app.dart                     # MaterialApp 配置
│   ├── ai/                          # AI 功能模块
│   │   ├── engines/                 # AI 引擎 (TFLite / AI Engine)
│   │   ├── models/                  # 模型管理器
│   │   └── processors/              # 内容生成 · 模板推荐 · 语音/视频转 PPT
│   ├── core/                        # 核心基础设施
│   │   ├── config/                  # 应用配置
│   │   ├── constants/               # 常量定义
│   │   ├── services/                # 错误处理 · 性能监控
│   │   └── theme/                   # UI 主题
│   ├── data/                        # 数据服务层
│   │   └── services/                # PPT · 音频 · 视频 · 品牌 · 协作
│   └── presentation/                # UI 表现层
│       └── pages/                   # 首页 · 编辑器 · 设置 · 品牌 · 协作 · 帮助
├── test/                            # 测试代码
├── assets/                          # 资源文件 (模型 · 模板 · 字体 · 图片)
├── scripts/                         # 构建和发布脚本
├── docs/                            # 项目文档
├── preview/                         # Web 预览页面
├── start                            # 一键启动脚本 (macOS/Linux)
├── start.bat                        # 一键启动脚本 (Windows)
├── start.py                         # 一键启动脚本 (跨平台)
├── Makefile                         # Make 构建配置
└── pubspec.yaml                     # 依赖配置
```

---

## 🛠️ 开发指南

### 新增功能

```bash
# 创建功能分支
git checkout -b feature/your-feature

# 开发完成后
git add .
git commit -m "feat: your feature description"
git push origin feature/your-feature
```

### 代码规范

- 遵循 Dart 官方代码规范
- 使用 `flutter_lints` 进行代码检查
- 保持单一职责原则
- 提交信息遵循 [Conventional Commits](https://www.conventionalcommits.org/)

---

## 🤝 贡献

欢迎贡献代码、报告 Bug、提出新功能建议！

1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'feat: add amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 创建 Pull Request

---

## 📄 许可证

本项目基于 [MIT License](LICENSE) 开源。

---

<p align="center">
  <sub>Made with ❤️ by <a href="https://github.com/Doesking">Doesking</a></sub>
</p>
