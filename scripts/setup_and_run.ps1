# ============================================================
# AI PPT Desktop - Windows 一键启动脚本 (PowerShell 版本)
# ============================================================
# 使用方法:
#   .\scripts\setup_and_run.ps1 [选项]
#
# 选项:
#   -Setup      仅安装依赖
#   -Run        仅运行应用
#   -Build      构建发布版本
#   -Test       运行测试
#   -Clean      清理构建缓存
#   -Help       显示帮助信息
# ============================================================

param(
    [switch]$Setup,
    [switch]$Run,
    [switch]$Build,
    [switch]$Test,
    [switch]$Clean,
    [switch]$Full,
    [switch]$Help
)

# 错误处理
$ErrorActionPreference = "Stop"

# 颜色定义
$Colors = @{
    Red = "Red"
    Green = "Green"
    Yellow = "Yellow"
    Blue = "Blue"
    Cyan = "Cyan"
    Magenta = "Magenta"
}

# 项目配置
$ProjectName = "AI PPT Desktop"
$FlutterMinVersion = "3.0.0"

# 打印函数
function Write-Banner {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║              AI PPT Desktop Application                   ║" -ForegroundColor Cyan
    Write-Host "║              Windows PowerShell 启动脚本                   ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[✓] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[!] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[✗] $Message" -ForegroundColor Red
}

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
    Write-Host "  $Message" -ForegroundColor Magenta
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
}

# 显示帮助
function Show-Help {
    Write-Banner
    Write-Host "使用方法:"
    Write-Host "  .\scripts\setup_and_run.ps1 [选项]"
    Write-Host ""
    Write-Host "选项:"
    Write-Host "  -Setup      仅安装依赖"
    Write-Host "  -Run        仅运行应用"
    Write-Host "  -Build      构建发布版本"
    Write-Host "  -Test       运行测试"
    Write-Host "  -Clean      清理构建缓存"
    Write-Host "  -Full       完整流程：安装依赖 + 构建 + 运行"
    Write-Host "  -Help       显示此帮助信息"
    Write-Host ""
    Write-Host "示例:"
    Write-Host "  .\scripts\setup_and_run.ps1              # 完整流程"
    Write-Host "  .\scripts\setup_and_run.ps1 -Setup       # 仅安装依赖"
    Write-Host "  .\scripts\setup_and_run.ps1 -Run         # 仅运行应用"
    Write-Host "  .\scripts\setup_and_run.ps1 -Build       # 构建发布版本"
}

# 检查命令是否存在
function Test-Command {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

# 检查Flutter环境
function Test-Flutter {
    Write-Step "检查 Flutter 环境"
    
    if (Test-Command "flutter") {
        $flutterVersion = (flutter --version 2>$null | Select-String "Flutter" | ForEach-Object { $_.ToString().Split(" ")[1] })
        Write-Success "Flutter 已安装: $flutterVersion"
        
        # 检查版本
        if ([version]$flutterVersion -lt [version]$FlutterMinVersion) {
            Write-Warning "Flutter 版本过低，建议升级到 $FlutterMinVersion 或更高版本"
        }
    } else {
        Write-Warning "Flutter 未安装"
        $install = Read-Host "是否自动安装 Flutter? (y/n)"
        if ($install -eq "y" -or $install -eq "Y") {
            Install-Flutter
        } else {
            Write-Error "请先安装 Flutter: https://flutter.dev/docs/get-started/install"
            exit 1
        }
    }
    
    # 检查Dart
    if (Test-Command "dart") {
        $dartVersion = (dart --version 2>&1 | ForEach-Object { $_.ToString() } | Select-String "[0-9]+\.[0-9]+\.[0-9]+" | ForEach-Object { $_.Matches.Value })
        Write-Success "Dart 已安装: $dartVersion"
    } else {
        Write-Warning "Dart 未找到"
    }
}

# 安装Flutter
function Install-Flutter {
    Write-Status "正在安装 Flutter..."
    
    # 检查是否安装了Chocolatey
    if (Test-Command "choco") {
        Write-Status "使用 Chocolatey 安装 Flutter..."
        choco install flutter -y
    } elseif (Test-Command "winget") {
        Write-Status "使用 winget 安装 Flutter..."
        winget install Flutter.Flutter
    } else {
        Write-Warning "Chocolatey 和 winget 均未安装"
        Write-Host ""
        Write-Host "请手动安装 Flutter:" -ForegroundColor Yellow
        Write-Host "1. 访问 https://flutter.dev/docs/get-started/install/windows"
        Write-Host "2. 下载 Flutter SDK"
        Write-Host "3. 解压到 C:\flutter"
        Write-Host "4. 将 C:\flutter\bin 添加到 PATH 环境变量"
        Write-Host ""
        Read-Host "按 Enter 键继续"
        exit 1
    }
    
    if (Test-Command "flutter") {
        Write-Success "Flutter 安装成功"
    } else {
        Write-Error "Flutter 安装失败，请手动安装"
        exit 1
    }
}

# 检查系统依赖
function Test-SystemDependencies {
    Write-Step "检查系统依赖"
    
    # 检查 Git
    if (Test-Command "git") {
        $gitVersion = git --version
        Write-Success "Git 已安装: $gitVersion"
    } else {
        Write-Error "Git 未安装，请先安装 Git: https://git-scm.com/download/win"
        exit 1
    }
    
    # 检查 Visual Studio
    $vsPath = "C:\Program Files\Microsoft Visual Studio\2022"
    $vsPath2 = "C:\Program Files (x86)\Microsoft Visual Studio\2019"
    
    if (Test-Path $vsPath) {
        Write-Success "Visual Studio 2022 已安装"
    } elseif (Test-Path $vsPath2) {
        Write-Success "Visual Studio 2019 已安装"
    } else {
        Write-Warning "Visual Studio 未安装"
        Write-Host "Windows 构建需要 Visual Studio 和 C++ 桌面开发工作负载" -ForegroundColor Yellow
        Write-Host "下载地址: https://visualstudio.microsoft.com/downloads/" -ForegroundColor Yellow
    }
    
    # 检查 Chrome
    $chromePaths = @(
        "C:\Program Files\Google\Chrome\Application\chrome.exe",
        "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
    )
    
    $chromeFound = $false
    foreach ($path in $chromePaths) {
        if (Test-Path $path) {
            $chromeFound = $true
            break
        }
    }
    
    if ($chromeFound) {
        Write-Success "Chrome 已安装"
    } else {
        Write-Warning "Chrome 未安装（Web 构建需要）"
    }
}

# 安装项目依赖
function Install-Dependencies {
    Write-Step "安装项目依赖"
    
    Set-Location $PSScriptRoot\..
    
    # 清理缓存
    Write-Status "清理旧的构建缓存..."
    flutter clean 2>$null
    
    # 获取依赖
    Write-Status "获取 Flutter 依赖..."
    flutter pub get
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "依赖安装成功"
    } else {
        Write-Error "依赖安装失败"
        exit 1
    }
}

# 运行应用
function Start-App {
    Write-Step "启动应用"
    
    Set-Location $PSScriptRoot\..
    
    # 检测可用设备
    Write-Status "检测可用设备..."
    flutter devices
    
    Write-Host ""
    Write-Host "选择运行目标:" -ForegroundColor Cyan
    Write-Host "1. Windows 桌面"
    Write-Host "2. Chrome (Web)"
    Write-Host "3. Edge (Web)"
    Write-Host ""
    
    $choice = Read-Host "请选择 (1-3)"
    
    switch ($choice) {
        "1" { $device = "windows" }
        "2" { $device = "chrome" }
        "3" { $device = "edge" }
        default { $device = "windows" }
    }
    
    Write-Status "使用设备: $device"
    Write-Status "正在启动 $ProjectName..."
    
    # 运行应用
    flutter run -d $device --hot
}

# 构建应用
function Build-App {
    Write-Step "构建发布版本"
    
    Set-Location $PSScriptRoot\..
    
    Write-Host ""
    Write-Host "选择构建目标:" -ForegroundColor Cyan
    Write-Host "1. Windows 桌面应用"
    Write-Host "2. Web 应用"
    Write-Host ""
    
    $choice = Read-Host "请选择 (1-2)"
    
    switch ($choice) {
        "1" {
            Write-Status "正在构建 Windows 桌面应用..."
            flutter build windows --release
            if ($LASTEXITCODE -eq 0) {
                Write-Success "Windows 构建完成"
                Write-Status "构建产物: build\windows\x64\runner\Release\"
            }
        }
        "2" {
            Write-Status "正在构建 Web 应用..."
            flutter build web --release
            if ($LASTEXITCODE -eq 0) {
                Write-Success "Web 构建完成"
                Write-Status "构建产物: build\web\"
            }
        }
        default {
            Write-Error "无效选择"
            exit 1
        }
    }
}

# 运行测试
function Invoke-Tests {
    Write-Step "运行测试"
    
    Set-Location $PSScriptRoot\..
    
    Write-Status "运行单元测试..."
    flutter test
    
    Write-Status "运行集成测试..."
    flutter test integration_test/
    
    Write-Success "所有测试完成"
}

# 清理构建缓存
function Clear-Build {
    Write-Step "清理构建缓存"
    
    Set-Location $PSScriptRoot\..
    
    Write-Status "清理 Flutter 缓存..."
    flutter clean
    
    Write-Status "删除构建目录..."
    if (Test-Path "build") { Remove-Item -Recurse -Force "build" }
    if (Test-Path ".dart_tool") { Remove-Item -Recurse -Force ".dart_tool" }
    
    Write-Success "清理完成"
}

# 显示环境信息
function Show-EnvironmentInfo {
    Write-Step "环境信息"
    
    Write-Host "项目信息:" -ForegroundColor Cyan
    Write-Host "  项目名称: $ProjectName"
    Write-Host "  项目目录: $(Get-Location)"
    Write-Host ""
    
    Write-Host "系统信息:" -ForegroundColor Cyan
    Write-Host "  操作系统: Windows"
    Write-Host "  主机名: $env:COMPUTERNAME"
    Write-Host "  用户: $env:USERNAME"
    Write-Host ""
    
    if (Test-Command "flutter") {
        Write-Host "Flutter 信息:" -ForegroundColor Cyan
        flutter --version
        Write-Host ""
    }
    
    Write-Host "磁盘空间:" -ForegroundColor Cyan
    Get-PSDrive -Name (Get-Location).Drive.Name | Select-Object Used, Free | Format-List
}

# 完整流程
function Start-FullSetup {
    Write-Banner
    Test-SystemDependencies
    Test-Flutter
    Show-EnvironmentInfo
    Install-Dependencies
    Build-App
    Start-App
}

# 主函数
function Main {
    Set-Location $PSScriptRoot\..
    
    if ($Help) {
        Show-Help
        return
    }
    
    if ($Setup) {
        Write-Banner
        Test-SystemDependencies
        Test-Flutter
        Install-Dependencies
        return
    }
    
    if ($Run) {
        Write-Banner
        Start-App
        return
    }
    
    if ($Build) {
        Write-Banner
        Build-App
        return
    }
    
    if ($Test) {
        Write-Banner
        Invoke-Tests
        return
    }
    
    if ($Clean) {
        Write-Banner
        Clear-Build
        return
    }
    
    # 默认执行完整流程
    Start-FullSetup
}

# 运行主函数
Main