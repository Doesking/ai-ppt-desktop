; ============================================================
; AI PPT Desktop - Inno Setup 安装包脚本
; ============================================================
; 使用方法:
;   1. 安装 Inno Setup: https://jrsoftware.org/isinfo.php
;   2. 打开此文件，点击编译 (Build > Compile)
;   3. 或命令行: ISCC.exe /O"dist" installer.iss
; ============================================================

#define MyAppName "AI PPT Desktop"
#define MyAppNameShort "ai-ppt-desktop"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Doesking"
#define MyAppURL "https://github.com/Doesking/ai-ppt-desktop"
#define MyAppExeName "ai_ppt_desktop.exe"

; 构建产物路径 (flutter build windows --release 的输出)
#define ReleaseDir "..\build\windows\x64\runner\Release"

[Setup]
; 应用基本信息
AppId={{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}

; 安装位置
DefaultDirName={autopf}\{#MyAppNameShort}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes

; 安装包外观
OutputDir=..\dist
OutputBaseFilename={#MyAppNameShort}-setup
SetupIconFile=..\windows\runner\resources\app_icon.ico
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern

; 界面语言
LanguageDetectionMethod=uilanguage
ShowLanguageDialog=no

; 权限
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog

; 卸载信息
UninstallDisplayName={#MyAppName}
UninstallDisplayIcon={app}\{#MyAppExeName}

; 版本信息
VersionInfoVersion={#MyAppVersion}.0
VersionInfoCompany={#MyAppPublisher}
VersionInfoDescription={#MyAppName} 安装程序
VersionInfoProductName={#MyAppName}
VersionInfoProductVersion={#MyAppVersion}

[Languages]
Name: "chinesesimplified"; MessagesFile: "compiler:Languages\ChineseSimplified.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "创建桌面快捷方式"; GroupDescription: "附加图标:"

[Files]
; 复制整个构建产物目录
Source: "{#ReleaseDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
; 开始菜单
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\卸载 {#MyAppName}"; Filename: "{uninstallexe}"

; 桌面快捷方式 (可选)
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
; 安装完成后启动应用
Filename: "{app}\{#MyAppExeName}"; Description: "启动 {#MyAppName}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
; 卸载时清理
Type: filesandordirs; Name: "{app}"
