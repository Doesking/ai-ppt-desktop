#!/bin/bash

# ============================================================
# AI PPT Desktop - macOS/Linux 一键启动脚本
# ============================================================
# 使用方法:
#   chmod +x scripts/setup_and_run.sh
#   ./scripts/setup_and_run.sh [选项]
#
# 选项:
#   --setup     仅安装依赖
#   --run       仅运行应用（假设依赖已安装）
#   --build     构建发布版本
#   --test      运行测试
#   --clean     清理构建缓存
#   --help      显示帮助信息
# ============================================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# 项目配置
PROJECT_NAME="AI PPT Desktop"
FLUTTER_MIN_VERSION="3.0.0"
DART_MIN_VERSION="3.0.0"

# 打印函数
print_banner() {
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║              AI PPT Desktop Application                   ║"
    echo "║              一键启动配置脚本                              ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_step() {
    echo -e "\n${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}  $1${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# 显示帮助信息
show_help() {
    print_banner
    echo "使用方法:"
    echo "  ./scripts/setup_and_run.sh [选项]"
    echo ""
    echo "选项:"
    echo "  --setup     仅安装依赖"
    echo "  --run       仅运行应用（假设依赖已安装）"
    echo "  --build     构建发布版本"
    echo "  --test      运行测试"
    echo "  --clean     清理构建缓存"
    echo "  --full      完整流程：安装依赖 + 构建 + 运行"
    echo "  --help      显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  ./scripts/setup_and_run.sh              # 完整流程"
    echo "  ./scripts/setup_and_run.sh --setup      # 仅安装依赖"
    echo "  ./scripts/setup_and_run.sh --run        # 仅运行应用"
    echo "  ./scripts/setup_and_run.sh --build      # 构建发布版本"
    echo "  ./scripts/setup_and_run.sh --test       # 运行测试"
}

# 检测操作系统
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        ARCH=$(uname -m)
        if [[ "$ARCH" == "arm64" ]]; then
            ARCH_TYPE="Apple Silicon"
        else
            ARCH_TYPE="Intel"
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        ARCH=$(uname -m)
        ARCH_TYPE="Linux"
    else
        OS="unknown"
        ARCH_TYPE="Unknown"
    fi
    print_status "操作系统: $OS ($ARCH_TYPE)"
}

# 检查命令是否存在
command_exists() {
    command -v "$1" &> /dev/null
}

# 版本比较
version_compare() {
    if [[ $1 == $2 ]]; then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++)); do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++)); do
        if [[ -z ${ver2[i]} ]]; then
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]})); then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]})); then
            return 2
        fi
    done
    return 0
}

# 检查并安装Flutter
check_flutter() {
    print_step "检查 Flutter 环境"
    
    if command_exists flutter; then
        FLUTTER_VERSION=$(flutter --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        print_success "Flutter 已安装: $FLUTTER_VERSION"
        
        # 检查版本
        version_compare "$FLUTTER_VERSION" "$FLUTTER_MIN_VERSION"
        if [[ $? -eq 2 ]]; then
            print_warning "Flutter 版本过低，建议升级到 $FLUTTER_MIN_VERSION 或更高版本"
        fi
    else
        print_warning "Flutter 未安装"
        
        read -p "是否自动安装 Flutter? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_flutter
        else
            print_error "请先安装 Flutter: https://flutter.dev/docs/get-started/install"
            exit 1
        fi
    fi
    
    # 检查Dart
    if command_exists dart; then
        DART_VERSION=$(dart --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        print_success "Dart 已安装: $DART_VERSION"
    else
        print_warning "Dart 未找到（通常随 Flutter 一起安装）"
    fi
}

# 安装Flutter
install_flutter() {
    print_status "正在安装 Flutter..."
    
    if [[ "$OS" == "macos" ]]; then
        if command_exists brew; then
            print_status "使用 Homebrew 安装 Flutter..."
            brew install --cask flutter
        else
            print_status "下载 Flutter SDK..."
            cd /tmp
            curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.24.0-stable.zip
            unzip -q flutter_macos_arm64_3.24.0-stable.zip
            sudo mv flutter /opt/flutter
            echo 'export PATH="/opt/flutter/bin:$PATH"' >> ~/.zshrc
            export PATH="/opt/flutter/bin:$PATH"
            rm flutter_macos_arm64_3.24.0-stable.zip
        fi
    elif [[ "$OS" == "linux" ]]; then
        print_status "下载 Flutter SDK..."
        cd /tmp
        curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.0-stable.tar.xz
        tar xf flutter_linux_3.24.0-stable.tar.xz
        sudo mv flutter /opt/flutter
        echo 'export PATH="/opt/flutter/bin:$PATH"' >> ~/.bashrc
        export PATH="/opt/flutter/bin:$PATH"
        rm flutter_linux_3.24.0-stable.tar.xz
    fi
    
    if command_exists flutter; then
        print_success "Flutter 安装成功"
    else
        print_error "Flutter 安装失败，请手动安装"
        exit 1
    fi
}

# 检查系统依赖
check_system_dependencies() {
    print_step "检查系统依赖"
    
    # 检查 Git
    if command_exists git; then
        print_success "Git 已安装: $(git --version)"
    else
        print_error "Git 未安装，请先安装 Git"
        exit 1
    fi
    
    # 检查 curl
    if command_exists curl; then
        print_success "curl 已安装"
    else
        print_warning "curl 未安装，某些功能可能受限"
    fi
    
    # macOS 特定检查
    if [[ "$OS" == "macos" ]]; then
        # 检查 Xcode
        if command_exists xcodebuild; then
            XCODE_VERSION=$(xcodebuild -version 2>/dev/null | head -1)
            print_success "Xcode 已安装: $XCODE_VERSION"
        else
            print_warning "Xcode 未安装，macOS 构建可能失败"
        fi
        
        # 检查 CocoaPods
        if command_exists pod; then
            print_success "CocoaPods 已安装"
        else
            print_warning "CocoaPods 未安装，正在安装..."
            sudo gem install cocoapods
        fi
    fi
    
    # Linux 特定检查
    if [[ "$OS" == "linux" ]]; then
        # 检查必要库
        local deps=("clang" "cmake" "ninja-build" "pkg-config" "libgtk-3-dev")
        for dep in "${deps[@]}"; do
            if dpkg -l | grep -q "$dep"; then
                print_success "$dep 已安装"
            else
                print_warning "$dep 未安装，正在安装..."
                sudo apt-get install -y "$dep"
            fi
        done
    fi
}

# 安装项目依赖
install_dependencies() {
    print_step "安装项目依赖"
    
    # 确保在项目根目录
    cd "$(dirname "$0")/.."
    
    # 清理缓存
    print_status "清理旧的构建缓存..."
    flutter clean 2>/dev/null || true
    
    # 获取依赖
    print_status "获取 Flutter 依赖..."
    flutter pub get
    
    if [[ $? -eq 0 ]]; then
        print_success "依赖安装成功"
    else
        print_error "依赖安装失败"
        exit 1
    fi
    
    # macOS 特定依赖
    if [[ "$OS" == "macos" ]]; then
        print_status "安装 macOS 特定依赖..."
        cd macos && pod install 2>/dev/null && cd ..
    fi
}

# 运行应用
run_app() {
    print_step "启动应用"
    
    cd "$(dirname "$0")/.."
    
    # 检测可用设备
    print_status "检测可用设备..."
    flutter devices
    
    # 选择设备
    if [[ "$OS" == "macos" ]]; then
        DEVICE="macos"
    elif [[ "$OS" == "linux" ]]; then
        DEVICE="linux"
    else
        DEVICE="chrome"
    fi
    
    print_status "使用设备: $DEVICE"
    print_status "正在启动 $PROJECT_NAME..."
    
    # 运行应用
    flutter run -d "$DEVICE" --hot
}

# 构建应用
build_app() {
    print_step "构建发布版本"
    
    cd "$(dirname "$0")/.."
    
    print_status "正在构建 $PROJECT_NAME..."
    
    if [[ "$OS" == "macos" ]]; then
        flutter build macos --release
        print_success "macOS 构建完成"
        print_status "构建产物: build/macos/Build/Products/Release/"
    elif [[ "$OS" == "linux" ]]; then
        flutter build linux --release
        print_success "Linux 构建完成"
        print_status "构建产物: build/linux/x64/release/bundle/"
    fi
    
    print_success "构建完成！"
}

# 运行测试
run_tests() {
    print_step "运行测试"
    
    cd "$(dirname "$0")/.."
    
    print_status "运行单元测试..."
    flutter test
    
    print_status "运行集成测试..."
    flutter test integration_test/
    
    print_success "所有测试完成"
}

# 清理构建缓存
clean_build() {
    print_step "清理构建缓存"
    
    cd "$(dirname "$0")/.."
    
    print_status "清理 Flutter 缓存..."
    flutter clean
    
    print_status "删除构建目录..."
    rm -rf build/
    rm -rf .dart_tool/
    
    if [[ "$OS" == "macos" ]]; then
        print_status "清理 macOS 构建缓存..."
        rm -rf macos/Pods/
        rm -rf macos/.symlinks/
        rm -rf macos/Flutter/ephemeral/
    fi
    
    print_success "清理完成"
}

# 显示环境信息
show_environment_info() {
    print_step "环境信息"
    
    echo -e "${CYAN}项目信息:${NC}"
    echo "  项目名称: $PROJECT_NAME"
    echo "  项目目录: $(pwd)"
    echo ""
    
    echo -e "${CYAN}系统信息:${NC}"
    echo "  操作系统: $OS ($ARCH_TYPE)"
    echo "  主机名: $(hostname)"
    echo "  用户: $(whoami)"
    echo ""
    
    if command_exists flutter; then
        echo -e "${CYAN}Flutter 信息:${NC}"
        flutter --version
        echo ""
    fi
    
    echo -e "${CYAN}磁盘空间:${NC}"
    df -h . | tail -1
}

# 完整流程
full_setup() {
    print_banner
    detect_os
    check_system_dependencies
    check_flutter
    show_environment_info
    install_dependencies
    build_app
    run_app
}

# 主函数
main() {
    # 切换到项目根目录
    cd "$(dirname "$0")/.."
    
    case "${1:-}" in
        --help|-h)
            show_help
            ;;
        --setup)
            print_banner
            detect_os
            check_system_dependencies
            check_flutter
            install_dependencies
            ;;
        --run)
            print_banner
            detect_os
            run_app
            ;;
        --build)
            print_banner
            detect_os
            build_app
            ;;
        --test)
            print_banner
            run_tests
            ;;
        --clean)
            print_banner
            clean_build
            ;;
        --full|"")
            full_setup
            ;;
        *)
            print_error "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
}

# 运行主函数
main "$@"