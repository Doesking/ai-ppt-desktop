# ============================================================
# AI PPT Desktop - Makefile
# ============================================================
# 使用方法:
#   make help          显示帮助信息
#   make setup         安装依赖
#   make run           运行应用
#   make build         构建发布版本
#   make test          运行测试
#   make clean         清理构建缓存
#   make all           完整流程
# ============================================================

# 变量定义
PROJECT_NAME = ai_ppt_desktop
FLUTTER = flutter
DART = dart

# 颜色定义
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
BLUE = \033[0;34m
CYAN = \033[0;36m
NC = \033[0m # No Color

# 检测操作系统
ifeq ($(OS),Windows_NT)
    DETECTED_OS = Windows
    SCRIPT_EXT = .bat
    SCRIPT_PATH = scripts\setup_and_run.bat
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Darwin)
        DETECTED_OS = macOS
    else
        DETECTED_OS = Linux
    endif
    SCRIPT_EXT = .sh
    SCRIPT_PATH = ./scripts/setup_and_run.sh
endif

# 默认目标
.DEFAULT_GOAL := help

# 帮助信息
.PHONY: help
help:
	@echo ""
	@echo "$(CYAN)╔════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(CYAN)║              AI PPT Desktop Application                   ║$(NC)"
	@echo "$(CYAN)║              Makefile 构建配置                             ║$(NC)"
	@echo "$(CYAN)╚════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(BLUE)使用方法:$(NC)"
	@echo "  make <目标>"
	@echo ""
	@echo "$(BLUE)可用目标:$(NC)"
	@echo "  $(GREEN)help$(NC)          显示此帮助信息"
	@echo "  $(GREEN)setup$(NC)         安装项目依赖"
	@echo "  $(GREEN)run$(NC)           运行应用"
	@echo "  $(GREEN)build$(NC)         构建发布版本"
	@echo "  $(GREEN)test$(NC)          运行测试"
	@echo "  $(GREEN)clean$(NC)         清理构建缓存"
	@echo "  $(GREEN)all$(NC)           完整流程：安装 + 构建 + 运行"
	@echo "  $(GREEN)info$(NC)          显示环境信息"
	@echo "  $(GREEN)doctor$(NC)        检查环境依赖"
	@echo "  $(GREEN)format$(NC)        格式化代码"
	@echo "  $(GREEN)analyze$(NC)       分析代码"
	@echo "  $(GREEN)upgrade$(NC)       升级依赖"
	@echo ""
	@echo "$(BLUE)平台特定目标:$(NC)"
	@echo "  $(GREEN)run-macos$(NC)     在 macOS 上运行"
	@echo "  $(GREEN)run-windows$(NC)   在 Windows 上运行"
	@echo "  $(GREEN)run-linux$(NC)     在 Linux 上运行"
	@echo "  $(GREEN)run-web$(NC)       在 Web 上运行"
	@echo "  $(GREEN)build-macos$(NC)   构建 macOS 版本"
	@echo "  $(GREEN)build-windows$(NC)       构建 Windows 版本"
	@echo "  $(GREEN)build-windows-portable$(NC) 构建 Windows 便携版 (.exe + ZIP)"
	@echo "  $(GREEN)build-linux$(NC)       构建 Linux 版本"
	@echo "  $(GREEN)build-web$(NC)     构建 Web 版本"
	@echo ""
	@echo "$(BLUE)当前系统:$(NC) $(DETECTED_OS)"
	@echo ""

# 安装依赖
.PHONY: setup
setup:
	@echo "$(BLUE)[INFO]$(NC) 安装项目依赖..."
	$(FLUTTER) clean
	$(FLUTTER) pub get
	@echo "$(GREEN)[✓]$(NC) 依赖安装完成"

# 运行应用
.PHONY: run
run:
	@echo "$(BLUE)[INFO]$(NC) 启动应用..."
	$(FLUTTER) run --hot

# 运行特定平台
.PHONY: run-macos
run-macos:
	@echo "$(BLUE)[INFO]$(NC) 在 macOS 上启动应用..."
	$(FLUTTER) run -d macos --hot

.PHONY: run-windows
run-windows:
	@echo "$(BLUE)[INFO]$(NC) 在 Windows 上启动应用..."
	$(FLUTTER) run -d windows --hot

.PHONY: run-linux
run-linux:
	@echo "$(BLUE)[INFO]$(NC) 在 Linux 上启动应用..."
	$(FLUTTER) run -d linux --hot

.PHONY: run-web
run-web:
	@echo "$(BLUE)[INFO]$(NC) 在 Web 上启动应用..."
	$(FLUTTER) run -d chrome --hot

# 构建应用
.PHONY: build
build:
	@echo "$(BLUE)[INFO]$(NC) 构建应用..."
	$(FLUTTER) build
	@echo "$(GREEN)[✓]$(NC) 构建完成"

# 构建特定平台
.PHONY: build-macos
build-macos:
	@echo "$(BLUE)[INFO]$(NC) 构建 macOS 版本..."
	$(FLUTTER) build macos --release
	@echo "$(GREEN)[✓]$(NC) macOS 构建完成"
	@echo "$(BLUE)[INFO]$(NC) 构建产物: build/macos/Build/Products/Release/"

.PHONY: build-windows
build-windows: ## 构建 Windows 版本 (在 Windows 上运行)
	@echo "$(BLUE)[INFO]$(NC) 构建 Windows 版本..."
	$(FLUTTER) build windows --release
	@echo "$(GREEN)[✓]$(NC) Windows 构建完成"
	@echo "$(BLUE)[INFO]$(NC) 构建产物: build/windows/x64/runner/Release/"

.PHONY: build-windows-portable
build-windows-portable: build-windows ## 构建 Windows 便携版 + 安装包
	@echo "$(BLUE)[INFO]$(NC) 打包 Windows 便携版..."
	@rm -rf dist/ai-ppt-desktop-windows-portable
	@mkdir -p dist/ai-ppt-desktop-windows-portable
	@cp -r build/windows/x64/runner/Release/* dist/ai-ppt-desktop-windows-portable/
	@echo "双击 ai_ppt_desktop.exe 启动应用" > dist/ai-ppt-desktop-windows-portable/使用说明.txt
	@echo "$(GREEN)[✓]$(NC) 便携版已生成: dist/ai-ppt-desktop-windows-portable/"
	@cd dist && powershell -Command "Compress-Archive -Path 'ai-ppt-desktop-windows-portable/*' -DestinationPath 'ai-ppt-desktop-windows-portable.zip' -Force" 2>/dev/null && \
		echo "$(GREEN)[✓]$(NC) ZIP 已生成: dist/ai-ppt-desktop-windows-portable.zip" || true

.PHONY: build-linux
build-linux:
	@echo "$(BLUE)[INFO]$(NC) 构建 Linux 版本..."
	$(FLUTTER) build linux --release
	@echo "$(GREEN)[✓]$(NC) Linux 构建完成"
	@echo "$(BLUE)[INFO]$(NC) 构建产物: build/linux/x64/release/bundle/"

.PHONY: build-web
build-web:
	@echo "$(BLUE)[INFO]$(NC) 构建 Web 版本..."
	$(FLUTTER) build web --release
	@echo "$(GREEN)[✓]$(NC) Web 构建完成"
	@echo "$(BLUE)[INFO]$(NC) 构建产物: build/web/"

# 运行测试
.PHONY: test
test:
	@echo "$(BLUE)[INFO]$(NC) 运行测试..."
	$(FLUTTER) test
	@echo "$(GREEN)[✓]$(NC) 测试完成"

.PHONY: test-unit
test-unit:
	@echo "$(BLUE)[INFO]$(NC) 运行单元测试..."
	$(FLUTTER) test test/unit/
	@echo "$(GREEN)[✓]$(NC) 单元测试完成"

.PHONY: test-integration
test-integration:
	@echo "$(BLUE)[INFO]$(NC) 运行集成测试..."
	$(FLUTTER) test integration_test/
	@echo "$(GREEN)[✓]$(NC) 集成测试完成"

.PHONY: test-coverage
test-coverage:
	@echo "$(BLUE)[INFO]$(NC) 运行测试并生成覆盖率报告..."
	$(FLUTTER) test --coverage
	genhtml coverage/lcov.info -o coverage/html
	@echo "$(GREEN)[✓]$(NC) 覆盖率报告已生成: coverage/html/index.html"

# 清理
.PHONY: clean
clean:
	@echo "$(BLUE)[INFO]$(NC) 清理构建缓存..."
	$(FLUTTER) clean
	rm -rf build/
	rm -rf .dart_tool/
	@echo "$(GREEN)[✓]$(NC) 清理完成"

# 完整流程
.PHONY: all
all: setup build run

# 环境信息
.PHONY: info
info:
	@echo ""
	@echo "$(CYAN)环境信息:$(NC)"
	@echo "  项目: $(PROJECT_NAME)"
	@echo "  系统: $(DETECTED_OS)"
	@echo ""
	@echo "$(CYAN)Flutter 信息:$(NC)"
	$(FLUTTER) --version
	@echo ""
	@echo "$(CYAN)Dart 信息:$(NC)"
	$(DART) --version

# 检查环境
.PHONY: doctor
doctor:
	@echo "$(BLUE)[INFO]$(NC) 检查环境依赖..."
	$(FLUTTER) doctor
	@echo ""
	@echo "$(BLUE)[INFO]$(NC) 检查项目依赖..."
	$(FLUTTER) pub deps

# 格式化代码
.PHONY: format
format:
	@echo "$(BLUE)[INFO]$(NC) 格式化代码..."
	$(DART) format lib/ test/
	@echo "$(GREEN)[✓]$(NC) 代码格式化完成"

# 分析代码
.PHONY: analyze
analyze:
	@echo "$(BLUE)[INFO]$(NC) 分析代码..."
	$(FLUTTER) analyze
	@echo "$(GREEN)[✓]$(NC) 代码分析完成"

# 升级依赖
.PHONY: upgrade
upgrade:
	@echo "$(BLUE)[INFO]$(NC) 升级依赖..."
	$(FLUTTER) pub upgrade
	@echo "$(GREEN)[✓]$(NC) 依赖升级完成"

# 检查过时依赖
.PHONY: outdated
outdated:
	@echo "$(BLUE)[INFO]$(NC) 检查过时依赖..."
	$(FLUTTER) pub outdated

# 生成文档
.PHONY: docs
docs:
	@echo "$(BLUE)[INFO]$(NC) 生成文档..."
	$(DART) doc
	@echo "$(GREEN)[✓]$(NC) 文档生成完成"

# 运行脚本
.PHONY: script-setup
script-setup:
	@echo "$(BLUE)[INFO]$(NC) 运行一键启动脚本..."
	$(SCRIPT_PATH) --setup

.PHONY: script-run
script-run:
	@echo "$(BLUE)[INFO]$(NC) 运行一键启动脚本..."
	$(SCRIPT_PATH) --run

.PHONY: script-build
script-build:
	@echo "$(BLUE)[INFO]$(NC) 运行一键启动脚本..."
	$(SCRIPT_PATH) --build

.PHONY: script-full
script-full:
	@echo "$(BLUE)[INFO]$(NC) 运行一键启动脚本..."
	$(SCRIPT_PATH)

# Git 操作
.PHONY: git-status
git-status:
	@echo "$(BLUE)[INFO]$(NC) Git 状态:"
	@git status

.PHONY: git-commit
git-commit:
	@echo "$(BLUE)[INFO]$(NC) 提交代码..."
	@git add .
	@git status
	@read -p "输入提交信息: " msg; \
	git commit -m "$$msg"

.PHONY: git-push
git-push:
	@echo "$(BLUE)[INFO]$(NC) 推送代码..."
	@git push

# 打包
.PHONY: package
package: clean build
	@echo "$(BLUE)[INFO]$(NC) 打包应用..."
	@if [ "$(DETECTED_OS)" = "macOS" ]; then \
		cd build/macos/Build/Products/Release && \
		tar -czf ../../../../../$(PROJECT_NAME)-macos.tar.gz *.app; \
	elif [ "$(DETECTED_OS)" = "Linux" ]; then \
		cd build/linux/x64/release/bundle && \
		tar -czf ../../../../../$(PROJECT_NAME)-linux.tar.gz *; \
	fi
	@echo "$(GREEN)[✓]$(NC) 打包完成"

# 发布
.PHONY: release
release:
	@echo "$(BLUE)[INFO]$(NC) 执行发布流程..."
	./scripts/release.sh

# 伪目标声明
.PHONY: all build clean run test help info doctor format analyze upgrade outdated docs package release