import 'dart:io';
import 'package:flutter_pptx/flutter_pptx.dart';
import 'package:dart_pptx/dart_pptx.dart';
import 'package:path/path.dart' as path;

class PPTService {
  /// Create a new presentation with title slide
  Future<Powerpoint> createPresentation({
    required String title,
    String? author,
    String? company,
  }) async {
    final pres = Powerpoint();
    
    // Set metadata
    pres.title = title;
    pres.author = author ?? 'AI PPT Desktop';
    pres.company = company ?? '';
    
    // Add title slide
    pres.addTitleSlide(
      title: title.toTextValue(),
      author: (author ?? 'AI PPT Desktop').toTextValue(),
    );
    
    return pres;
  }
  
  /// Add a title and bullets slide
  void addTitleAndBulletsSlide({
    required Powerpoint presentation,
    required String title,
    String? subtitle,
    required List<String> bullets,
  }) {
    presentation.addTitleAndBulletsSlide(
      title: title.toTextValue(),
      subtitle: subtitle?.toTextValue(),
      bullets: bullets.map((e) => e.toTextValue()).toList(),
    );
  }
  
  /// Add a section slide
  void addSectionSlide({
    required Powerpoint presentation,
    required String section,
  }) {
    presentation.addSectionSlide(
      section: section.toTextValue(),
    );
  }
  
  /// Add a quote slide
  void addQuoteSlide({
    required Powerpoint presentation,
    required String quote,
    required String attribution,
  }) {
    presentation.addQuoteSlide(
      quote: quote.toTextLine(),
      attribution: attribution.toTextValue(),
    );
  }
  
  /// Add a big fact slide
  void addBigFactSlide({
    required Powerpoint presentation,
    required String fact,
    required String information,
  }) {
    presentation.addBigFactSlide(
      fact: fact.toTextLine(),
      information: information.toTextValue(),
    );
  }
  
  /// Add a photo slide
  void addPhotoSlide({
    required Powerpoint presentation,
    required String imagePath,
    required String imageName,
  }) {
    presentation.addPhotoSlide(
      image: ImageReference(
        path: imagePath,
        name: imageName,
      ),
    );
  }
  
  /// Add a title and photo slide
  void addTitleAndPhotoSlide({
    required Powerpoint presentation,
    required String title,
    String? subtitle,
    required String imagePath,
    required String imageName,
  }) {
    presentation.addTitleAndPhotoSlide(
      title: title.toTextValue(),
      subtitle: subtitle?.toTextValue(),
      image: ImageReference(
        path: imagePath,
        name: imageName,
      ),
    );
  }
  
  /// Save presentation to file
  Future<String> savePresentation({
    required Powerpoint presentation,
    required String fileName,
    String? directory,
  }) async {
    final bytes = await presentation.save();
    
    // Determine save path
    final saveDir = directory ?? Directory.current.path;
    final filePath = path.join(saveDir, fileName.endsWith('.pptx') ? fileName : '$fileName.pptx');
    
    // Write to file
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    
    return filePath;
  }
  
  /// Create presentation from markdown
  Future<Powerpoint> createFromMarkdown(String markdown) async {
    final pres = Powerpoint();
    await pres.addSlidesFromMarkdown(markdown);
    return pres;
  }
  
  /// Set slide background color
  void setSlideBackgroundColor({
    required dynamic slide,
    required String colorHex,
  }) {
    slide.background.color = colorHex;
  }
  
  /// Set slide background image
  void setSlideBackgroundImage({
    required dynamic slide,
    required String imagePath,
    required String imageName,
  }) {
    slide.background.image = ImageReference(
      path: imagePath,
      name: imageName,
    );
  }
  
  /// Add speaker notes to slide
  void addSpeakerNotes({
    required dynamic slide,
    required String notes,
  }) {
    slide.speakerNotes = notes.toTextValue();
  }
  
  /// Set presentation layout
  void setLayout({
    required Powerpoint presentation,
    String layoutType = '16x9',
  }) {
    switch (layoutType) {
      case '4x3':
        presentation.layout = Layout.screen4x3();
        break;
      case '16x10':
        presentation.layout = Layout.screen16x10();
        break;
      case 'wide':
        presentation.layout = Layout.screenWide();
        break;
      case '16x9':
      default:
        presentation.layout = Layout.screen16x9();
        break;
    }
  }
  
  /// Show slide numbers
  void showSlideNumbers({
    required Powerpoint presentation,
    bool show = true,
  }) {
    presentation.showSlideNumbers = show;
  }
}