import 'dart:async';
import 'package:flutter/foundation.dart';

class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();
  
  final Map<String, Stopwatch> _timers = {};
  final List<PerformanceMetric> _metrics = [];
  final StreamController<PerformanceMetric> _metricController = 
      StreamController<PerformanceMetric>.broadcast();
  
  /// Start a performance timer
  void startTimer(String name) {
    _timers[name] = Stopwatch()..start();
  }
  
  /// Stop a performance timer and record the metric
  Duration? stopTimer(String name) {
    final timer = _timers[name];
    if (timer == null) return null;
    
    timer.stop();
    final duration = timer.elapsed;
    
    _recordMetric(PerformanceMetric(
      name: name,
      value: duration.inMilliseconds.toDouble(),
      unit: 'ms',
      timestamp: DateTime.now(),
    ));
    
    _timers.remove(name);
    return duration;
  }
  
  /// Record a custom metric
  void recordMetric({
    required String name,
    required double value,
    String unit = 'count',
    Map<String, dynamic>? metadata,
  }) {
    _recordMetric(PerformanceMetric(
      name: name,
      value: value,
      unit: unit,
      timestamp: DateTime.now(),
      metadata: metadata,
    ));
  }
  
  /// Record AI inference performance
  void recordAIInference({
    required String modelName,
    required Duration inferenceTime,
    required int inputSize,
    required int outputSize,
    bool success = true,
  }) {
    recordMetric(
      name: 'ai_inference',
      value: inferenceTime.inMilliseconds.toDouble(),
      unit: 'ms',
      metadata: {
        'modelName': modelName,
        'inputSize': inputSize,
        'outputSize': outputSize,
        'success': success,
      },
    );
  }
  
  /// Record PPT generation performance
  void recordPPTGeneration({
    required int slideCount,
    required Duration generationTime,
    required int fileSize,
    bool success = true,
  }) {
    recordMetric(
      name: 'ppt_generation',
      value: generationTime.inMilliseconds.toDouble(),
      unit: 'ms',
      metadata: {
        'slideCount': slideCount,
        'fileSize': fileSize,
        'success': success,
      },
    );
  }
  
  /// Record audio processing performance
  void recordAudioProcessing({
    required Duration processingTime,
    required Duration audioDuration,
    required int transcriptionLength,
    bool success = true,
  }) {
    recordMetric(
      name: 'audio_processing',
      value: processingTime.inMilliseconds.toDouble(),
      unit: 'ms',
      metadata: {
        'audioDuration': audioDuration.inSeconds,
        'transcriptionLength': transcriptionLength,
        'success': success,
      },
    );
  }
  
  /// Record video processing performance
  void recordVideoProcessing({
    required Duration processingTime,
    required Duration videoDuration,
    required int frameCount,
    required int sceneChanges,
    bool success = true,
  }) {
    recordMetric(
      name: 'video_processing',
      value: processingTime.inMilliseconds.toDouble(),
      unit: 'ms',
      metadata: {
        'videoDuration': videoDuration.inSeconds,
        'frameCount': frameCount,
        'sceneChanges': sceneChanges,
        'success': success,
      },
    );
  }
  
  /// Record memory usage
  void recordMemoryUsage() {
    // Note: This is a simplified implementation
    // In a real app, you would use platform-specific methods
    recordMetric(
      name: 'memory_usage',
      value: 0, // Placeholder
      unit: 'MB',
    );
  }
  
  /// Record UI performance
  void recordUIPerformance({
    required String screen,
    required Duration buildTime,
    required int widgetCount,
  }) {
    recordMetric(
      name: 'ui_performance',
      value: buildTime.inMilliseconds.toDouble(),
      unit: 'ms',
      metadata: {
        'screen': screen,
        'widgetCount': widgetCount,
      },
    );
  }
  
  void _recordMetric(PerformanceMetric metric) {
    _metrics.add(metric);
    _metricController.add(metric);
    
    // Keep only last 1000 metrics
    if (_metrics.length > 1000) {
      _metrics.removeAt(0);
    }
    
    // Log in debug mode
    if (kDebugMode) {
      print('PERF [${metric.name}]: ${metric.value}${metric.unit}');
    }
  }
  
  /// Get metric stream
  Stream<PerformanceMetric> get metricStream => _metricController.stream;
  
  /// Get all metrics
  List<PerformanceMetric> get metrics => List.unmodifiable(_metrics);
  
  /// Get metrics by name
  List<PerformanceMetric> getMetricsByName(String name) {
    return _metrics.where((m) => m.name == name).toList();
  }
  
  /// Get average metric value
  double getAverageMetric(String name) {
    final namedMetrics = getMetricsByName(name);
    if (namedMetrics.isEmpty) return 0;
    
    final sum = namedMetrics.fold(0.0, (sum, m) => sum + m.value);
    return sum / namedMetrics.length;
  }
  
  /// Get performance statistics
  Map<String, dynamic> getPerformanceStatistics() {
    final nameGroups = <String, List<PerformanceMetric>>{};
    for (final metric in _metrics) {
      nameGroups[metric.name] = (nameGroups[metric.name] ?? [])..add(metric);
    }
    
    final stats = <String, dynamic>{};
    for (final entry in nameGroups.entries) {
      final values = entry.value.map((m) => m.value).toList();
      stats[entry.key] = {
        'count': values.length,
        'average': values.fold(0.0, (a, b) => a + b) / values.length,
        'min': values.reduce((a, b) => a < b ? a : b),
        'max': values.reduce((a, b) => a > b ? a : b),
      };
    }
    
    return {
      'totalMetrics': _metrics.length,
      'metrics': stats,
    };
  }
  
  /// Clear metrics
  void clearMetrics() {
    _metrics.clear();
  }
  
  /// Dispose resources
  void dispose() {
    _metricController.close();
    _timers.clear();
  }
}

/// Performance metric class
class PerformanceMetric {
  final String name;
  final double value;
  final String unit;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  
  PerformanceMetric({
    required this.name,
    required this.value,
    required this.unit,
    required this.timestamp,
    this.metadata,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'unit': unit,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
  
  @override
  String toString() {
    return 'PerformanceMetric(name: $name, value: $value$unit, timestamp: $timestamp)';
  }
}