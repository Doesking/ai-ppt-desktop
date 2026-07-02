@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ============================================================
:: AI PPT Desktop - Windows 一键构建脚本
:: ============================================================
:: 使用方法:
::   build_windows.bat           完整构建 (添加平台 + 构建 + 打包)
::   build_windows.bat build     仅构建 (平台已添加)
::   build_windows.bat package   仅打包便携版
::   build_windows.bat installer 仅生成安装包
::   build_windows.bat clean     清理构建产物
:: ============================================================

set "APP_NAME=AI PPT Desktop"
set "APP_NAME_SHORT=ai-ppt-desktop"
set "VERSION=1.0.0"
set "BUILD_DIR=build\windows\x64\runner\Release"
set "PORTABLE_DIR=dist\%APP_NAME_SHORT%-windows-portable"
set "PROJECT_DIR=%~dp0.."

cd /d "%PROJECT_DIR%"

echo.
echo ========================================
echo   %APP_NAME% - Windows 构建工具
echo ========================================
echo.

:: ----------------------------------------------------------
:: 检查 Flutter
:: ----------------------------------------------------------
:check_flutter
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Flutter 未安装或不在 PATH 中
    echo.
    echo 请先安装 Flutter SDK:
    echo   1. 访问 https://docs.flutter.dev/get-started/install/windows
    echo   2. 下载并解压 Flutter SDK
    echo   3. 将 flutter\bin 添加到系统 PATH
    echo   4. 运行 flutter doctor 确认环境
    echo.
    echo 安装完成后重新运行此脚本。
    pause
    exit /b 1
)

for /f "tokens=2" %%i in ('flutter --version 2^>nul ^| findstr "Flutter"') do set "FLUTTER_VER=%%i"
echo [OK] Flutter %FLUTTER_VER% 已就绪
echo.

:: ----------------------------------------------------------
:: 处理命令参数
:: ----------------------------------------------------------
set "COMMAND=%1"
if "%COMMAND%"=="" set "COMMAND=full"

if "%COMMAND%"=="build" goto :do_build
if "%COMMAND%"=="package" goto :do_package
if "%COMMAND%"=="installer" goto :do_installer
if "%COMMAND%"=="clean" goto :do_clean
if "%COMMAND%"=="full" goto :do_full

echo [ERROR] 未知命令: %COMMAND%
echo.
echo 可用命令:
echo   build      仅构建
echo   package    仅打包便携版
echo   installer  仅生成安装包
echo   clean      清理构建产物
echo   (空)       完整构建流程
pause
exit /b 1

:: ============================================================
:: 完整构建流程
:: ============================================================
:do_full

:: Step 1: 添加 Windows 平台
echo [1/5] 检查 Windows 平台支持...
if not exist "windows\CMakeLists.txt" (
    echo [..] 首次构建，正在添加 Windows 平台...
    flutter create --platforms=windows .
    if %errorlevel% neq 0 (
        echo [ERROR] 添加 Windows 平台失败
        pause
        exit /b 1
    )
    echo [OK] Windows 平台已添加
) else (
    echo [OK] Windows 平台已存在
)
echo.

:: Step 2: 安装依赖
echo [2/5] 安装项目依赖...
flutter pub get
if %errorlevel% neq 0 (
    echo [ERROR] 依赖安装失败
    pause
    exit /b 1
)
echo [OK] 依赖安装完成
echo.

:: Step 3: 构建
echo [3/5] 构建 Release 版本...
flutter build windows --release
if %errorlevel% neq 0 (
    echo [ERROR] 构建失败
    pause
    exit /b 1
)
echo [OK] 构建完成
echo.

:: Step 4: 打包便携版
echo [4/5] 打包便携版...
call :create_portable
echo.

:: Step 5: 生成安装包
echo [5/5] 生成安装包...
call :create_installer
echo.

echo ========================================
echo   构建完成！
echo ========================================
echo.
echo   便携版:  %PORTABLE_DIR%\
echo   安装包:  dist\%APP_NAME_SHORT%-setup.exe
echo.
echo   双击 %PORTABLE_DIR%\%APP_NAME_SHORT%.exe 即可运行
echo.
pause
exit /b 0

:: ============================================================
:: 仅构建
:: ============================================================
:do_build
echo [1/2] 构建 Release 版本...

if not exist "windows\CMakeLists.txt" (
    echo [..] 首次构建，正在添加 Windows 平台...
    flutter create --platforms=windows .
)

flutter pub get
flutter build windows --release
if %errorlevel% neq 0 (
    echo [ERROR] 构建失败
    pause
    exit /b 1
)
echo [OK] 构建完成
echo   产物路径: %BUILD_DIR%\
echo.
pause
exit /b 0

:: ============================================================
:: 仅打包便携版
:: ============================================================
:do_package
if not exist "%BUILD_DIR%\ai_ppt_desktop.exe" (
    echo [ERROR] 未找到构建产物，请先运行: build_windows.bat build
    pause
    exit /b 1
)
call :create_portable
echo.
pause
exit /b 0

:: ============================================================
:: 仅生成安装包
:: ============================================================
:do_installer
if not exist "%BUILD_DIR%\ai_ppt_desktop.exe" (
    echo [ERROR] 未找到构建产物，请先运行: build_windows.bat build
    pause
    exit /b 1
)
call :create_installer
echo.
pause
exit /b 0

:: ============================================================
:: 清理
:: ============================================================
:do_clean
echo [..] 清理构建产物...
if exist "build" rd /s /q "build"
if exist "dist" rd /s /q "dist"
if exist ".dart_tool" rd /s /q ".dart_tool"
echo [OK] 清理完成
echo.
pause
exit /b 0

:: ============================================================
:: 打包便携版 (子程序)
:: ============================================================
:create_portable
    if not exist "dist" mkdir "dist"
    if exist "%PORTABLE_DIR%" rd /s /q "%PORTABLE_DIR%"
    mkdir "%PORTABLE_DIR%"

    echo [..] 复制构建产物...
    xcopy /s /e /q /y "%BUILD_DIR%\*" "%PORTABLE_DIR%\" >nul

    :: 创建启动脚本
    (
        echo @echo off
        echo chcp 65001 ^>nul
        echo echo 正在启动 AI PPT Desktop...
        echo start "" "%%~dp0ai_ppt_desktop.exe"
    ) > "%PORTABLE_DIR%\启动 AI PPT Desktop.bat"

    :: 创建卸载说明
    (
        echo AI PPT Desktop - 便携版
        echo.
        echo 使用说明:
        echo   1. 双击 "启动 AI PPT Desktop.bat" 运行应用
        echo   2. 或直接双击 ai_ppt_desktop.exe 运行
        echo.
        echo 卸载说明:
        echo   删除此文件夹即可完全卸载，不会留下任何残留。
        echo.
        echo 版本: %VERSION%
        echo 构建日期: %date% %time%
    ) > "%PORTABLE_DIR%\README.txt"

    :: 创建 ZIP 压缩包 (需要 7-Zip 或 PowerShell)
    echo [..] 创建 ZIP 压缩包...
    powershell -Command "Compress-Archive -Path '%PORTABLE_DIR%\*' -DestinationPath 'dist\%APP_NAME_SHORT%-windows-portable.zip' -Force" 2>nul
    if %errorlevel% equ 0 (
        echo [OK] ZIP 已生成: dist\%APP_NAME_SHORT%-windows-portable.zip
    ) else (
        echo [..] ZIP 压缩需要 PowerShell 5.0+，跳过
    )

    echo [OK] 便携版已打包: %PORTABLE_DIR%\
    goto :eof

:: ============================================================
:: 生成 Inno Setup 安装包 (子程序)
:: ============================================================
:create_installer
    :: 检查 Inno Setup
    set "ISCC="
    if exist "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" (
        set "ISCC=C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
    ) else if exist "C:\Program Files\Inno Setup 6\ISCC.exe" (
        set "ISCC=C:\Program Files\Inno Setup 6\ISCC.exe"
    ) else if exist "C:\Program Files (x86)\Inno Setup 5\ISCC.exe" (
        set "ISCC=C:\Program Files (x86)\Inno Setup 5\ISCC.exe"
    )

    if "%ISCC%"=="" (
        echo [!!] Inno Setup 未安装，跳过安装包生成
        echo.
        echo 如需生成 .exe 安装包，请:
        echo   1. 下载 Inno Setup: https://jrsoftware.org/isinfo.php
        echo   2. 安装后重新运行: build_windows.bat installer
        echo.
        echo 便携版可直接使用，无需安装包。
        goto :eof
    )

    echo [..] 使用 Inno Setup 生成安装包...
    "%ISCC%" /O"dist" "scripts\installer.iss"
    if %errorlevel% equ 0 (
        echo [OK] 安装包已生成: dist\%APP_NAME_SHORT%-setup.exe
    ) else (
        echo [ERROR] 安装包生成失败
    )
    goto :eof
