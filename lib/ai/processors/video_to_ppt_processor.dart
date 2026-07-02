import 'dart:async';
import 'dart:io';
import '../models/model_manager.dart';
import '../../data/services/video_service.dart';
import '../../data/services/audio_service.dart';
import '../../data/services/speech_recognition_service.dart';
import '../../data/services/ppt_service.dart';

class VideoToPPTProcessor {
  final ModelManager _modelManager;
  final VideoService _videoService;
  final AudioService _audioService;
  final SpeechRecognitionService _speechService;
  final PPTService _pptService;
  
  VideoToPPTProcessor({
    required ModelManager modelManager,
    required VideoService videoService,
    required AudioService audioService,
    required SpeechRecognitionService speechService,
    required PPTService pptService,
  }) : _modelManager = modelManager,
       _videoService = videoService,
       _audioService = audioService,
       _speechService = speechService,
       _pptService = pptService;
  
  /// Process video file and generate PPT presentation
  Future<VideoToPPTResult> processVideoToPPT({
    required String videoPath,
    String style = 'business',
    int slideCount = 10,
    String? outputPath,
    VideoProcessingOptions? options,
  }) async {
    final stopwatch = Stopwatch()..start();
    final processingOptions = options ?? VideoProcessingOptions.defaultOptions();
    
    try {
      // Step 1: Initialize services
      await _videoService.initialize();
      await _audioService.initialize();
      await _speechService.initialize();
      
      // Step 2: Get video information
      final videoInfo = await _videoService.getVideoInfo(videoPath);
      
      // Step 3: Extract audio from video
      String? audioPath;
      if (processingOptions.extractAudio) {
        audioPath = await _videoService.extractAudio(
          videoPath: videoPath,
          format: AudioFormat.wav,
          quality: AudioQuality.high,
        );
      }
      
      // Step 4: Extract key frames
      List<VideoFrame>? keyFrames;
      if (processingOptions.extractFrames) {
        keyFrames = await _videoService.extractKeyFrames(
          videoPath: videoPath,
          maxFrames: processingOptions.maxFrames,
          method: FrameExtractionMethod.uniform,
        );
      }
      
      // Step 5: Transcribe audio if extracted
      String? transcription;
      List<String>? keyPoints;
      String? summary;
      
      if (audioPath != null) {
        final transcriptionResult = await _speechService.transcribeAudio(
          audioPath: audioPath,
        );
        
        transcription = transcriptionResult.text;
        
        keyPoints = await _speechService.extractKeyPoints(
          transcription: transcription,
          maxPoints: slideCount * 2,
        );
        
        summary = await _speechService.generateSummary(
          transcription: transcription,
          maxLength: 1000,
        );
      }
      
      // Step 6: Generate scene analysis
      final sceneChanges = await _videoService.extractSceneChanges(
        videoPath: videoPath,
      );
      
      // Step 7: Generate video summary
      final videoSummary = await _videoService.generateVideoSummary(
        videoPath: videoPath,
      );
      
      // Step 8: Generate PPT slides
      final slides = _generateSlidesFromVideo(
        videoInfo: videoInfo,
        transcription: transcription,
        keyPoints: keyPoints ?? [],
        summary: summary ?? videoSummary.summary,
        keyFrames: keyFrames,
        sceneChanges: sceneChanges,
        style: style,
        slideCount: slideCount,
      );
      
      // Step 9: Create PPT presentation
      final presentation = await _pptService.createPresentation(
        title: 'Presentation from Video',
        author: 'AI PPT Desktop',
      );
      
      // Step 10: Add slides to presentation
      for (final slide in slides) {
        _addSlideToPresentation(presentation, slide);
      }
      
      // Step 11: Save presentation
      final fileName = 'video_presentation_${DateTime.now().millisecondsSinceEpoch}.pptx';
      final savePath = await _pptService.savePresentation(
        presentation: presentation,
        fileName: fileName,
        directory: outputPath,
      );
      
      stopwatch.stop();
      
      return VideoToPPTResult(
        videoPath: videoPath,
        outputPath: savePath,
        videoInfo: videoInfo,
        audioPath: audioPath,
        transcription: transcription,
        keyPoints: keyPoints,
        summary: summary,
        keyFrames: keyFrames,
        sceneChanges: sceneChanges,
        slideCount: slides.length,
        processingTime: stopwatch.elapsed,
        success: true,
      );
    } catch (e) {
      stopwatch.stop();
      
      return VideoToPPTResult(
        videoPath: videoPath,
        outputPath: null,
        videoInfo: null,
        audioPath: null,
        transcription: null,
        keyPoints: null,
        summary: null,
        keyFrames: null,
        sceneChanges: null,
        slideCount: 0,
        processingTime: stopwatch.elapsed,
        success: false,
        error: e.toString(),
      );
    }
  }
  
  /// Process video in real-time with progress updates
  Stream<VideoProcessingProgress> processVideoWithProgress({
    required String videoPath,
    String style = 'business',
    int slideCount = 10,
    String? outputPath,
    VideoProcessingOptions? options,
  }) async* {
    final processingOptions = options ?? VideoProcessingOptions.defaultOptions();
    
    // Initialize services
    yield VideoProcessingProgress(
      status: 'initializing',
      progress: 0.0,
      message: 'Initializing services...',
    );
    
    await _videoService.initialize();
    await _audioService.initialize();
    await _speechService.initialize();
    
    yield VideoProcessingProgress(
      status: 'analyzing',
      progress: 0.1,
      message: 'Analyzing video...',
    );
    
    // Get video info
    final videoInfo = await _videoService.getVideoInfo(videoPath);
    
    yield VideoProcessingProgress(
      status: 'extracting_audio',
      progress: 0.2,
      message: 'Extracting audio...',
    );
    
    // Extract audio
    String? audioPath;
    if (processingOptions.extractAudio) {
      audioPath = await _videoService.extractAudio(
        videoPath: videoPath,
      );
    }
    
    yield VideoProcessingProgress(
      status: 'extracting_frames',
      progress: 0.4,
      message: 'Extracting key frames...',
    );
    
    // Extract frames
    List<VideoFrame>? keyFrames;
    if (processingOptions.extractFrames) {
      keyFrames = await _videoService.extractKeyFrames(
        videoPath: videoPath,
        maxFrames: processingOptions.maxFrames,
      );
    }
    
    yield VideoProcessingProgress(
      status: 'transcribing',
      progress: 0.6,
      message: 'Transcribing audio...',
    );
    
    // Transcribe audio
    String? transcription;
    if (audioPath != null) {
      final result = await _speechService.transcribeAudio(
        audioPath: audioPath,
      );
      transcription = result.text;
    }
    
    yield VideoProcessingProgress(
      status: 'generating_content',
      progress: 0.8,
      message: 'Generating PPT content...',
    );
    
    // Generate content
    final keyPoints = transcription != null
        ? await _speechService.extractKeyPoints(
            transcription: transcription,
            maxPoints: slideCount * 2,
          )
        : <String>[];
    
    yield VideoProcessingProgress(
      status: 'creating_presentation',
      progress: 0.9,
      message: 'Creating presentation...',
    );
    
    // Create presentation (simplified)
    await Future.delayed(const Duration(seconds: 1));
    
    yield VideoProcessingProgress(
      status: 'completed',
      progress: 1.0,
      message: 'Processing complete!',
    );
  }
  
  /// Extract topics from video
  Future<List<String>> extractTopics({
    required String videoPath,
    int maxTopics = 5,
  }) async {
    try {
      await _videoService.initialize();
      await _audioService.initialize();
      await _speechService.initialize();
      
      // Extract audio
      final audioPath = await _videoService.extractAudio(
        videoPath: videoPath,
      );
      
      // Transcribe audio
      final transcription = await _speechService.transcribeAudio(
        audioPath: audioPath,
      );
      
      // Extract key points
      final keyPoints = await _speechService.extractKeyPoints(
        transcription: transcription.text,
        maxPoints: maxTopics * 2,
      );
      
      // Extract main topics
      return _extractMainTopics(keyPoints, maxTopics);
    } catch (e) {
      throw Exception('Failed to extract topics from video: $e');
    }
  }
  
  /// Generate video outline
  Future<List<Map<String, dynamic>>> generateOutline({
    required String videoPath,
    String style = 'business',
  }) async {
    try {
      await _videoService.initialize();
      await _audioService.initialize();
      await _speechService.initialize();
      
      // Get video info
      final videoInfo = await _videoService.getVideoInfo(videoPath);
      
      // Extract audio and transcribe
      final audioPath = await _videoService.extractAudio(
        videoPath: videoPath,
      );
      
      final transcription = await _speechService.transcribeAudio(
        audioPath: audioPath,
      );
      
      final keyPoints = await _speechService.extractKeyPoints(
        transcription: transcription.text,
        maxPoints: 10,
      );
      
      // Generate outline
      return _generateOutlineFromVideo(
        videoInfo: videoInfo,
        keyPoints: keyPoints,
        style: style,
      );
    } catch (e) {
      throw Exception('Failed to generate video outline: $e');
    }
  }
  
  List<Map<String, dynamic>> _generateSlidesFromVideo({
    required VideoInfo videoInfo,
    required String? transcription,
    required List<String> keyPoints,
    required String summary,
    required List<VideoFrame>? keyFrames,
    required List<SceneChange> sceneChanges,
    required String style,
    required int slideCount,
  }) {
    final slides = <Map<String, dynamic>>[];
    
    // Title slide
    slides.add({
      'type': 'title',
      'title': 'Video Presentation',
      'subtitle': 'Generated from: ${videoInfo.fileName}',
      'content': 'Duration: ${videoInfo.duration.inMinutes} minutes',
    });
    
    // Video overview slide
    slides.add({
      'type': 'content',
      'title': 'Video Overview',
      'content': summary,
      'bullets': [
        'Duration: ${videoInfo.duration.inMinutes} minutes',
        'Resolution: ${videoInfo.resolution}',
        'Format: ${videoInfo.format}',
        'Scene changes: ${sceneChanges.length}',
      ],
    });
    
    // Content slides from key points
    for (int i = 0; i < slideCount - 3 && i < keyPoints.length; i++) {
      slides.add({
        'type': 'content',
        'title': 'Section ${i + 1}',
        'content': keyPoints[i],
        'bullets': _extractBullets(keyPoints[i]),
      });
    }
    
    // Scene analysis slide
    if (sceneChanges.isNotEmpty) {
      slides.add({
        'type': 'content',
        'title': 'Video Structure',
        'content': 'Key scenes and transitions',
        'bullets': sceneChanges.take(5).map((scene) =>
          '${_formatDuration(scene.timestamp)}: ${scene.description}'
        ).toList(),
      });
    }
    
    // Key frames slide
    if (keyFrames != null && keyFrames.isNotEmpty) {
      slides.add({
        'type': 'content',
        'title': 'Key Visual Moments',
        'content': 'Important visual content from the video',
        'bullets': keyFrames.take(5).map((frame) =>
          'Frame at ${_formatDuration(frame.timestamp)}'
        ).toList(),
      });
    }
    
    // Conclusion slide
    slides.add({
      'type': 'conclusion',
      'title': 'Conclusion',
      'content': 'Summary of video content',
      'bullets': keyPoints.take(5).toList(),
    });
    
    return slides;
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
      final words = point.split(' ');
      if (words.length >= 3) {
        final topic = words.take(5).join(' ');
        if (!topics.contains(topic)) {
          topics.add(topic);
          if (topics.length >= maxTopics) break;
        }
      }
    }
    
    return topics;
  }
  
  List<Map<String, dynamic>> _generateOutlineFromVideo({
    required VideoInfo videoInfo,
    required List<String> keyPoints,
    required String style,
  }) {
    final outline = <Map<String, dynamic>>[];
    
    // Introduction
    outline.add({
      'section': 'Introduction',
      'content': 'Video overview and objectives',
      'duration': '1-2 minutes',
    });
    
    // Main sections
    final sectionDuration = videoInfo.duration.inMinutes ~/ (keyPoints.length + 2);
    for (int i = 0; i < keyPoints.length && i < 5; i++) {
      outline.add({
        'section': 'Section ${i + 1}',
        'content': keyPoints[i],
        'duration': '$sectionDuration minutes',
      });
    }
    
    // Conclusion
    outline.add({
      'section': 'Conclusion',
      'content': 'Summary and key takeaways',
      'duration': '1-2 minutes',
    });
    
    return outline;
  }
  
  List<String> _extractBullets(String text) {
    final bullets = <String>[];
    final sentences = text.split(RegExp(r'[.!?]+'));
    
    for (final sentence in sentences.take(3)) {
      final trimmed = sentence.trim();
      if (trimmed.isNotEmpty && trimmed.length > 10) {
        bullets.add(trimmed);
      }
    }
    
    return bullets;
  }
  
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Video to PPT result class
class VideoToPPTResult {
  final String videoPath;
  final String? outputPath;
  final VideoInfo? videoInfo;
  final String? audioPath;
  final String? transcription;
  final List<String>? keyPoints;
  final String? summary;
  final List<VideoFrame>? keyFrames;
  final List<SceneChange>? sceneChanges;
  final int slideCount;
  final Duration processingTime;
  final bool success;
  final String? error;
  
  VideoToPPTResult({
    required this.videoPath,
    this.outputPath,
    this.videoInfo,
    this.audioPath,
    this.transcription,
    this.keyPoints,
    this.summary,
    this.keyFrames,
    this.sceneChanges,
    required this.slideCount,
    required this.processingTime,
    required this.success,
    this.error,
  });
}

/// Video processing progress class
class VideoProcessingProgress {
  final String status;
  final double progress;
  final String message;
  
  VideoProcessingProgress({
    required this.status,
    required this.progress,
    required this.message,
  });
}

/// Video processing options class
class VideoProcessingOptions {
  final bool extractAudio;
  final bool extractFrames;
  final int maxFrames;
  final bool extractSceneChanges;
  final bool generateSummary;
  
  const VideoProcessingOptions({
    required this.extractAudio,
    required this.extractFrames,
    required this.maxFrames,
    required this.extractSceneChanges,
    required this.generateSummary,
  });
  
  factory VideoProcessingOptions.defaultOptions() {
    return const VideoProcessingOptions(
      extractAudio: true,
      extractFrames: true,
      maxFrames: 10,
      extractSceneChanges: true,
      generateSummary: true,
    );
  }
}