import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/services/error_service.dart';
import 'core/services/performance_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize error handling
  final errorService = ErrorService();
  errorService.initialize();
  
  // Initialize performance monitoring
  final performanceService = PerformanceService();
  
  // Start app initialization timer
  performanceService.startTimer('app_initialization');
  
  try {
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
    
    // Record successful initialization
    performanceService.stopTimer('app_initialization');
    
    runApp(
      const ProviderScope(
        child: AiPptDesktopApp(),
      ),
    );
  } catch (e, stackTrace) {
    // Handle initialization errors
    errorService.handleError(
      message: 'Failed to initialize app: $e',
      type: ErrorType.critical,
      stackTrace: stackTrace.toString(),
      context: 'App Initialization',
    );
    
    // Show error app
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Failed to initialize application',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Restart app
                    main();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}