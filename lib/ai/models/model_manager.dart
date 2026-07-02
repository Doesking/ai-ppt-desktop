import 'package:flutter/foundation.dart';
import '../engines/ai_engine.dart';
import '../engines/tflite_engine.dart';

class ModelManager {
  final Map<String, AIEngine> _models = {};
  final Map<String, bool> _loadingStatus = {};
  
  /// Load a model by name
  Future<void> loadModel(String modelName, {String? modelPath}) async {
    if (_models.containsKey(modelName)) {
      debugPrint('Model $modelName is already loaded');
      return;
    }
    
    _loadingStatus[modelName] = true;
    
    try {
      final engine = TFLiteEngine();
      final path = modelPath ?? 'assets/models/$modelName';
      
      await engine.loadModel(path);
      _models[modelName] = engine;
      
      debugPrint('Model $modelName loaded successfully');
    } catch (e) {
      debugPrint('Failed to load model $modelName: $e');
      rethrow;
    } finally {
      _loadingStatus[modelName] = false;
    }
  }
  
  /// Get a loaded model
  AIEngine? getModel(String modelName) {
    return _models[modelName];
  }
  
  /// Check if model is loaded
  bool isModelLoaded(String modelName) {
    return _models.containsKey(modelName) && 
           (_models[modelName]?.isModelLoaded ?? false);
  }
  
  /// Check if model is loading
  bool isModelLoading(String modelName) {
    return _loadingStatus[modelName] ?? false;
  }
  
  /// Run inference with a specific model
  Future<List<dynamic>> runInference({
    required String modelName,
    required List<dynamic> input,
  }) async {
    final model = _models[modelName];
    if (model == null) {
      throw AIEngineException('Model $modelName not loaded');
    }
    
    return await model.runInference(input);
  }
  
  /// Unload a model
  void unloadModel(String modelName) {
    final model = _models.remove(modelName);
    model?.dispose();
    _loadingStatus.remove(modelName);
    
    debugPrint('Model $modelName unloaded');
  }
  
  /// Unload all models
  void unloadAllModels() {
    for (final model in _models.values) {
      model.dispose();
    }
    _models.clear();
    _loadingStatus.clear();
    
    debugPrint('All models unloaded');
  }
  
  /// Get list of loaded models
  List<String> get loadedModels => _models.keys.toList();
  
  /// Get model info
  Map<String, dynamic> getModelInfo(String modelName) {
    final model = _models[modelName];
    if (model == null) {
      return {'loaded': false};
    }
    
    return {
      'loaded': model.isModelLoaded,
      'type': model.runtimeType.toString(),
    };
  }
  
  /// Preload essential models
  Future<void> preloadEssentialModels() async {
    final essentialModels = [
      'text_generation.tflite',
      'speech_recognition.tflite',
    ];
    
    for (final modelName in essentialModels) {
      try {
        await loadModel(modelName);
      } catch (e) {
        debugPrint('Warning: Failed to preload essential model $modelName: $e');
      }
    }
  }
  
  /// Dispose all resources
  void dispose() {
    unloadAllModels();
  }
}