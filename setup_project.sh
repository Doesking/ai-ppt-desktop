#!/bin/bash

# AI PPT Desktop Application - Project Setup Script
# This script initializes the Flutter Desktop project with all necessary configurations

set -e

echo "🚀 Setting up AI PPT Desktop Application..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Flutter is installed
check_flutter() {
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed. Please install Flutter first."
        exit 1
    fi
    
    print_status "Flutter version: $(flutter --version | head -1)"
}

# Create Flutter project
create_flutter_project() {
    print_status "Creating Flutter Desktop project..."
    
    # Create project directory if it doesn't exist
    mkdir -p ai_ppt_desktop
    cd ai_ppt_desktop
    
    # Create Flutter project with desktop support
    flutter create --project-name ai_ppt_desktop --platforms=windows,macos,linux .
    
    print_success "Flutter project created successfully"
}

# Update pubspec.yaml with dependencies
update_pubspec() {
    print_status "Updating pubspec.yaml with dependencies..."
    
    cat > pubspec.yaml << 'EOL'
name: ai_ppt_desktop
description: AI-powered PPT creation desktop application for enterprise teams
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.3.6
  riverpod_annotation: ^2.1.1
  
  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  sqflite_common_ffi: ^2.3.0+2
  path_provider: ^2.0.15
  
  # PPT Generation
  flutter_pptx: ^0.1.0
  dart_pptx: ^0.1.0
  
  # AI Integration
  tflite_flutter: ^0.10.0
  onnxruntime: ^1.15.0
  
  # Audio Processing
  flutter_sound: ^9.2.13
  just_audio: ^0.9.34
  
  # Video Processing
  video_player: ^2.7.0
  
  # UI Components
  flutter_animate: ^4.2.0
  google_fonts: ^5.1.0
  flutter_svg: ^2.0.7
  
  # Utilities
  dio: ^5.2.1+1
  path: ^1.8.3
  uuid: ^3.0.7
  intl: ^0.18.0
  
  # File Handling
  file_picker: ^5.3.2
  permission_handler: ^10.4.3
  
  # Window Management
  window_manager: ^0.3.4
  
  # Logging
  logger: ^1.4.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # Testing
  mockito: ^5.4.2
  build_runner: ^2.4.6
  
  # Code Generation
  riverpod_generator: ^2.2.3
  hive_generator: ^2.0.0
  json_serializable: ^6.7.1
  
  # Linting
  flutter_lints: ^3.0.1
  custom_lint: ^0.5.0

flutter:
  uses-material-design: true
  
  assets:
    - assets/
    - assets/models/
    - assets/templates/
    - assets/images/
    - assets/fonts/
  
  fonts:
    - family: Roboto
      fonts:
        - asset: assets/fonts/Roboto-Regular.ttf
        - asset: assets/fonts/Roboto-Bold.ttf
          weight: 700
        - asset: assets/fonts/Roboto-Italic.ttf
          style: italic
EOL

    print_success "pubspec.yaml updated"
}

# Create project structure
create_project_structure() {
    print_status "Creating project structure..."
    
    # Create main directories
    mkdir -p lib/{core/{config,constants,errors,utils,theme},data/{models,repositories,sources,services},domain/{entities,usecases,repositories},presentation/{pages,widgets,providers,blocs},ai/{models,engines,processors}}
    
    # Create assets directories
    mkdir -p assets/{models,templates,images,fonts}
    
    # Create test directories
    mkdir -p test/{unit,integration,widget}
    
    print_success "Project structure created"
}

# Create main entry point
create_main_entry() {
    print_status "Creating main entry point..."
    
    cat > lib/main.dart << 'EOL'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'core/config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize window manager for desktop
  await windowManager.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Initialize app configuration
  await AppConfig.initialize();
  
  // Set window options for desktop
  const windowOptions = WindowOptions(
    size: Size(1280, 800),
    minimumSize: Size(1024, 768),
    center: true,
    backgroundColor: Colors.transparent,
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: true,
  );
  
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  
  runApp(
    const ProviderScope(
      child: AiPptDesktopApp(),
    ),
  );
}
EOL

    print_success "Main entry point created"
}

# Create app widget
create_app_widget() {
    print_status "Creating app widget..."
    
    cat > lib/app.dart << 'EOL'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme/app_theme.dart';
import 'presentation/pages/home_page.dart';

class AiPptDesktopApp extends ConsumerWidget {
  const AiPptDesktopApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'AI PPT Desktop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}
EOL

    print_success "App widget created"
}

# Create core configurations
create_core_configs() {
    print_status "Creating core configurations..."
    
    # App configuration
    cat > lib/core/config/app_config.dart << 'EOL'
import 'package:hive/hive.dart';

class AppConfig {
  static const String _configBoxName = 'app_config';
  static late Box _configBox;
  
  static Future<void> initialize() async {
    _configBox = await Hive.openBox(_configBoxName);
  }
  
  // AI Model Configuration
  static String get aiModelPath => _configBox.get('ai_model_path', defaultValue: 'assets/models/');
  static set aiModelPath(String value) => _configBox.put('ai_model_path', value);
  
  // Template Configuration
  static String get templatePath => _configBox.get('template_path', defaultValue: 'assets/templates/');
  static set templatePath(String value) => _configBox.put('template_path', value);
  
  // User Preferences
  static String get userName => _configBox.get('user_name', defaultValue: '');
  static set userName(String value) => _configBox.put('user_name', value);
  
  static String get companyName => _configBox.get('company_name', defaultValue: '');
  static set companyName(String value) => _configBox.put('company_name', value);
  
  // Theme Configuration
  static bool get isDarkMode => _configBox.get('is_dark_mode', defaultValue: false);
  static set isDarkMode(bool value) => _configBox.put('is_dark_mode', value);
  
  // Language Configuration
  static String get language => _configBox.get('language', defaultValue: 'en');
  static set language(String value) => _configBox.put('language', value);
}
EOL

    # App constants
    cat > lib/core/constants/app_constants.dart << 'EOL'
class AppConstants {
  // App Information
  static const String appName = 'AI PPT Desktop';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'AI-powered PPT creation desktop application';
  
  // File Extensions
  static const String pptxExtension = '.pptx';
  static const String pdfExtension = '.pdf';
  static const String imageExtensions = '.png,.jpg,.jpeg,.gif,.bmp';
  static const String audioExtensions = '.mp3,.wav,.aac,.m4a';
  static const String videoExtensions = '.mp4,.avi,.mov,.mkv';
  
  // AI Model Names
  static const String textGenerationModel = 'text_generation.tflite';
  static const String imageClassificationModel = 'image_classification.tflite';
  static const String speechRecognitionModel = 'speech_recognition.tflite';
  static const String layoutGenerationModel = 'layout_generation.tflite';
  
  // Default Values
  static const int maxSlides = 100;
  static const int maxImages = 50;
  static const int maxAudioLength = 3600; // 1 hour in seconds
  static const int maxVideoLength = 7200; // 2 hours in seconds
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 8.0;
  static const double defaultElevation = 2.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}
EOL

    print_success "Core configurations created"
}

# Create theme configuration
create_theme() {
    print_status "Creating theme configuration..."
    
    cat > lib/core/theme/app_theme.dart << 'EOL'
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF6366F1);
  static const Color secondaryColor = Color(0xFF8B5CF6);
  static const Color accentColor = Color(0xFF06B6D4);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  
  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.robotoTextTheme(),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
  
  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.robotoTextTheme(
        ThemeData.dark().textTheme,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
EOL

    print_success "Theme configuration created"
}

# Create home page
create_home_page() {
    print_status "Creating home page..."
    
    cat > lib/presentation/pages/home_page.dart << 'EOL'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/constants/app_constants.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Custom Title Bar for Desktop
          _buildTitleBar(),
          
          // Main Content
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTitleBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Text(
            AppConstants.appName,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const Spacer(),
          // Window controls
          IconButton(
            icon: const Icon(Icons.minimize, size: 16),
            onPressed: () => windowManager.minimize(),
          ),
          IconButton(
            icon: const Icon(Icons.crop_square, size: 16),
            onPressed: () => windowManager.maximize(),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: () => windowManager.close(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMainContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.slideshow,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Welcome to AI PPT Desktop',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'Create professional presentations with AI assistance',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Navigate to PPT creation page
            },
            icon: const Icon(Icons.add),
            label: const Text('Create New Presentation'),
          ),
        ],
      ),
    );
  }
  
  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose && mounted) {
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('Are you sure you want to close?'),
            content: const Text('Unsaved changes will be lost.'),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                  windowManager.destroy();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
EOL

    print_success "Home page created"
}

# Main setup function
main() {
    echo "=========================================="
    echo "   AI PPT Desktop Application Setup"
    echo "=========================================="
    echo ""
    
    check_flutter
    create_flutter_project
    update_pubspec
    create_project_structure
    create_main_entry
    create_app_widget
    create_core_configs
    create_theme
    create_home_page
    
    echo ""
    echo "=========================================="
    echo "   Setup Complete!"
    echo "=========================================="
    echo ""
    echo "Next steps:"
    echo "1. cd ai_ppt_desktop"
    echo "2. flutter pub get"
    echo "3. flutter run -d windows/macos/linux"
    echo ""
    echo "For more information, see README.md"
}

# Run main function
main