@echo off
setlocal enabledelayedexpansion

:: ============================================================
:: AI PPT Desktop - Windows 一键启动脚本 (批处理版本)
:: ============================================================
:: 使用方法:
::   scripts\setup_and_run.bat [选项]
::
:: 选项:
::   --setup     仅安装依赖
::   --run       仅运行应用
::   --build     构建发布版本
::   --test      运行测试
::   --clean     清理构建缓存
::   --help      显示帮助信息
:: ============================================================

title AI PPT Desktop - 一键启动

:: 颜色代码
set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "CYAN=[96m"
set "MAGENTA=[95m"
set "NC=[0m"

:: 项目配置
set "PROJECT_NAME=AI PPT Desktop"
set "FLUTTER_MIN_VERSION=3.0.0"

:: 显示横幅
:print_banner
echo.
echo %CYAN%╔════════════════════════════════════════════════════════════╗%NC%
echo %CYAN%║              AI PPT Desktop Application                   ║%NC%
echo %CYAN%║              Windows 一键启动脚本                          ║%NC%
echo %CYAN%╚════════════════════════════════════════════════════════════╝%NC%
echo.
goto :eof

:: 显示帮助
:show_help
call :print_banner
echo 使用方法:
echo   scripts\setup_and_run.bat [选项]
echo.
echo 选项:
echo   --setup     仅安装依赖
echo   --run       仅运行应用
echo   --build     构建发布版本
echo   --test      运行测试
echo   --clean     清理构建缓存
echo   --full      完整流程：安装依赖 + 构建 + 运行
echo   --help      显示此帮助信息
echo.
echo 示例:
echo   scripts\setup_and_run.bat              # 完整流程
echo   scripts\setup_and_run.bat --setup      # 仅安装依赖
echo   scripts\setup_and_run.bat --run        # 仅运行应用
goto :eof

:: 打印状态信息
:print_status
echo %BLUE%[INFO]%NC% %~1
goto :eof

:print_success
echo %GREEN%[✓]%NC% %~1
goto :eof

:print_warning
echo %YELLOW%[!]%NC% %~1
goto :eof

:print_error
echo %RED%[✗]%NC% %~1
goto :eof

:print_step
echo.
echo %MAGENTA%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%NC%
echo %MAGENTA%  %~1%NC%
echo %MAGENTA%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%NC%
goto :eof

:: 检查命令是否存在
:check_command
where %~1 >nul 2>&1
if %errorlevel% equ 0 (
    exit /b 0
) else (
    exit /b 1
)

:: 检查Flutter环境
:check_flutter
call :print_step "检查 Flutter 环境"

call :check_command flutter
if %errorlevel% equ 0 (
    for /f "tokens=3" %%i in ('flutter --version 2^>nul ^| findstr /C:"Flutter"') do set "FLUTTER_VERSION=%%i"
    call :print_success "Flutter 已安装: !FLUTTER_VERSION!"
) else (
    call :print_warning "Flutter 未安装"
    echo.
    set /p "INSTALL_FLUTTER=是否自动安装 Flutter? (y/n): "
    if /i "!INSTALL_FLUTTER!"=="y" (
        call :install_flutter
    ) else (
        call :print_error "请先安装 Flutter: https://flutter.dev/docs/get-started/install"
        exit /b 1
    )
)

:: 检查Dart
call :check_command dart
if %errorlevel% equ 0 (
    for /f "tokens=4" %%i in ('dart --version 2^>nul') do set "DART_VERSION=%%i"
    call :print_success "Dart 已安装: !DART_VERSION!"
) else (
    call :print_warning "Dart 未找到"
)
goto :eof

:: 安装Flutter
:install_flutter
call :print_status "正在安装 Flutter..."

:: 检查是否安装了Chocolatey
call :check_command choco
if %errorlevel% equ 0 (
    call :print_status "使用 Chocolatey 安装 Flutter..."
    choco install flutter -y
) else (
    call :print_warning "Chocolatey 未安装"
    echo.
    echo 请手动安装 Flutter:
    echo 1. 访问 https://flutter.dev/docs/get-started/install/windows
    echo 2. 下载 Flutter SDK
    echo 3. 解压到 C:\flutter
    echo 4. 将 C:\flutter\bin 添加到 PATH 环境变量
    echo.
    pause
    exit /b 1
)

call :check_command flutter
if %errorlevel% equ 0 (
    call :print_success "Flutter 安装成功"
) else (
    call :print_error "Flutter 安装失败，请手动安装"
    exit /b 1
)
goto :eof

:: 检查系统依赖
:check_system_dependencies
call :print_step "检查系统依赖"

:: 检查 Git
call :check_command git
if %errorlevel% equ 0 (
    call :print_success "Git 已安装"
) else (
    call :print_error "Git 未安装，请先安装 Git: https://git-scm.com/download/win"
    exit /b 1
)

:: 检查 Visual Studio
if exist "C:\Program Files\Microsoft Visual Studio\2022" (
    call :print_success "Visual Studio 2022 已安装"
) else if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019" (
    call :print_success "Visual Studio 2019 已安装"
) else (
    call :print_warning "Visual Studio 未安装"
    echo Windows 构建需要 Visual Studio 和 C++ 桌面开发工作负载
    echo 下载地址: https://visualstudio.microsoft.com/downloads/
)

:: 检查 Chrome（用于 Web 构建）
if exist "C:\Program Files\Google\Chrome\Application\chrome.exe" (
    call :print_success "Chrome 已安装"
) else if exist "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" (
    call :print_success "Chrome 已安装"
) else (
    call :print_warning "Chrome 未安装（Web 构建需要）"
)
goto :eof

:: 安装项目依赖
:install_dependencies
call :print_step "安装项目依赖"

cd /d "%~dp0\.."

:: 清理缓存
call :print_status "清理旧的构建缓存..."
call flutter clean 2>nul

:: 获取依赖
call :print_status "获取 Flutter 依赖..."
call flutter pub get

if %errorlevel% equ 0 (
    call :print_success "依赖安装成功"
) else (
    call :print_error "依赖安装失败"
    exit /b 1
)
goto :eof

:: 运行应用
:run_app
call :print_step "启动应用"

cd /d "%~dp0\.."

:: 检测可用设备
call :print_status "检测可用设备..."
call flutter devices

echo.
echo 选择运行目标:
echo 1. Windows 桌面
echo 2. Chrome (Web)
echo 3. Edge (Web)
echo.
set /p "DEVICE_CHOICE=请选择 (1-3): "

if "!DEVICE_CHOICE!"=="1" (
    set "DEVICE=windows"
) else if "!DEVICE_CHOICE!"=="2" (
    set "DEVICE=chrome"
) else if "!DEVICE_CHOICE!"=="3" (
    set "DEVICE=edge"
) else (
    set "DEVICE=windows"
)

call :print_status "使用设备: !DEVICE!"
call :print_status "正在启动 %PROJECT_NAME%..."

:: 运行应用
call flutter run -d "!DEVICE!" --hot
goto :eof

:: 构建应用
:build_app
call :print_step "构建发布版本"

cd /d "%~dp0\.."

echo.
echo 选择构建目标:
echo 1. Windows 桌面应用
echo 2. Web 应用
echo.
set /p "BUILD_CHOICE=请选择 (1-2): "

if "!BUILD_CHOICE!"=="1" (
    call :print_status "正在构建 Windows 桌面应用..."
    call flutter build windows --release
    if %errorlevel% equ 0 (
        call :print_success "Windows 构建完成"
        call :print_status "构建产物: build\windows\x64\runner\Release\"
    )
) else if "!BUILD_CHOICE!"=="2" (
    call :print_status "正在构建 Web 应用..."
    call flutter build web --release
    if %errorlevel% equ 0 (
        call :print_success "Web 构建完成"
        call :print_status "构建产物: build\web\"
    )
) else (
    call :print_error "无效选择"
    exit /b 1
)
goto :eof

:: 运行测试
:run_tests
call :print_step "运行测试"

cd /d "%~dp0\.."

call :print_status "运行单元测试..."
call flutter test

call :print_status "运行集成测试..."
call flutter test integration_test/

call :print_success "所有测试完成"
goto :eof

:: 清理构建缓存
:clean_build
call :print_step "清理构建缓存"

cd /d "%~dp0\.."

call :print_status "清理 Flutter 缓存..."
call flutter clean

call :print_status "删除构建目录..."
if exist build rmdir /s /q build
if exist .dart_tool rmdir /s /q .dart_tool

call :print_success "清理完成"
goto :eof

:: 显示环境信息
:show_environment_info
call :print_step "环境信息"

echo %CYAN%项目信息:%NC%
echo   项目名称: %PROJECT_NAME%
echo   项目目录: %CD%
echo.

echo %CYAN%系统信息:%NC%
echo   操作系统: Windows
echo   主机名: %COMPUTERNAME%
echo   用户: %USERNAME%
echo.

call :check_command flutter
if %errorlevel% equ 0 (
    echo %CYAN%Flutter 信息:%NC%
    call flutter --version
    echo.
)

echo %CYAN%磁盘空间:%NC%
wmic logicaldisk where "DeviceID='%CD:~0,2%'" get FreeSpace,Size /format:list | findstr /v "^$"
goto :eof

:: 完整流程
:full_setup
call :print_banner
call :check_system_dependencies
call :check_flutter
call :show_environment_info
call :install_dependencies
call :build_app
call :run_app
goto :eof

:: 主函数
:main
cd /d "%~dp0\.."

if "%~1"=="" goto full_setup
if "%~1"=="--help" goto show_help
if "%~1"=="-h" goto show_help
if "%~1"=="--setup" (
    call :print_banner
    call :check_system_dependencies
    call :check_flutter
    call :install_dependencies
    goto :eof
)
if "%~1"=="--run" (
    call :print_banner
    call :run_app
    goto :eof
)
if "%~1"=="--build" (
    call :print_banner
    call :build_app
    goto :eof
)
if "%~1"=="--test" (
    call :print_banner
    call :run_tests
    goto :eof
)
if "%~1"=="--clean" (
    call :print_banner
    call :clean_build
    goto :eof
)
if "%~1"=="--full" goto full_setup

call :print_error "未知选项: %~1"
call :show_help
exit /b 1

:: 运行主函数
call :main %*