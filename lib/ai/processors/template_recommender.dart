class TemplateRecommender {
  /// Template data structure
  static final List<Map<String, dynamic>> _templates = [
    {
      'id': 'business_professional',
      'name': 'Business Professional',
      'category': 'business',
      'description': 'Clean and professional template for business presentations',
      'colors': ['#2C3E50', '#3498DB', '#1ABC9C', '#E74C3C'],
      'style': 'modern',
      'useCase': ['meetings', 'reports', 'proposals'],
    },
    {
      'id': 'creative_modern',
      'name': 'Creative Modern',
      'category': 'creative',
      'description': 'Bold and creative template for design presentations',
      'colors': ['#9B59B6', '#E91E63', '#FF9800', '#4CAF50'],
      'style': 'artistic',
      'useCase': ['portfolios', 'design', 'marketing'],
    },
    {
      'id': 'academic_formal',
      'name': 'Academic Formal',
      'category': 'academic',
      'description': 'Formal template for academic and research presentations',
      'colors': ['#34495E', '#2980B9', '#27AE60', '#F39C12'],
      'style': 'traditional',
      'useCase': ['lectures', 'research', 'conferences'],
    },
    {
      'id': 'minimalist_clean',
      'name': 'Minimalist Clean',
      'category': 'minimalist',
      'description': 'Simple and clean template with minimal design elements',
      'colors': ['#FFFFFF', '#F8F9FA', '#DEE2E6', '#6C757D'],
      'style': 'minimal',
      'useCase': ['presentations', 'meetings', 'reports'],
    },
    {
      'id': 'tech_startup',
      'name': 'Tech Startup',
      'category': 'technology',
      'description': 'Modern template for technology and startup presentations',
      'colors': ['#0D1B2A', '#1B263B', '#415A77', '#778DA9'],
      'style': 'tech',
      'useCase': ['pitches', 'demos', 'product launches'],
    },
  ];
  
  /// Recommend templates based on content analysis
  Future<List<Map<String, dynamic>>> recommendTemplates({
    required String content,
    required String style,
    int maxRecommendations = 3,
  }) async {
    // Analyze content to determine best templates
    final contentLower = content.toLowerCase();
    final scores = <String, double>{};
    
    // Score each template based on content and style
    for (final template in _templates) {
      double score = 0.0;
      
      // Style matching
      if (template['style'] == style) {
        score += 3.0;
      }
      
      // Category matching based on content keywords
      final category = template['category'] as String;
      switch (category) {
        case 'business':
          if (contentLower.contains('business') ||
              contentLower.contains('corporate') ||
              contentLower.contains('professional') ||
              contentLower.contains('meeting') ||
              contentLower.contains('report')) {
            score += 2.0;
          }
          break;
        case 'creative':
          if (contentLower.contains('creative') ||
              contentLower.contains('design') ||
              contentLower.contains('art') ||
              contentLower.contains('portfolio') ||
              contentLower.contains('marketing')) {
            score += 2.0;
          }
          break;
        case 'academic':
          if (contentLower.contains('research') ||
              contentLower.contains('academic') ||
              contentLower.contains('study') ||
              contentLower.contains('analysis') ||
              contentLower.contains('data')) {
            score += 2.0;
          }
          break;
        case 'minimalist':
          if (contentLower.contains('simple') ||
              contentLower.contains('clean') ||
              contentLower.contains('minimal') ||
              contentLower.contains('elegant')) {
            score += 2.0;
          }
          break;
        case 'technology':
          if (contentLower.contains('tech') ||
              contentLower.contains('software') ||
              contentLower.contains('digital') ||
              contentLower.contains('innovation') ||
              contentLower.contains('startup')) {
            score += 2.0;
          }
          break;
      }
      
      // Use case matching
      final useCases = template['useCase'] as List<dynamic>;
      for (final useCase in useCases) {
        if (contentLower.contains(useCase.toString().toLowerCase())) {
          score += 1.0;
        }
      }
      
      scores[template['id'] as String] = score;
    }
    
    // Sort by score and return top recommendations
    final sortedEntries = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final recommendations = <Map<String, dynamic>>[];
    for (int i = 0; i < maxRecommendations && i < sortedEntries.length; i++) {
      final templateId = sortedEntries[i].key;
      final template = _templates.firstWhere((t) => t['id'] == templateId);
      recommendations.add({
        ...template,
        'score': sortedEntries[i].value,
        'matchReason': _getMatchReason(template, content, style),
      });
    }
    
    return recommendations;
  }
  
  /// Get template by ID
  Map<String, dynamic>? getTemplateById(String id) {
    try {
      return _templates.firstWhere((t) => t['id'] == id);
    } catch (e) {
      return null;
    }
  }
  
  /// Get all templates
  List<Map<String, dynamic>> getAllTemplates() {
    return List.from(_templates);
  }
  
  /// Get templates by category
  List<Map<String, dynamic>> getTemplatesByCategory(String category) {
    return _templates.where((t) => t['category'] == category).toList();
  }
  
  /// Get match reason for recommendation
  String _getMatchReason(
    Map<String, dynamic> template,
    String content,
    String style,
  ) {
    final reasons = <String>[];
    
    if (template['style'] == style) {
      reasons.add('matches your preferred style');
    }
    
    final category = template['category'] as String;
    if (content.toLowerCase().contains(category)) {
      reasons.add('relevant to your content topic');
    }
    
    if (reasons.isEmpty) {
      reasons.add('popular choice for similar presentations');
    }
    
    return reasons.join(', ');
  }
  
  /// Get color scheme for template
  List<String> getColorScheme(String templateId) {
    final template = getTemplateById(templateId);
    if (template != null) {
      return List<String>.from(template['colors'] ?? []);
    }
    return ['#000000', '#FFFFFF', '#CCCCCC'];
  }
  
  /// Get template preview data
  Map<String, dynamic> getTemplatePreview(String templateId) {
    final template = getTemplateById(templateId);
    if (template == null) {
      return {};
    }
    
    return {
      'id': template['id'],
      'name': template['name'],
      'description': template['description'],
      'colors': template['colors'],
      'previewElements': _getPreviewElements(template['style'] as String),
    };
  }
  
  List<Map<String, dynamic>> _getPreviewElements(String style) {
    switch (style) {
      case 'modern':
        return [
          {'type': 'title', 'position': 'top', 'size': 'large'},
          {'type': 'content', 'position': 'center', 'size': 'medium'},
          {'type': 'footer', 'position': 'bottom', 'size': 'small'},
        ];
      case 'artistic':
        return [
          {'type': 'image', 'position': 'background', 'size': 'full'},
          {'type': 'title', 'position': 'center', 'size': 'large'},
          {'type': 'accent', 'position': 'side', 'size': 'medium'},
        ];
      case 'traditional':
        return [
          {'type': 'header', 'position': 'top', 'size': 'medium'},
          {'type': 'content', 'position': 'center', 'size': 'large'},
          {'type': 'footer', 'position': 'bottom', 'size': 'small'},
        ];
      case 'minimal':
        return [
          {'type': 'title', 'position': 'top-left', 'size': 'medium'},
          {'type': 'content', 'position': 'center', 'size': 'large'},
          {'type': 'line', 'position': 'divider', 'size': 'small'},
        ];
      case 'tech':
        return [
          {'type': 'gradient', 'position': 'background', 'size': 'full'},
          {'type': 'title', 'position': 'center', 'size': 'large'},
          {'type': 'icons', 'position': 'side', 'size': 'medium'},
        ];
      default:
        return [
          {'type': 'title', 'position': 'top', 'size': 'large'},
          {'type': 'content', 'position': 'center', 'size': 'medium'},
        ];
    }
  }
}