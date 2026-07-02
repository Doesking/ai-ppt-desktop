import 'package:flutter_test/flutter_test.dart';
import 'package:ai_ppt_desktop/ai/engines/tflite_engine.dart';
import 'package:ai_ppt_desktop/ai/models/model_manager.dart';
import 'package:ai_ppt_desktop/ai/processors/content_generator.dart';
import 'package:ai_ppt_desktop/ai/processors/template_recommender.dart';

void main() {
  group('AI Engine Tests', () {
    test('TFLiteEngine initialization', () {
      final engine = TFLiteEngine();
      
      expect(engine.isModelLoaded, isFalse);
      expect(engine.inputShape, isNull);
      expect(engine.outputShape, isNull);
    });
    
    test('ModelManager operations', () {
      final manager = ModelManager();
      
      expect(manager.loadedModels, isEmpty);
      expect(manager.isModelLoaded('test_model'), isFalse);
      expect(manager.isModelLoading('test_model'), isFalse);
    });
    
    test('ContentGenerator fallback content', () async {
      final manager = ModelManager();
      final generator = ContentGenerator(manager);
      
      // Test fallback content generation (without actual AI model)
      final content = await generator.generateContent(
        topic: 'Test Topic',
        style: 'business',
        slideCount: 5,
      );
      
      expect(content, isNotNull);
      expect(content['topic'], equals('Test Topic'));
      expect(content['style'], equals('business'));
      expect(content['content'], isNotEmpty);
    });
    
    test('TemplateRecommender recommendations', () async {
      final recommender = TemplateRecommender();
      
      final recommendations = await recommender.recommendTemplates(
        content: 'Business presentation about technology',
        style: 'business',
        maxRecommendations: 3,
      );
      
      expect(recommendations, isNotEmpty);
      expect(recommendations.length, lessThanOrEqualTo(3));
      
      for (final recommendation in recommendations) {
        expect(recommendation['name'], isNotNull);
        expect(recommendation['description'], isNotNull);
        expect(recommendation['score'], isNotNull);
      }
    });
    
    test('TemplateRecommender get all templates', () {
      final recommender = TemplateRecommender();
      final templates = recommender.getAllTemplates();
      
      expect(templates, isNotEmpty);
      expect(templates.length, greaterThan(0));
      
      for (final template in templates) {
        expect(template['id'], isNotNull);
        expect(template['name'], isNotNull);
        expect(template['category'], isNotNull);
      }
    });
    
    test('TemplateRecommender get template by ID', () {
      final recommender = TemplateRecommender();
      
      // Test existing template
      final template = recommender.getTemplateById('business_professional');
      expect(template, isNotNull);
      expect(template!['name'], equals('Business Professional'));
      
      // Test non-existing template
      final nonExisting = recommender.getTemplateById('non_existing');
      expect(nonExisting, isNull);
    });
    
    test('TemplateRecommender get templates by category', () {
      final recommender = TemplateRecommender();
      
      final businessTemplates = recommender.getTemplatesByCategory('business');
      expect(businessTemplates, isNotEmpty);
      
      for (final template in businessTemplates) {
        expect(template['category'], equals('business'));
      }
    });
    
    test('TemplateRecommender color scheme', () {
      final recommender = TemplateRecommender();
      
      final colors = recommender.getColorScheme('business_professional');
      expect(colors, isNotEmpty);
      expect(colors.length, greaterThan(0));
      
      // Test non-existing template
      final defaultColors = recommender.getColorScheme('non_existing');
      expect(defaultColors, isNotEmpty);
    });
    
    test('TemplateRecommender template preview', () {
      final recommender = TemplateRecommender();
      
      final preview = recommender.getTemplatePreview('business_professional');
      expect(preview, isNotEmpty);
      expect(preview['id'], equals('business_professional'));
      expect(preview['name'], equals('Business Professional'));
      expect(preview['previewElements'], isNotEmpty);
    });
    
    test('ContentGenerator slide structure', () async {
      final manager = ModelManager();
      final generator = ContentGenerator(manager);
      
      final slides = await generator.generateSlideStructure(
        topic: 'Test Topic',
        content: 'Section 1\n\nSection 2\n\nSection 3',
      );
      
      expect(slides, isNotEmpty);
      expect(slides.first['type'], equals('title'));
      expect(slides.last['type'], equals('conclusion'));
    });
    
    test('ContentGenerator speaker notes', () async {
      final manager = ModelManager();
      final generator = ContentGenerator(manager);
      
      final notes = await generator.generateSpeakerNotes(
        slideTitle: 'Test Slide',
        slideContent: 'Key point 1\nKey point 2\nKey point 3',
      );
      
      expect(notes, isNotEmpty);
      expect(notes, contains('Test Slide'));
      expect(notes, contains('Key point 1'));
    });
  });
}