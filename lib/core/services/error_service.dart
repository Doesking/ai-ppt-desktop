import 'dart:async';
import 'package:flutter/foundation.dart';

class ErrorService {
  static final ErrorService _instance = ErrorService._internal();
  factory ErrorService() => _instance;
  ErrorService._internal();
  
  final List<AppError> _errorLog = [];
  final StreamController<AppError> _errorController = StreamController<AppError>.broadcast();
  
  /// Initialize error service
  void initialize() {
    // Set up global error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      _handleFlutterError(details);
    };
    
    // Set up platform error handling
    PlatformDispatcher.instance.onError = (error, stack) {
      _handlePlatformError(error, stack);
      return true;
    };
  }
  
  /// Handle Flutter framework errors
  void _handleFlutterError(FlutterErrorDetails details) {
    final error = AppError(
      type: ErrorType.flutter,
      message: details.exception.toString(),
      stackTrace: details.stack.toString(),
      timestamp: DateTime.now(),
      context: details.context?.toString(),
    );
    
    _logError(error);
    
    // In debug mode, show the error
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  }
  
  /// Handle platform errors
  void _handlePlatformError(Object error, StackTrace stack) {
    final appError = AppError(
      type: ErrorType.platform,
      message: error.toString(),
      stackTrace: stack.toString(),
      timestamp: DateTime.now(),
    );
    
    _logError(appError);
  }
  
  /// Handle application errors
  void handleError({
    required String message,
    ErrorType type = ErrorType.application,
    String? stackTrace,
    String? context,
    Map<String, dynamic>? metadata,
  }) {
    final error = AppError(
      type: type,
      message: message,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
      context: context,
      metadata: metadata,
    );
    
    _logError(error);
  }
  
  /// Handle AI model errors
  void handleAIError({
    required String modelName,
    required String operation,
    required dynamic error,
    StackTrace? stackTrace,
  }) {
    handleError(
      message: 'AI model error in $modelName during $operation: $error',
      type: ErrorType.aiModel,
      stackTrace: stackTrace?.toString(),
      context: 'AI Processing',
      metadata: {
        'modelName': modelName,
        'operation': operation,
        'error': error.toString(),
      },
    );
  }
  
  /// Handle file operation errors
  void handleFileError({
    required String operation,
    required String filePath,
    required dynamic error,
    StackTrace? stackTrace,
  }) {
    handleError(
      message: 'File error during $operation: $error',
      type: ErrorType.file,
      stackTrace: stackTrace?.toString(),
      context: 'File Operation',
      metadata: {
        'operation': operation,
        'filePath': filePath,
        'error': error.toString(),
      },
    );
  }
  
  /// Handle network errors
  void handleNetworkError({
    required String endpoint,
    required dynamic error,
    StackTrace? stackTrace,
    int? statusCode,
  }) {
    handleError(
      message: 'Network error accessing $endpoint: $error',
      type: ErrorType.network,
      stackTrace: stackTrace?.toString(),
      context: 'Network Request',
      metadata: {
        'endpoint': endpoint,
        'statusCode': statusCode,
        'error': error.toString(),
      },
    );
  }
  
  /// Log error to internal storage
  void _logError(AppError error) {
    _errorLog.add(error);
    _errorController.add(error);
    
    // Keep only last 100 errors
    if (_errorLog.length > 100) {
      _errorLog.removeAt(0);
    }
    
    // Log to console in debug mode
    if (kDebugMode) {
      print('ERROR [${error.type}]: ${error.message}');
      if (error.stackTrace != null) {
        print('Stack trace: ${error.stackTrace}');
      }
    }
  }
  
  /// Get error stream
  Stream<AppError> get errorStream => _errorController.stream;
  
  /// Get error log
  List<AppError> get errorLog => List.unmodifiable(_errorLog);
  
  /// Get recent errors
  List<AppError> getRecentErrors({int count = 10}) {
    final startIndex = _errorLog.length > count ? _errorLog.length - count : 0;
    return _errorLog.sublist(startIndex);
  }
  
  /// Get errors by type
  List<AppError> getErrorsByType(ErrorType type) {
    return _errorLog.where((error) => error.type == type).toList();
  }
  
  /// Clear error log
  void clearErrorLog() {
    _errorLog.clear();
  }
  
  /// Check if there are critical errors
  bool hasCriticalErrors() {
    return _errorLog.any((error) => error.type == ErrorType.critical);
  }
  
  /// Get error statistics
  Map<String, dynamic> getErrorStatistics() {
    final typeCounts = <ErrorType, int>{};
    for (final error in _errorLog) {
      typeCounts[error.type] = (typeCounts[error.type] ?? 0) + 1;
    }
    
    return {
      'totalErrors': _errorLog.length,
      'typeCounts': typeCounts.map((key, value) => MapEntry(key.toString(), value)),
      'hasCritical': hasCriticalErrors(),
      'lastError': _errorLog.isNotEmpty ? _errorLog.last.toJson() : null,
    };
  }
  
  /// Dispose resources
  void dispose() {
    _errorController.close();
  }
}

/// App error class
class AppError {
  final ErrorType type;
  final String message;
  final String? stackTrace;
  final DateTime timestamp;
  final String? context;
  final Map<String, dynamic>? metadata;
  
  AppError({
    required this.type,
    required this.message,
    this.stackTrace,
    required this.timestamp,
    this.context,
    this.metadata,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'message': message,
      'stackTrace': stackTrace,
      'timestamp': timestamp.toIso8601String(),
      'context': context,
      'metadata': metadata,
    };
  }
  
  @override
  String toString() {
    return 'AppError(type: $type, message: $message, timestamp: $timestamp)';
  }
}

/// Error type enum
enum ErrorType {
  flutter,
  platform,
  application,
  aiModel,
  file,
  network,
  critical,
}