class AppConstants {
  // App Information
  static const String appName = 'AI PPT Desktop';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'AI-powered PPT creation desktop application';
  
  // File Extensions
  static const String pptxExtension = '.pptx';
  static const String pdfExtension = '.pdf';
  static const String imageExtensions = '.png,.jpg,.jpeg,.gif,.bmp';
  static const String audioExtensions = '.mp3,.wav,.aac,.m4a';
  static const String videoExtensions = '.mp4,.avi,.mov,.mkv';
  
  // AI Model Names
  static const String textGenerationModel = 'text_generation.tflite';
  static const String imageClassificationModel = 'image_classification.tflite';
  static const String speechRecognitionModel = 'speech_recognition.tflite';
  static const String layoutGenerationModel = 'layout_generation.tflite';
  
  // Default Values
  static const int maxSlides = 100;
  static const int maxImages = 50;
  static const int maxAudioLength = 3600; // 1 hour in seconds
  static const int maxVideoLength = 7200; // 2 hours in seconds
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 8.0;
  static const double defaultElevation = 2.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}