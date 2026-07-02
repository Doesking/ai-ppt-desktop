import 'package:flutter_test/flutter_test.dart';
import 'package:ai_ppt_desktop/data/services/ppt_service.dart';

void main() {
  group('PPTService Tests', () {
    late PPTService pptService;
    
    setUp(() {
      pptService = PPTService();
    });
    
    test('Create presentation with title', () async {
      final presentation = await pptService.createPresentation(
        title: 'Test Presentation',
        author: 'Test Author',
        company: 'Test Company',
      );
      
      expect(presentation, isNotNull);
      expect(presentation.title, equals('Test Presentation'));
      expect(presentation.author, equals('Test Author'));
      expect(presentation.company, equals('Test Company'));
    });
    
    test('Add title and bullets slide', () async {
      final presentation = await pptService.createPresentation(
        title: 'Test Presentation',
      );
      
      pptService.addTitleAndBulletsSlide(
        presentation: presentation,
        title: 'Test Slide',
        subtitle: 'Test Subtitle',
        bullets: ['Bullet 1', 'Bullet 2', 'Bullet 3'],
      );
      
      // Note: We can't directly test slide count without accessing internal state
      // This test verifies the method doesn't throw an exception
    });
    
    test('Add section slide', () async {
      final presentation = await pptService.createPresentation(
        title: 'Test Presentation',
      );
      
      pptService.addSectionSlide(
        presentation: presentation,
        section: 'Test Section',
      );
      
      // Note: We can't directly test slide count without accessing internal state
      // This test verifies the method doesn't throw an exception
    });
    
    test('Set presentation layout', () async {
      final presentation = await pptService.createPresentation(
        title: 'Test Presentation',
      );
      
      // Test different layout types
      pptService.setLayout(presentation: presentation, layoutType: '16x9');
      pptService.setLayout(presentation: presentation, layoutType: '4x3');
      pptService.setLayout(presentation: presentation, layoutType: '16x10');
      pptService.setLayout(presentation: presentation, layoutType: 'wide');
      
      // Note: We can't directly test layout without accessing internal state
      // This test verifies the method doesn't throw an exception
    });
    
    test('Show slide numbers', () async {
      final presentation = await pptService.createPresentation(
        title: 'Test Presentation',
      );
      
      pptService.showSlideNumbers(presentation: presentation, show: true);
      pptService.showSlideNumbers(presentation: presentation, show: false);
      
      // Note: We can't directly test slide numbers without accessing internal state
      // This test verifies the method doesn't throw an exception
    });
    
    test('Create from markdown', () async {
      final markdown = '''
# Test Presentation

## Slide 1
Content for slide 1

## Slide 2
Content for slide 2
''';
      
      final presentation = await pptService.createFromMarkdown(markdown);
      
      expect(presentation, isNotNull);
    });
  });
}