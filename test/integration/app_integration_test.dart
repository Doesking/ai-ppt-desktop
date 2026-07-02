import 'package:flutter_test/flutter_test.dart';
import 'package:ai_ppt_desktop/data/services/ppt_service.dart';
import 'package:ai_ppt_desktop/data/services/audio_service.dart';
import 'package:ai_ppt_desktop/data/services/video_service.dart';
import 'package:ai_ppt_desktop/data/services/speech_recognition_service.dart';
import 'package:ai_ppt_desktop/data/services/collaboration_service.dart';
import 'package:ai_ppt_desktop/data/services/brand_service.dart';
import 'package:ai_ppt_desktop/ai/models/model_manager.dart';
import 'package:ai_ppt_desktop/ai/processors/content_generator.dart';
import 'package:ai_ppt_desktop/ai/processors/template_recommender.dart';
import 'package:ai_ppt_desktop/ai/processors/speech_to_ppt_processor.dart';
import 'package:ai_ppt_desktop/ai/processors/video_to_ppt_processor.dart';
import 'package:ai_ppt_desktop/core/services/error_service.dart';
import 'package:ai_ppt_desktop/core/services/performance_service.dart';

void main() {
  group('App Integration Tests', () {
    late PPTService pptService;
    late AudioService audioService;
    late VideoService videoService;
    late SpeechRecognitionService speechService;
    late CollaborationService collaborationService;
    late BrandService brandService;
    late ModelManager modelManager;
    late ContentGenerator contentGenerator;
    late TemplateRecommender templateRecommender;
    late SpeechToPPTProcessor speechToPPTProcessor;
    late VideoToPPTProcessor videoToPPTProcessor;
    late ErrorService errorService;
    late PerformanceService performanceService;
    
    setUp(() {
      // Initialize all services
      pptService = PPTService();
      audioService = AudioService();
      videoService = VideoService();
      speechService = SpeechRecognitionService();
      collaborationService = CollaborationService();
      brandService = BrandService();
      modelManager = ModelManager();
      contentGenerator = ContentGenerator(modelManager);
      templateRecommender = TemplateRecommender();
      speechToPPTProcessor = SpeechToPPTProcessor(
        modelManager: modelManager,
        speechService: speechService,
        pptService: pptService,
      );
      videoToPPTProcessor = VideoToPPTProcessor(
        modelManager: modelManager,
        videoService: videoService,
        audioService: audioService,
        speechService: speechService,
        pptService: pptService,
      );
      errorService = ErrorService();
      performanceService = PerformanceService();
    });
    
    test('Service initialization test', () async {
      // Test that all services can be initialized
      expect(pptService, isNotNull);
      expect(audioService, isNotNull);
      expect(videoService, isNotNull);
      expect(speechService, isNotNull);
      expect(collaborationService, isNotNull);
      expect(brandService, isNotNull);
      expect(modelManager, isNotNull);
      expect(contentGenerator, isNotNull);
      expect(templateRecommender, isNotNull);
      expect(speechToPPTProcessor, isNotNull);
      expect(videoToPPTProcessor, isNotNull);
      expect(errorService, isNotNull);
      expect(performanceService, isNotNull);
    });
    
    test('PPT creation workflow test', () async {
      // Test complete PPT creation workflow
      final presentation = await pptService.createPresentation(
        title: 'Integration Test Presentation',
        author: 'Test Author',
        company: 'Test Company',
      );
      
      expect(presentation, isNotNull);
      
      // Add slides
      pptService.addTitleAndBulletsSlide(
        presentation: presentation,
        title: 'Test Slide 1',
        bullets: ['Bullet 1', 'Bullet 2', 'Bullet 3'],
      );
      
      pptService.addSectionSlide(
        presentation: presentation,
        section: 'Test Section',
      );
      
      pptService.addQuoteSlide(
        presentation: presentation,
        quote: 'This is a test quote',
        attribution: 'Test Author',
      );
      
      // Save presentation
      final filePath = await pptService.savePresentation(
        presentation: presentation,
        fileName: 'integration_test.pptx',
      );
      
      expect(filePath, isNotEmpty);
      expect(filePath.endsWith('.pptx'), isTrue);
    });
    
    test('AI content generation test', () async {
      // Test AI content generation
      final content = await contentGenerator.generateContent(
        topic: 'Integration Testing',
        style: 'business',
        slideCount: 5,
      );
      
      expect(content, isNotNull);
      expect(content['topic'], equals('Integration Testing'));
      expect(content['style'], equals('business'));
      expect(content['content'], isNotEmpty);
    });
    
    test('Template recommendation test', () async {
      // Test template recommendation
      final recommendations = await templateRecommender.recommendTemplates(
        content: 'Business presentation about technology',
        style: 'business',
        maxRecommendations: 3,
      );
      
      expect(recommendations, isNotEmpty);
      expect(recommendations.length, lessThanOrEqualTo(3));
      
      for (final recommendation in recommendations) {
        expect(recommendation['name'], isNotNull);
        expect(recommendation['description'], isNotNull);
      }
    });
    
    test('Speech recognition service test', () async {
      // Test speech recognition service initialization
      await speechService.initialize();
      expect(speechService.isInitialized, isTrue);
      
      // Test transcription (mock)
      final result = await speechService.transcribeAudio(
        audioPath: 'test_audio.wav',
      );
      
      expect(result, isNotNull);
      expect(result.text, isNotEmpty);
      expect(result.confidence, greaterThan(0));
    });
    
    test('Video service test', () async {
      // Test video service initialization
      await videoService.initialize();
      expect(videoService.isInitialized, isTrue);
    });
    
    test('Collaboration service test', () async {
      // Test collaboration service
      await collaborationService.initialize();
      expect(collaborationService.isInitialized, isTrue);
      
      // Create session
      final session = await collaborationService.createSession(
        presentationId: 'test_presentation',
        hostUserId: 'user_1',
        sessionName: 'Test Session',
      );
      
      expect(session, isNotNull);
      expect(session.isActive, isTrue);
      expect(session.participants, contains('user_1'));
      
      // End session
      await collaborationService.endSession(sessionId: session.id);
    });
    
    test('Brand service test', () async {
      // Test brand service
      await brandService.initialize();
      expect(brandService.isInitialized, isTrue);
      
      // Get default brands
      final brands = brandService.getAllBrandProfiles();
      expect(brands, isNotEmpty);
      
      // Get specific brand
      final corporateBrand = brandService.getBrandProfile('default_corporate');
      expect(corporateBrand, isNotNull);
      expect(corporateBrand!.name, equals('Corporate Blue'));
    });
    
    test('Error handling test', () {
      // Test error service
      errorService.handleError(
        message: 'Test error',
        type: ErrorType.application,
      );
      
      expect(errorService.errorLog, isNotEmpty);
      expect(errorService.errorLog.last.message, equals('Test error'));
      
      // Test error statistics
      final stats = errorService.getErrorStatistics();
      expect(stats['totalErrors'], greaterThan(0));
    });
    
    test('Performance monitoring test', () {
      // Test performance service
      performanceService.startTimer('test_timer');
      
      // Simulate some work
      Future.delayed(const Duration(milliseconds: 100));
      
      final duration = performanceService.stopTimer('test_timer');
      expect(duration, isNotNull);
      
      // Record custom metric
      performanceService.recordMetric(
        name: 'test_metric',
        value: 42.0,
        unit: 'count',
      );
      
      expect(performanceService.metrics, isNotEmpty);
      
      // Get statistics
      final stats = performanceService.getPerformanceStatistics();
      expect(stats['totalMetrics'], greaterThan(0));
    });
    
    test('Model manager test', () {
      // Test model manager
      expect(modelManager.loadedModels, isEmpty);
      expect(modelManager.isModelLoaded('test_model'), isFalse);
    });
    
    tearDown(() {
      // Clean up resources
      performanceService.dispose();
      errorService.dispose();
    });
  });
}