import 'dart:async';
import '../models/model_manager.dart';
import '../../data/services/speech_recognition_service.dart';
import '../../data/services/ppt_service.dart';

class SpeechToPPTProcessor {
  final ModelManager _modelManager;
  final SpeechRecognitionService _speechService;
  final PPTService _pptService;
  
  SpeechToPPTProcessor({
    required ModelManager modelManager,
    required SpeechRecognitionService speechService,
    required PPTService pptService,
  }) : _modelManager = modelManager,
       _speechService = speechService,
       _pptService = pptService;
  
  /// Process audio file and generate PPT presentation
  Future<SpeechToPPTResult> processAudioToPPT({
    required String audioPath,
    String style = 'business',
    int slideCount = 10,
    String? outputPath,
    Map<String, dynamic>? options,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      // Step 1: Initialize services
      await _speechService.initialize();
      
      // Step 2: Process audio to get content
      final audioResult = await _speechService.processAudioForPPT(
        audioPath: audioPath,
        style: style,
        slideCount: slideCount,
      );
      
      // Step 3: Generate PPT presentation
      final presentation = await _pptService.createPresentation(
        title: 'Presentation from Audio',
        author: 'AI PPT Desktop',
      );
      
      // Step 4: Add slides from audio content
      for (final slide in audioResult.slides) {
        _addSlideToPresentation(presentation, slide);
      }
      
      // Step 5: Save presentation
      final fileName = 'audio_presentation_${DateTime.now().millisecondsSinceEpoch}.pptx';
      final savePath = await _pptService.savePresentation(
        presentation: presentation,
        fileName: fileName,
        directory: outputPath,
      );
      
      stopwatch.stop();
      
      return SpeechToPPTResult(
        audioPath: audioPath,
        outputPath: savePath,
        transcription: audioResult.transcription.text,
        keyPoints: audioResult.keyPoints,
        summary: audioResult.summary,
        slideCount: audioResult.slides.length,
        processingTime: stopwatch.elapsed,
        success: true,
      );
    } catch (e) {
      stopwatch.stop();
      
      return SpeechToPPTResult(
        audioPath: audioPath,
        outputPath: null,
        transcription: null,
        keyPoints: null,
        summary: null,
        slideCount: 0,
        processingTime: stopwatch.elapsed,
        success: false,
        error: e.toString(),
      );
    }
  }
  
  /// Process audio stream in real-time
  Stream<RealTimeProcessingResult> processAudioStream({
    required Stream<List<int>> audioStream,
    String style = 'business',
    int slideCount = 10,
  }) async* {
    final buffer = <int>[];
    final results = <String>[];
    
    await for (final chunk in audioStream) {
      buffer.addAll(chunk);
      
      // Process when buffer reaches certain size
      if (buffer.length >= 16000) { // ~1 second of audio at 16kHz
        final audioData = List<int>.from(buffer);
        buffer.clear();
        
        // Simulate real-time processing
        await Future.delayed(const Duration(milliseconds: 100));
        
        yield RealTimeProcessingResult(
          status: 'processing',
          progress: results.length / slideCount,
          currentText: 'Processing audio chunk...',
          partialResults: results,
        );
      }
    }
    
    // Final processing
    yield RealTimeProcessingResult(
      status: 'completed',
      progress: 1.0,
      currentText: 'Processing complete',
      partialResults: results,
    );
  }
  
  /// Extract topics from audio content
  Future<List<String>> extractTopics({
    required String audioPath,
    int maxTopics = 5,
  }) async {
    try {
      await _speechService.initialize();
      
      final transcription = await _speechService.transcribeAudio(
        audioPath: audioPath,
      );
      
      final keyPoints = await _speechService.extractKeyPoints(
        transcription: transcription.text,
        maxPoints: maxTopics * 2,
      );
      
      // Extract main topics from key points
      return _extractMainTopics(keyPoints, maxTopics);
    } catch (e) {
      throw Exception('Failed to extract topics: $e');
    }
  }
  
  /// Generate outline from audio
  Future<List<Map<String, dynamic>>> generateOutline({
    required String audioPath,
    String style = 'business',
  }) async {
    try {
      await _speechService.initialize();
      
      final transcription = await _speechService.transcribeAudio(
        audioPath: audioPath,
      );
      
      final keyPoints = await _speechService.extractKeyPoints(
        transcription: transcription.text,
        maxPoints: 10,
      );
      
      final summary = await _speechService.generateSummary(
        transcription: transcription.text,
        maxLength: 500,
      );
      
      return _generateOutlineFromContent(
        transcription: transcription.text,
        keyPoints: keyPoints,
        summary: summary,
        style: style,
      );
    } catch (e) {
      throw Exception('Failed to generate outline: $e');
    }
  }
  
  void _addSlideToPresentation(dynamic presentation, Map<String, dynamic> slide) {
    final type = slide['type'] as String? ?? 'content';
    final title = slide['title'] as String? ?? 'Untitled';
    final content = slide['content'] as String? ?? '';
    final bullets = slide['bullets'] as List<String>? ?? [];
    
    switch (type) {
      case 'title':
        _pptService.addTitleAndBulletsSlide(
          presentation: presentation,
          title: title,
          subtitle: content,
          bullets: bullets,
        );
        break;
      case 'content':
        _pptService.addTitleAndBulletsSlide(
          presentation: presentation,
          title: title,
          bullets: bullets.isNotEmpty ? bullets : [content],
        );
        break;
      case 'section':
        _pptService.addSectionSlide(
          presentation: presentation,
          section: title,
        );
        break;
      case 'quote':
        _pptService.addQuoteSlide(
          presentation: presentation,
          quote: content,
          attribution: slide['attribution'] as String? ?? 'Unknown',
        );
        break;
      default:
        _pptService.addTitleAndBulletsSlide(
          presentation: presentation,
          title: title,
          bullets: [content],
        );
    }
  }
  
  List<String> _extractMainTopics(List<String> keyPoints, int maxTopics) {
    final topics = <String>[];
    
    for (final point in keyPoints) {
      // Extract main topic from each key point
      final words = point.split(' ');
      if (words.length >= 3) {
        // Take first few words as topic
        final topic = words.take(5).join(' ');
        if (!topics.contains(topic)) {
          topics.add(topic);
          if (topics.length >= maxTopics) break;
        }
      }
    }
    
    return topics;
  }
  
  List<Map<String, dynamic>> _generateOutlineFromContent({
    required String transcription,
    required List<String> keyPoints,
    required String summary,
    required String style,
  }) {
    final outline = <Map<String, dynamic>>[];
    
    // Introduction
    outline.add({
      'section': 'Introduction',
      'content': summary,
      'duration': '2-3 minutes',
    });
    
    // Main sections from key points
    for (int i = 0; i < keyPoints.length && i < 5; i++) {
      outline.add({
        'section': 'Section ${i + 1}',
        'content': keyPoints[i],
        'duration': '3-4 minutes',
      });
    }
    
    // Conclusion
    outline.add({
      'section': 'Conclusion',
      'content': 'Summary and Q&A',
      'duration': '2-3 minutes',
    });
    
    return outline;
  }
}

/// Speech to PPT result class
class SpeechToPPTResult {
  final String audioPath;
  final String? outputPath;
  final String? transcription;
  final List<String>? keyPoints;
  final String? summary;
  final int slideCount;
  final Duration processingTime;
  final bool success;
  final String? error;
  
  SpeechToPPTResult({
    required this.audioPath,
    this.outputPath,
    this.transcription,
    this.keyPoints,
    this.summary,
    required this.slideCount,
    required this.processingTime,
    required this.success,
    this.error,
  });
}

/// Real-time processing result class
class RealTimeProcessingResult {
  final String status;
  final double progress;
  final String currentText;
  final List<String> partialResults;
  
  RealTimeProcessingResult({
    required this.status,
    required this.progress,
    required this.currentText,
    required this.partialResults,
  });
}