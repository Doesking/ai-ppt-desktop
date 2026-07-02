import 'package:hive/hive.dart';

class AppConfig {
  static const String _configBoxName = 'app_config';
  static late Box _configBox;
  
  static Future<void> initialize() async {
    _configBox = await Hive.openBox(_configBoxName);
  }
  
  // AI Model Configuration
  static String get aiModelPath => _configBox.get('ai_model_path', defaultValue: 'assets/models/');
  static set aiModelPath(String value) => _configBox.put('ai_model_path', value);
  
  // Template Configuration
  static String get templatePath => _configBox.get('template_path', defaultValue: 'assets/templates/');
  static set templatePath(String value) => _configBox.put('template_path', value);
  
  // User Preferences
  static String get userName => _configBox.get('user_name', defaultValue: '');
  static set userName(String value) => _configBox.put('user_name', value);
  
  static String get companyName => _configBox.get('company_name', defaultValue: '');
  static set companyName(String value) => _configBox.put('company_name', value);
  
  // Theme Configuration
  static bool get isDarkMode => _configBox.get('is_dark_mode', defaultValue: false);
  static set isDarkMode(bool value) => _configBox.put('is_dark_mode', value);
  
  // Language Configuration
  static String get language => _configBox.get('language', defaultValue: 'en');
  static set language(String value) => _configBox.put('language', value);
}