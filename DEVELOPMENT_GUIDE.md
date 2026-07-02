# 开发指南

## 快速开始

### 1. 环境准备

#### Flutter SDK 安装
```bash
# macOS (使用Homebrew)
brew install flutter

# Windows (使用Chocolatey)
choco install flutter

# Linux (手动安装)
# 下载Flutter SDK并添加到PATH
```

#### 开发工具安装
- **Android Studio**: 推荐用于Flutter开发
- **VS Code**: 轻量级替代方案
- **Xcode**: macOS开发必需 (仅macOS)
- **Visual Studio**: Windows开发必需 (仅Windows)

### 2. 项目初始化

#### 使用自动化脚本
```bash
# 给脚本执行权限
chmod +x setup_project.sh

# 运行设置脚本
./setup_project.sh
```

#### 手动初始化
```bash
# 创建Flutter项目
flutter create --project-name ai_ppt_desktop --platforms=windows,macos,linux ai_ppt_desktop

# 进入项目目录
cd ai_ppt_desktop

# 安装依赖
flutter pub get
```

### 3. 项目结构

```
ai_ppt_desktop/
├── lib/                          # 主要源代码
│   ├── main.dart                 # 应用入口
│   ├── app.dart                  # 应用主Widget
│   ├── core/                     # 核心功能
│   │   ├── config/               # 配置管理
│   │   ├── constants/            # 常量定义
│   │   ├── errors/               # 错误处理
│   │   ├── utils/                # 工具类
│   │   └── theme/                # 主题配置
│   ├── data/                     # 数据层
│   │   ├── models/               # 数据模型
│   │   ├── repositories/         # 数据仓库
│   │   ├── sources/              # 数据源
│   │   └── services/             # 服务层
│   ├── domain/                   # 领域层
│   │   ├── entities/             # 实体类
│   │   ├── usecases/             # 用例
│   │   └── repositories/         # 仓库接口
│   ├── presentation/             # 表现层
│   │   ├── pages/                # 页面
│   │   ├── widgets/              # 组件
│   │   ├── providers/            # 状态管理
│   │   └── blocs/                # BLoC模式
│   └── ai/                       # AI功能
│       ├── models/               # AI模型
│       ├── engines/              # AI引擎
│       └── processors/           # 数据处理器
├── assets/                       # 资源文件
│   ├── models/                   # AI模型文件
│   ├── templates/                # PPT模板
│   ├── images/                   # 图片资源
│   └── fonts/                    # 字体文件
├── test/                         # 测试代码
├── pubspec.yaml                  # 依赖配置
└── README.md                     # 项目说明
```

## 开发流程

### 1. 功能开发流程

#### 创建新功能
```bash
# 1. 创建功能分支
git checkout -b feature/new-feature

# 2. 开发功能
# ... 编写代码 ...

# 3. 测试功能
flutter test

# 4. 提交代码
git add .
git commit -m "feat: add new feature"

# 5. 推送到远程
git push origin feature/new-feature
```

#### 代码规范
- 遵循Dart官方代码规范
- 使用flutter_lints进行代码检查
- 保持代码简洁，添加必要注释
- 遵循单一职责原则

### 2. 测试流程

#### 单元测试
```bash
# 运行所有单元测试
flutter test

# 运行特定测试文件
flutter test test/unit/ai_engine_test.dart

# 生成测试覆盖率报告
flutter test --coverage
```

#### 集成测试
```bash
# 运行集成测试
flutter test integration_test/
```

#### 性能测试
```bash
# 性能分析
flutter run --profile
```

### 3. 构建和发布

#### 调试版本
```bash
# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

#### 发布版本
```bash
# Windows
flutter build windows

# macOS
flutter build macos

# Linux
flutter build linux
```

## 核心功能实现

### 1. AI模型集成

#### TensorFlow Lite 集成
```dart
// lib/ai/engines/tflite_engine.dart
import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteEngine {
  late Interpreter _interpreter;
  
  Future<void> loadModel(String modelPath) async {
    _interpreter = await Interpreter.fromAsset(modelPath);
  }
  
  List<dynamic> runModel(List<dynamic> input) {
    List<dynamic> output = [];
    _interpreter.run(input, output);
    return output;
  }
  
  void dispose() {
    _interpreter.close();
  }
}
```

#### 模型管理
```dart
// lib/ai/models/model_manager.dart
class ModelManager {
  final Map<String, TFLiteEngine> _models = {};
  
  Future<void> loadModel(String modelName) async {
    if (!_models.containsKey(modelName)) {
      final engine = TFLiteEngine();
      await engine.loadModel('assets/models/$modelName');
      _models[modelName] = engine;
    }
  }
  
  TFLiteEngine? getModel(String modelName) {
    return _models[modelName];
  }
  
  void unloadModel(String modelName) {
    _models[modelName]?.dispose();
    _models.remove(modelName);
  }
}
```

### 2. PPT生成

#### 基础PPT创建
```dart
// lib/data/services/ppt_service.dart
import 'package:flutter_pptx/flutter_pptx.dart';

class PPTService {
  Future<Powerpoint> createPresentation({
    required String title,
    required List<String> slides,
  }) async {
    final pres = Powerpoint();
    
    // 添加标题幻灯片
    pres.addTitleSlide(
      title: title.toTextValue(),
      author: 'AI PPT Desktop'.toTextValue(),
    );
    
    // 添加内容幻灯片
    for (final slide in slides) {
      pres.addTitleAndBulletsSlide(
        title: 'Content'.toTextValue(),
        bullets: [slide.toTextValue()],
      );
    }
    
    return pres;
  }
  
  Future<List<int>> savePresentation(Powerpoint pres) async {
    return await pres.save();
  }
}
```

### 3. 语音识别

#### 语音录制
```dart
// lib/data/services/audio_service.dart
import 'package:flutter_sound/flutter_sound.dart';

class AudioService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  
  Future<void> initialize() async {
    await _recorder.openRecorder();
  }
  
  Future<void> startRecording() async {
    await _recorder.startRecorder(
      toFile: 'recording.wav',
      codec: Codec.pcm16WAV,
    );
  }
  
  Future<String?> stopRecording() async {
    return await _recorder.stopRecorder();
  }
  
  Future<void> dispose() async {
    await _recorder.closeRecorder();
  }
}
```

### 4. 状态管理

#### Riverpod 配置
```dart
// lib/presentation/providers/app_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 应用状态
final appStateProvider = StateNotifierProvider<AppState, bool>((ref) {
  return AppState();
});

class AppState extends StateNotifier<bool> {
  AppState() : super(false);
  
  void setLoading(bool loading) {
    state = loading;
  }
}

// PPT状态
final pptProvider = StateNotifierProvider<PPTState, PPTData>((ref) {
  return PPTState();
});

class PPTState extends StateNotifier<PPTData> {
  PPTState() : super(PPTData.initial());
  
  void updateTitle(String title) {
    state = state.copyWith(title: title);
  }
  
  void addSlide(SlideData slide) {
    state = state.copyWith(slides: [...state.slides, slide]);
  }
}
```

## 性能优化

### 1. 启动优化

#### 延迟加载
```dart
// 使用懒加载减少启动时间
class LazyWidget extends StatefulWidget {
  @override
  _LazyWidgetState createState() => _LazyWidgetState();
}

class _LazyWidgetState extends State<LazyWidget> {
  bool _isLoaded = false;
  
  @override
  void initState() {
    super.initState();
    // 延迟加载非关键资源
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoaded = true;
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return const CircularProgressIndicator();
    }
    return _buildContent();
  }
}
```

### 2. 内存优化

#### 对象池
```dart
// lib/core/utils/object_pool.dart
class ObjectPool<T> {
  final T Function() _factory;
  final List<T> _pool = [];
  final int _maxSize;
  
  ObjectPool(this._factory, {int maxSize = 100}) : _maxSize = maxSize;
  
  T acquire() {
    if (_pool.isEmpty) {
      return _factory();
    }
    return _pool.removeLast();
  }
  
  void release(T object) {
    if (_pool.length < _maxSize) {
      _pool.add(object);
    }
  }
}
```

### 3. 渲染优化

#### 虚拟列表
```dart
// 使用ListView.builder实现虚拟列表
ListView.builder(
  itemCount: 1000, // 大量数据
  itemBuilder: (context, index) {
    return ListTile(
      title: Text('Item $index'),
    );
  },
)
```

## 错误处理

### 1. 全局错误处理
```dart
// lib/core/errors/error_handler.dart
class ErrorHandler {
  static void initialize() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      // 记录错误到日志
      _logError(details);
    };
    
    PlatformDispatcher.instance.onError = (error, stack) {
      // 处理平台错误
      _logError(error, stack);
      return true;
    };
  }
  
  static void _logError(dynamic error, [StackTrace? stack]) {
    // 实现错误日志记录
    print('Error: $error');
    if (stack != null) {
      print('Stack: $stack');
    }
  }
}
```

### 2. 用户友好的错误提示
```dart
// lib/core/errors/error_widget.dart
class ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  
  const ErrorDisplay({
    required this.message,
    this.onRetry,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}
```

## 调试技巧

### 1. 日志记录
```dart
// lib/core/utils/logger.dart
import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );
  
  static void debug(String message) {
    _logger.d(message);
  }
  
  static void info(String message) {
    _logger.i(message);
  }
  
  static void warning(String message) {
    _logger.w(message);
  }
  
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error, stackTrace);
  }
}
```

### 2. 性能监控
```dart
// lib/core/utils/performance_monitor.dart
class PerformanceMonitor {
  static final Map<String, Stopwatch> _timers = {};
  
  static void startTimer(String name) {
    _timers[name] = Stopwatch()..start();
  }
  
  static void stopTimer(String name) {
    final timer = _timers[name];
    if (timer != null) {
      timer.stop();
      AppLogger.debug('Timer $name: ${timer.elapsedMilliseconds}ms');
      _timers.remove(name);
    }
  }
}
```

## 部署指南

### 1. Windows 部署
```bash
# 构建Windows应用
flutter build windows

# 打包为MSIX
flutter pub run msix:create
```

### 2. macOS 部署
```bash
# 构建macOS应用
flutter build macos

# 创建DMG
# 使用create-dmg工具
```

### 3. Linux 部署
```bash
# 构建Linux应用
flutter build linux

# 创建DEB包
# 使用dpkg-deb工具
```

## 常见问题解决

### 1. 编译错误
```bash
# 清理构建缓存
flutter clean

# 重新获取依赖
flutter pub get

# 检查Flutter版本
flutter doctor
```

### 2. 运行时错误
- 检查平台特定配置
- 验证资源文件路径
- 检查权限配置

### 3. 性能问题
- 使用Flutter DevTools进行性能分析
- 检查内存泄漏
- 优化渲染性能

## 最佳实践

### 1. 代码组织
- 遵循Clean Architecture原则
- 使用依赖注入
- 保持代码模块化

### 2. 状态管理
- 使用Riverpod进行状态管理
- 避免全局状态
- 实现状态持久化

### 3. 测试策略
- 编写单元测试
- 实现集成测试
- 进行性能测试

### 4. 错误处理
- 实现全局错误处理
- 提供用户友好的错误信息
- 记录错误日志

---

*最后更新: 2026年7月2日*