#!/usr/bin/env python3
"""
AI PPT Desktop - 跨平台一键启动脚本

使用方法:
    python3 start.py              启动应用（完整流程）
    python3 start.py setup        仅安装依赖
    python3 start.py run          仅运行应用
    python3 start.py build        构建发布版本
    python3 start.py test         运行测试
    python3 start.py clean        清理缓存
    python3 start.py help         显示帮助
"""

import os
import sys
import platform
import subprocess
import shutil
from pathlib import Path

# 颜色定义
class Colors:
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    MAGENTA = '\033[95m'
    NC = '\033[0m'  # No Color
    
    @classmethod
    def disable(cls):
        cls.RED = ''
        cls.GREEN = ''
        cls.YELLOW = ''
        cls.BLUE = ''
        cls.CYAN = ''
        cls.MAGENTA = ''
        cls.NC = ''

# Windows 不支持 ANSI 颜色
if platform.system() == 'Windows':
    Colors.disable()

def print_banner():
    """打印横幅"""
    print(f"""
{Colors.CYAN}╔════════════════════════════════════════════════════════════╗
║           🚀 AI PPT Desktop - 一键启动                   ║
╚════════════════════════════════════════════════════════════╝{Colors.NC}
""")

def print_status(msg):
    """打印状态信息"""
    print(f"{Colors.BLUE}[▶]{Colors.NC} {msg}")

def print_success(msg):
    """打印成功信息"""
    print(f"{Colors.GREEN}[✓]{Colors.NC} {msg}")

def print_error(msg):
    """打印错误信息"""
    print(f"{Colors.RED}[✗]{Colors.NC} {msg}")

def print_warning(msg):
    """打印警告信息"""
    print(f"{Colors.YELLOW}[!]{Colors.NC} {msg}")

def run_command(cmd, check=True):
    """运行命令"""
    try:
        result = subprocess.run(cmd, shell=True, check=check, cwd=get_project_dir())
        return result.returncode == 0
    except subprocess.CalledProcessError:
        return False
    except FileNotFoundError:
        return False

def get_project_dir():
    """获取项目目录"""
    return Path(__file__).parent.absolute()

def check_command(cmd):
    """检查命令是否存在"""
    return shutil.which(cmd) is not None

def get_os():
    """获取操作系统"""
    system = platform.system()
    if system == 'Darwin':
        return 'macos'
    elif system == 'Linux':
        return 'linux'
    elif system == 'Windows':
        return 'windows'
    else:
        return 'unknown'

def check_flutter():
    """检查Flutter环境"""
    if not check_command('flutter'):
        print_error("Flutter 未安装")
        print("""
请先安装 Flutter:
  macOS:   brew install --cask flutter
  Linux:   https://flutter.dev/docs/get-started/install/linux
  Windows: https://flutter.dev/docs/get-started/install/windows
""")
        return False
    
    try:
        result = subprocess.run(['flutter', '--version'], 
                              capture_output=True, text=True, timeout=30)
        version = result.stdout.split('\n')[0] if result.stdout else 'Unknown'
        print_success(f"Flutter: {version}")
        return True
    except Exception:
        print_warning("无法获取 Flutter 版本")
        return True

def install_deps():
    """安装依赖"""
    print_status("安装项目依赖...")
    if run_command('flutter pub get'):
        print_success("依赖安装完成")
        return True
    else:
        print_error("依赖安装失败")
        return False

def run_app():
    """运行应用"""
    print_status("启动应用...")
    
    os_type = get_os()
    
    # 自动选择设备
    if os_type == 'macos':
        device = 'macos'
    elif os_type == 'linux':
        device = 'linux'
    elif os_type == 'windows':
        device = 'windows'
    else:
        device = 'chrome'
    
    print_status(f"平台: {device}")
    return run_command(f'flutter run -d {device} --hot', check=False)

def build_app():
    """构建应用"""
    print_status("构建应用...")
    
    os_type = get_os()
    
    if os_type == 'macos':
        if run_command('flutter build macos --release'):
            print_success("构建完成: build/macos/Build/Products/Release/")
            return True
    elif os_type == 'linux':
        if run_command('flutter build linux --release'):
            print_success("构建完成: build/linux/x64/release/bundle/")
            return True
    elif os_type == 'windows':
        if run_command('flutter build windows --release'):
            print_success("构建完成: build/windows/x64/runner/Release/")
            return True
    else:
        if run_command('flutter build web --release'):
            print_success("构建完成: build/web/")
            return True
    
    return False

def run_tests():
    """运行测试"""
    print_status("运行测试...")
    if run_command('flutter test'):
        print_success("测试完成")
        return True
    return False

def clean_cache():
    """清理缓存"""
    print_status("清理缓存...")
    
    # 清理 Flutter 缓存
    run_command('flutter clean', check=False)
    
    # 删除构建目录
    project_dir = get_project_dir()
    build_dir = project_dir / 'build'
    dart_tool_dir = project_dir / '.dart_tool'
    
    if build_dir.exists():
        shutil.rmtree(build_dir)
    if dart_tool_dir.exists():
        shutil.rmtree(dart_tool_dir)
    
    print_success("清理完成")
    return True

def show_help():
    """显示帮助"""
    print_banner()
    print("""使用方法:
  python3 start.py [命令]

命令:
  (无参数)    完整流程：检查环境 + 安装依赖 + 运行应用
  setup       仅安装依赖
  run         仅运行应用
  build       构建发布版本
  test        运行测试
  clean       清理缓存
  help        显示此帮助

示例:
  python3 start.py          # 首次运行，自动安装依赖并启动
  python3 start.py run      # 快速启动（依赖已安装）
  python3 start.py build    # 构建发布版本

平台支持:
  macOS, Linux, Windows
""")

def full_setup():
    """完整流程"""
    print_banner()
    
    if not check_flutter():
        return False
    
    if not install_deps():
        return False
    
    return run_app()

def main():
    """主函数"""
    # 切换到项目目录
    os.chdir(get_project_dir())
    
    # 获取命令
    command = sys.argv[1] if len(sys.argv) > 1 else ''
    
    # 命令分发
    if command == '':
        success = full_setup()
    elif command == 'setup':
        print_banner()
        if check_flutter():
            success = install_deps()
        else:
            success = False
    elif command == 'run':
        print_banner()
        if check_flutter():
            success = run_app()
        else:
            success = False
    elif command == 'build':
        print_banner()
        if check_flutter():
            success = build_app()
        else:
            success = False
    elif command == 'test':
        print_banner()
        if check_flutter():
            success = run_tests()
        else:
            success = False
    elif command == 'clean':
        print_banner()
        success = clean_cache()
    elif command in ['help', '--help', '-h']:
        show_help()
        success = True
    else:
        print_error(f"未知命令: {command}")
        print()
        show_help()
        success = False
    
    # 返回退出码
    sys.exit(0 if success else 1)

if __name__ == '__main__':
    main()