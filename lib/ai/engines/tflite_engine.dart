import 'package:tflite_flutter/tflite_flutter.dart';
import 'ai_engine.dart';

class TFLiteEngine implements AIEngine {
  Interpreter? _interpreter;
  bool _isModelLoaded = false;
  
  @override
  bool get isModelLoaded => _isModelLoaded;
  
  @override
  Future<void> loadModel(String modelPath) async {
    try {
      _interpreter = await Interpreter.fromAsset(modelPath);
      _isModelLoaded = true;
    } catch (e) {
      throw AIEngineException('Failed to load TFLite model: $modelPath', e);
    }
  }
  
  @override
  Future<List<dynamic>> runInference(List<dynamic> input) async {
    if (_interpreter == null) {
      throw AIEngineException('Model not loaded. Call loadModel() first.');
    }
    
    try {
      // Prepare output buffer
      final output = List.generate(
        1,
        (_) => List.filled(10, 0.0), // Adjust based on model output shape
      );
      
      // Run inference
      _interpreter!.run(input, output);
      
      return output;
    } catch (e) {
      throw AIEngineException('Failed to run TFLite inference', e);
    }
  }
  
  /// Run inference with multiple inputs
  Future<Map<String, dynamic>> runInferenceWithDetails({
    required List<dynamic> input,
    required String modelType,
  }) async {
    if (_interpreter == null) {
      throw AIEngineException('Model not loaded. Call loadModel() first.');
    }
    
    try {
      final startTime = DateTime.now();
      
      // Prepare output buffer based on model type
      List<dynamic> output;
      switch (modelType) {
        case 'text_generation':
          output = List.generate(1, (_) => List.filled(100, 0.0));
          break;
        case 'image_classification':
          output = List.generate(1, (_) => List.filled(1000, 0.0));
          break;
        case 'speech_recognition':
          output = List.generate(1, (_) => List.filled(50, 0.0));
          break;
        default:
          output = List.generate(1, (_) => List.filled(10, 0.0));
      }
      
      // Run inference
      _interpreter!.run(input, output);
      
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      return {
        'output': output,
        'inferenceTime': duration.inMilliseconds,
        'modelType': modelType,
      };
    } catch (e) {
      throw AIEngineException('Failed to run TFLite inference with details', e);
    }
  }
  
  /// Get model input shape
  List<int>? get inputShape {
    return _interpreter?.getInputTensor(0).shape;
  }
  
  /// Get model output shape
  List<int>? get outputShape {
    return _interpreter?.getOutputTensor(0).shape;
  }
  
  /// Get model input type
  TfLiteType? get inputType {
    return _interpreter?.getInputTensor(0).type;
  }
  
  /// Get model output type
  TfLiteType? get outputType {
    return _interpreter?.getOutputTensor(0).type;
  }
  
  @override
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isModelLoaded = false;
  }
}