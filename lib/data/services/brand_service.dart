import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

class BrandService {
  final Map<String, BrandProfile> _brandProfiles = {};
  bool _isInitialized = false;
  
  /// Initialize brand service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Load default brand profiles
    await _loadDefaultBrands();
    _isInitialized = true;
  }
  
  /// Create a new brand profile
  Future<BrandProfile> createBrandProfile({
    required String name,
    required BrandColors colors,
    required BrandTypography typography,
    required BrandLogo logo,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_isInitialized) {
      throw Exception('Brand service not initialized');
    }
    
    final brandId = 'brand_${DateTime.now().millisecondsSinceEpoch}';
    final brand = BrandProfile(
      id: brandId,
      name: name,
      description: description ?? '',
      colors: colors,
      typography: typography,
      logo: logo,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      metadata: metadata ?? {},
    );
    
    _brandProfiles[brandId] = brand;
    
    return brand;
  }
  
  /// Update an existing brand profile
  Future<BrandProfile> updateBrandProfile({
    required String brandId,
    String? name,
    String? description,
    BrandColors? colors,
    BrandTypography? typography,
    BrandLogo? logo,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_isInitialized) {
      throw Exception('Brand service not initialized');
    }
    
    final existingBrand = _brandProfiles[brandId];
    if (existingBrand == null) {
      throw Exception('Brand profile not found: $brandId');
    }
    
    final updatedBrand = BrandProfile(
      id: brandId,
      name: name ?? existingBrand.name,
      description: description ?? existingBrand.description,
      colors: colors ?? existingBrand.colors,
      typography: typography ?? existingBrand.typography,
      logo: logo ?? existingBrand.logo,
      createdAt: existingBrand.createdAt,
      updatedAt: DateTime.now(),
      metadata: metadata ?? existingBrand.metadata,
    );
    
    _brandProfiles[brandId] = updatedBrand;
    
    return updatedBrand;
  }
  
  /// Delete a brand profile
  Future<void> deleteBrandProfile(String brandId) async {
    if (!_isInitialized) {
      throw Exception('Brand service not initialized');
    }
    
    if (!_brandProfiles.containsKey(brandId)) {
      throw Exception('Brand profile not found: $brandId');
    }
    
    _brandProfiles.remove(brandId);
  }
  
  /// Get brand profile by ID
  BrandProfile? getBrandProfile(String brandId) {
    return _brandProfiles[brandId];
  }
  
  /// Get all brand profiles
  List<BrandProfile> getAllBrandProfiles() {
    return _brandProfiles.values.toList();
  }
  
  /// Apply brand to presentation
  Future<Map<String, dynamic>> applyBrandToPresentation({
    required String brandId,
    required Map<String, dynamic> presentation,
  }) async {
    if (!_isInitialized) {
      throw Exception('Brand service not initialized');
    }
    
    final brand = _brandProfiles[brandId];
    if (brand == null) {
      throw Exception('Brand profile not found: $brandId');
    }
    
    // Apply brand colors, typography, and logo to presentation
    final brandedPresentation = Map<String, dynamic>.from(presentation);
    
    // Apply colors
    brandedPresentation['primaryColor'] = brand.colors.primary;
    brandedPresentation['secondaryColor'] = brand.colors.secondary;
    brandedPresentation['accentColor'] = brand.colors.accent;
    brandedPresentation['backgroundColor'] = brand.colors.background;
    brandedPresentation['textColor'] = brand.colors.text;
    
    // Apply typography
    brandedPresentation['titleFont'] = brand.typography.titleFont;
    brandedPresentation['bodyFont'] = brand.typography.bodyFont;
    brandedPresentation['titleFontSize'] = brand.typography.titleFontSize;
    brandedPresentation['bodyFontSize'] = brand.typography.bodyFontSize;
    
    // Apply logo
    brandedPresentation['logoPath'] = brand.logo.path;
    brandedPresentation['logoPosition'] = brand.logo.position;
    
    return brandedPresentation;
  }
  
  /// Generate brand guidelines document
  Future<Map<String, dynamic>> generateBrandGuidelines({
    required String brandId,
  }) async {
    if (!_isInitialized) {
      throw Exception('Brand service not initialized');
    }
    
    final brand = _brandProfiles[brandId];
    if (brand == null) {
      throw Exception('Brand profile not found: $brandId');
    }
    
    return {
      'brandId': brandId,
      'brandName': brand.name,
      'guidelines': {
        'colors': {
          'primary': brand.colors.primary,
          'secondary': brand.colors.secondary,
          'accent': brand.colors.accent,
          'background': brand.colors.background,
          'text': brand.colors.text,
          'usage': 'Use primary color for main headings and important elements',
        },
        'typography': {
          'titleFont': brand.typography.titleFont,
          'bodyFont': brand.typography.bodyFont,
          'titleFontSize': brand.typography.titleFontSize,
          'bodyFontSize': brand.typography.bodyFontSize,
          'usage': 'Use title font for headings, body font for content',
        },
        'logo': {
          'path': brand.logo.path,
          'position': brand.logo.position,
          'minimumSize': brand.logo.minimumSize,
          'clearSpace': brand.logo.clearSpace,
          'usage': 'Maintain clear space around logo',
        },
        'layout': {
          'margins': 'Use consistent margins across all slides',
          'alignment': 'Align elements to a grid system',
          'spacing': 'Use consistent spacing between elements',
        },
      },
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }
  
  /// Import brand from file
  Future<BrandProfile> importBrandFromFile(String filePath) async {
    if (!_isInitialized) {
      throw Exception('Brand service not initialized');
    }
    
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Brand file not found: $filePath');
      }
      
      final content = await file.readAsString();
      final brandData = jsonDecode(content) as Map<String, dynamic>;
      
      return await createBrandProfile(
        name: brandData['name'] ?? 'Imported Brand',
        colors: BrandColors.fromMap(brandData['colors'] ?? {}),
        typography: BrandTypography.fromMap(brandData['typography'] ?? {}),
        logo: BrandLogo.fromMap(brandData['logo'] ?? {}),
        description: brandData['description'],
        metadata: brandData['metadata'],
      );
    } catch (e) {
      throw Exception('Failed to import brand: $e');
    }
  }
  
  /// Export brand to file
  Future<void> exportBrandToFile({
    required String brandId,
    required String outputPath,
  }) async {
    if (!_isInitialized) {
      throw Exception('Brand service not initialized');
    }
    
    final brand = _brandProfiles[brandId];
    if (brand == null) {
      throw Exception('Brand profile not found: $brandId');
    }
    
    try {
      final brandData = {
        'id': brand.id,
        'name': brand.name,
        'description': brand.description,
        'colors': brand.colors.toMap(),
        'typography': brand.typography.toMap(),
        'logo': brand.logo.toMap(),
        'metadata': brand.metadata,
        'exportedAt': DateTime.now().toIso8601String(),
      };
      
      final file = File(outputPath);
      await file.writeAsString(jsonEncode(brandData));
    } catch (e) {
      throw Exception('Failed to export brand: $e');
    }
  }
  
  /// Check if service is initialized
  bool get isInitialized => _isInitialized;
  
  /// Dispose resources
  void dispose() {
    _brandProfiles.clear();
    _isInitialized = false;
  }
  
  Future<void> _loadDefaultBrands() async {
    // Load default brand profiles
    final defaultBrands = [
      BrandProfile(
        id: 'default_corporate',
        name: 'Corporate Blue',
        description: 'Professional corporate brand with blue theme',
        colors: BrandColors(
          primary: '#1E3A8A',
          secondary: '#3B82F6',
          accent: '#F59E0B',
          background: '#FFFFFF',
          text: '#1F2937',
        ),
        typography: BrandTypography(
          titleFont: 'Arial',
          bodyFont: 'Arial',
          titleFontSize: 24,
          bodyFontSize: 16,
        ),
        logo: BrandLogo(
          path: 'assets/logos/corporate_logo.png',
          position: LogoPosition.topRight,
          minimumSize: 50,
          clearSpace: 20,
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      BrandProfile(
        id: 'default_creative',
        name: 'Creative Purple',
        description: 'Creative and modern brand with purple theme',
        colors: BrandColors(
          primary: '#7C3AED',
          secondary: '#A78BFA',
          accent: '#EC4899',
          background: '#F9FAFB',
          text: '#111827',
        ),
        typography: BrandTypography(
          titleFont: 'Helvetica',
          bodyFont: 'Helvetica',
          titleFontSize: 28,
          bodyFontSize: 18,
        ),
        logo: BrandLogo(
          path: 'assets/logos/creative_logo.png',
          position: LogoPosition.topLeft,
          minimumSize: 60,
          clearSpace: 25,
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
    
    for (final brand in defaultBrands) {
      _brandProfiles[brand.id] = brand;
    }
  }
}

/// Brand profile class
class BrandProfile {
  final String id;
  final String name;
  final String description;
  final BrandColors colors;
  final BrandTypography typography;
  final BrandLogo logo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;
  
  BrandProfile({
    required this.id,
    required this.name,
    required this.description,
    required this.colors,
    required this.typography,
    required this.logo,
    required this.createdAt,
    required this.updatedAt,
    required this.metadata,
  });
}

/// Brand colors class
class BrandColors {
  final String primary;
  final String secondary;
  final String accent;
  final String background;
  final String text;
  
  const BrandColors({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.text,
  });
  
  factory BrandColors.fromMap(Map<String, dynamic> map) {
    return BrandColors(
      primary: map['primary'] ?? '#000000',
      secondary: map['secondary'] ?? '#666666',
      accent: map['accent'] ?? '#0066CC',
      background: map['background'] ?? '#FFFFFF',
      text: map['text'] ?? '#000000',
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'primary': primary,
      'secondary': secondary,
      'accent': accent,
      'background': background,
      'text': text,
    };
  }
}

/// Brand typography class
class BrandTypography {
  final String titleFont;
  final String bodyFont;
  final int titleFontSize;
  final int bodyFontSize;
  
  const BrandTypography({
    required this.titleFont,
    required this.bodyFont,
    required this.titleFontSize,
    required this.bodyFontSize,
  });
  
  factory BrandTypography.fromMap(Map<String, dynamic> map) {
    return BrandTypography(
      titleFont: map['titleFont'] ?? 'Arial',
      bodyFont: map['bodyFont'] ?? 'Arial',
      titleFontSize: map['titleFontSize'] ?? 24,
      bodyFontSize: map['bodyFontSize'] ?? 16,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'titleFont': titleFont,
      'bodyFont': bodyFont,
      'titleFontSize': titleFontSize,
      'bodyFontSize': bodyFontSize,
    };
  }
}

/// Brand logo class
class BrandLogo {
  final String path;
  final LogoPosition position;
  final int minimumSize;
  final int clearSpace;
  
  const BrandLogo({
    required this.path,
    required this.position,
    required this.minimumSize,
    required this.clearSpace,
  });
  
  factory BrandLogo.fromMap(Map<String, dynamic> map) {
    return BrandLogo(
      path: map['path'] ?? '',
      position: LogoPosition.values.firstWhere(
        (e) => e.toString() == 'LogoPosition.${map['position']}',
        orElse: () => LogoPosition.topRight,
      ),
      minimumSize: map['minimumSize'] ?? 50,
      clearSpace: map['clearSpace'] ?? 20,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'path': path,
      'position': position.toString().split('.').last,
      'minimumSize': minimumSize,
      'clearSpace': clearSpace,
    };
  }
}

/// Logo position enum
enum LogoPosition {
  topLeft,
  topCenter,
  topRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}