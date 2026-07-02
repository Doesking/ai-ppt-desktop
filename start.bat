@echo off
setlocal enabledelayedexpansion

:: ============================================================
:: AI PPT Desktop - Windows 一键启动脚本
:: ============================================================
:: 使用方法:
::   start.bat              启动应用（完整流程）
::   start.bat setup        仅安装依赖
::   start.bat run          仅运行应用
::   start.bat build        构建发布版本
::   start.bat test         运行测试
::   start.bat clean        清理缓存
::   start.bat help         显示帮助
:: ============================================================

title AI PPT Desktop - 一键启动

:: 颜色代码
set "GREEN=[92m"
set "BLUE=[94m"
set "CYAN=[96m"
set "RED=[91m"
set "YELLOW=[93m"
set "NC=[0m"

:: 切换到脚本目录
cd /d "%~dp0"

:: 显示横幅
:print_banner
echo.
echo %CYAN%╔════════════════════════════════════════════════════════════╗%NC%
echo %CYAN%║           🚀 AI PPT Desktop - 一键启动                   ║%NC%
echo %CYAN%╚════════════════════════════════════════════════════════════╝%NC%
echo.
goto :eof

:: 检查Flutter
:check_flutter
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo %RED%[✗]%NC% Flutter 未安装
    echo.
    echo 请先安装 Flutter:
    echo   1. 访问 https://flutter.dev/docs/get-started/install/windows
    echo   2. 或使用: choco install flutter
    echo   3. 或使用: winget install Flutter.Flutter
    exit /b 1
)

for /f "tokens=*" %%i in ('flutter --version 2^>nul ^| findstr /B "Flutter"') do set "FLUTTER_VER=%%i"
echo %GREEN%[✓]%NC% Flutter: %FLUTTER_VER%
goto :eof

:: 安装依赖
:install_deps
echo %BLUE%[▶]%NC% 安装项目依赖...
call flutter pub get
if %errorlevel% equ 0 (
    echo %GREEN%[✓]%NC% 依赖安装完成
) else (
    echo %RED%[✗]%NC% 依赖安装失败
    exit /b 1
)
goto :eof

:: 运行应用
:run_app
echo %BLUE%[▶]%NC% 启动应用...
echo.
echo 选择运行目标:
echo   1. Windows 桌面
echo   2. Chrome (Web)
echo   3. Edge (Web)
echo.
set /p "CHOICE=请选择 (1-3, 默认1): "

if "!CHOICE!"=="" set "CHOICE=1"

if "!CHOICE!"=="1" (
    set "DEVICE=windows"
) else if "!CHOICE!"=="2" (
    set "DEVICE=chrome"
) else if "!CHOICE!"=="3" (
    set "DEVICE=edge"
) else (
    set "DEVICE=windows"
)

echo %BLUE%[▶]%NC% 使用设备: !DEVICE!
call flutter run -d "!DEVICE!" --hot
goto :eof

:: 构建应用
:build_app
echo %BLUE%[▶]%NC% 构建应用...
echo.
echo 选择构建目标:
echo   1. Windows 桌面应用
echo   2. Web 应用
echo.
set /p "CHOICE=请选择 (1-2, 默认1): "

if "!CHOICE!"=="" set "CHOICE=1"

if "!CHOICE!"=="1" (
    call flutter build windows --release
    if %errorlevel% equ 0 (
        echo %GREEN%[✓]%NC% 构建完成: build\windows\x64\runner\Release\
    )
) else if "!CHOICE!"=="2" (
    call flutter build web --release
    if %errorlevel% equ 0 (
        echo %GREEN%[✓]%NC% 构建完成: build\web\
    )
)
goto :eof

:: 运行测试
:run_tests
echo %BLUE%[▶]%NC% 运行测试...
call flutter test
if %errorlevel% equ 0 (
    echo %GREEN%[✓]%NC% 测试完成
)
goto :eof

:: 清理缓存
:clean_cache
echo %BLUE%[▶]%NC% 清理缓存...
call flutter clean
if exist build rmdir /s /q build
if exist .dart_tool rmdir /s /q .dart_tool
echo %GREEN%[✓]%NC% 清理完成
goto :eof

:: 显示帮助
:show_help
call :print_banner
echo 使用方法:
echo   start.bat [命令]
echo.
echo 命令:
echo   (无参数)    完整流程：检查环境 + 安装依赖 + 运行应用
echo   setup       仅安装依赖
echo   run         仅运行应用
echo   build       构建发布版本
echo   test        运行测试
echo   clean       清理缓存
echo   help        显示此帮助
echo.
echo 示例:
echo   start.bat          # 首次运行，自动安装依赖并启动
echo   start.bat run      # 快速启动（依赖已安装）
echo   start.bat build    # 构建发布版本
echo.
echo 快捷方式:
echo   双击 start.bat 文件
goto :eof

:: 完整流程
:full_setup
call :print_banner
call :check_flutter
if %errorlevel% neq 0 exit /b 1
call :install_deps
call :run_app
goto :eof

:: 主入口
if "%~1"=="" goto full_setup
if "%~1"=="setup" (
    call :print_banner
    call :check_flutter
    call :install_deps
    goto :eof
)
if "%~1"=="run" (
    call :print_banner
    call :check_flutter
    call :run_app
    goto :eof
)
if "%~1"=="build" (
    call :print_banner
    call :check_flutter
    call :build_app
    goto :eof
)
if "%~1"=="test" (
    call :print_banner
    call :check_flutter
    call :run_tests
    goto :eof
)
if "%~1"=="clean" (
    call :print_banner
    call :clean_cache
    goto :eof
)
if "%~1"=="help" goto show_help
if "%~1"=="--help" goto show_help
if "%~1"=="-h" goto show_help

echo %RED%[✗]%NC% 未知命令: %~1
echo.
goto show_help