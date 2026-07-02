abstract class AIEngine {
  /// Load the AI model
  Future<void> loadModel(String modelPath);
  
  /// Run inference with the model
  Future<List<dynamic>> runInference(List<dynamic> input);
  
  /// Check if model is loaded
  bool get isModelLoaded;
  
  /// Dispose resources
  void dispose();
}

class AIEngineException implements Exception {
  final String message;
  final dynamic originalError;
  
  AIEngineException(this.message, [this.originalError]);
  
  @override
  String toString() => 'AIEngineException: $message';
}