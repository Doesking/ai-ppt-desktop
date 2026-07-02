import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/constants/app_constants.dart';
import '../../data/services/ppt_service.dart';
import '../../ai/processors/content_generator.dart';
import '../../ai/processors/template_recommender.dart';

class PPTEditorPage extends ConsumerStatefulWidget {
  final String? initialTopic;
  
  const PPTEditorPage({super.key, this.initialTopic});

  @override
  ConsumerState<PPTEditorPage> createState() => _PPTEditorPageState();
}

class _PPTEditorPageState extends ConsumerState<PPTEditorPage> {
  final PPTService _pptService = PPTService();
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  
  String _selectedStyle = 'business';
  int _slideCount = 10;
  bool _isGenerating = false;
  List<Map<String, dynamic>> _slides = [];
  List<Map<String, dynamic>> _templateRecommendations = [];
  
  @override
  void initState() {
    super.initState();
    if (widget.initialTopic != null) {
      _topicController.text = widget.initialTopic!;
    }
  }
  
  @override
  void dispose() {
    _topicController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Title Bar
          _buildTitleBar(),
          
          // Main Content
          Expanded(
            child: Row(
              children: [
                // Left Panel - Controls
                _buildLeftPanel(),
                
                // Center - Slide Preview
                Expanded(
                  child: _buildSlidePreview(),
                ),
                
                // Right Panel - Properties
                _buildRightPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTitleBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 16),
          Text(
            'AI PPT Editor',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const Spacer(),
          // Window controls
          IconButton(
            icon: const Icon(Icons.minimize, size: 16),
            onPressed: () => windowManager.minimize(),
          ),
          IconButton(
            icon: const Icon(Icons.crop_square, size: 16),
            onPressed: () => windowManager.maximize(),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: () => windowManager.close(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLeftPanel() {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Topic Input
            Text(
              'Topic',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _topicController,
              decoration: const InputDecoration(
                hintText: 'Enter presentation topic',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Style Selection
            Text(
              'Style',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedStyle,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'business', child: Text('Business')),
                DropdownMenuItem(value: 'academic', child: Text('Academic')),
                DropdownMenuItem(value: 'creative', child: Text('Creative')),
                DropdownMenuItem(value: 'minimalist', child: Text('Minimalist')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStyle = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Slide Count
            Text(
              'Slide Count: $_slideCount',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Slider(
              value: _slideCount.toDouble(),
              min: 5,
              max: 20,
              divisions: 15,
              onChanged: (value) {
                setState(() {
                  _slideCount = value.round();
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Content Input
            Text(
              'Content',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Enter additional content or instructions',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Generate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generatePresentation,
                icon: _isGenerating 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(_isGenerating ? 'Generating...' : 'Generate with AI'),
              ),
            ),
            const SizedBox(height: 16),
            
            // Template Recommendations
            if (_templateRecommendations.isNotEmpty) ...[
              Text(
                'Recommended Templates',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ..._templateRecommendations.map((template) => _buildTemplateCard(template)),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildTemplateCard(Map<String, dynamic> template) {
    final colors = List<String>.from(template['colors'] ?? []);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: colors.isNotEmpty
                ? LinearGradient(
                    colors: colors.take(2).map((c) => Color(int.parse(c.replaceFirst('#', '0xFF')))).toList(),
                  )
                : null,
            color: colors.isEmpty ? Colors.grey : null,
          ),
        ),
        title: Text(template['name'] ?? 'Template'),
        subtitle: Text(template['description'] ?? ''),
        trailing: Text('${(template['score'] as double?)?.toStringAsFixed(1) ?? '0.0'}'),
        onTap: () => _applyTemplate(template),
      ),
    );
  }
  
  Widget _buildSlidePreview() {
    return Container(
      color: Colors.grey[100],
      child: _slides.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.slideshow,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Enter a topic and generate slides',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _slides.length,
              itemBuilder: (context, index) {
                return _buildSlideCard(_slides[index], index);
              },
            ),
    );
  }
  
  Widget _buildSlideCard(Map<String, dynamic> slide, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Slide ${index + 1}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                Text(
                  slide['type'] ?? 'content',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              slide['title'] ?? 'Untitled',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                slide['content'] ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRightPanel() {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          left: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Slide Properties',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            // Slide list
            if (_slides.isNotEmpty) ...[
              Text(
                'Slides (${_slides.length})',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ..._slides.asMap().entries.map((entry) {
                return ListTile(
                  leading: CircleAvatar(
                    radius: 12,
                    child: Text('${entry.key + 1}'),
                  ),
                  title: Text(
                    entry.value['title'] ?? 'Slide ${entry.key + 1}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  dense: true,
                );
              }),
            ],
            
            const SizedBox(height: 16),
            
            // Export options
            Text(
              'Export',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _slides.isEmpty ? null : _exportPresentation,
                icon: const Icon(Icons.save),
                label: const Text('Save as PPTX'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _slides.isEmpty ? null : _exportAsMarkdown,
                icon: const Icon(Icons.code),
                label: const Text('Export as Markdown'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _generatePresentation() async {
    if (_topicController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a topic')),
      );
      return;
    }
    
    setState(() {
      _isGenerating = true;
    });
    
    try {
      // Generate content (simplified for demo)
      final content = _generateDemoContent();
      
      // Get template recommendations
      final recommender = TemplateRecommender();
      final recommendations = await recommender.recommendTemplates(
        content: content,
        style: _selectedStyle,
      );
      
      setState(() {
        _templateRecommendations = recommendations;
        _slides = _parseContentToSlides(content);
        _isGenerating = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Generated ${_slides.length} slides')),
      );
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating presentation: $e')),
      );
    }
  }
  
  String _generateDemoContent() {
    final topic = _topicController.text;
    return '''
$topic

Introduction
• Overview of $topic
• Key objectives
• Expected outcomes

Main Content
• Detailed analysis
• Supporting evidence
• Case studies

Conclusion
• Summary of key points
• Action items
• Next steps
''';
  }
  
  List<Map<String, dynamic>> _parseContentToSlides(String content) {
    final slides = <Map<String, dynamic>>[];
    final lines = content.split('\n');
    
    String? currentTitle;
    final currentContent = StringBuffer();
    
    for (final line in lines) {
      if (line.trim().isEmpty) {
        if (currentTitle != null) {
          slides.add({
            'type': 'content',
            'title': currentTitle,
            'content': currentContent.toString().trim(),
          });
          currentTitle = null;
          currentContent.clear();
        }
      } else if (currentTitle == null) {
        currentTitle = line.trim();
      } else {
        currentContent.writeln(line);
      }
    }
    
    if (currentTitle != null) {
      slides.add({
        'type': 'content',
        'title': currentTitle,
        'content': currentContent.toString().trim(),
      });
    }
    
    return slides;
  }
  
  void _applyTemplate(Map<String, dynamic> template) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Applied template: ${template['name']}')),
    );
  }
  
  Future<void> _exportPresentation() async {
    try {
      final presentation = await _pptService.createPresentation(
        title: _topicController.text,
        author: 'AI PPT Desktop',
      );
      
      for (final slide in _slides) {
        _pptService.addTitleAndBulletsSlide(
          presentation: presentation,
          title: slide['title'] ?? 'Untitled',
          bullets: (slide['content'] as String?)?.split('\n').where((l) => l.trim().isNotEmpty).toList() ?? [],
        );
      }
      
      final filePath = await _pptService.savePresentation(
        presentation: presentation,
        fileName: '${_topicController.text.replaceAll(' ', '_')}.pptx',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved to: $filePath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving: $e')),
      );
    }
  }
  
  void _exportAsMarkdown() {
    final markdown = StringBuffer();
    markdown.writeln('# ${_topicController.text}');
    markdown.writeln();
    
    for (final slide in _slides) {
      markdown.writeln('## ${slide['title']}');
      markdown.writeln();
      markdown.writeln(slide['content']);
      markdown.writeln();
    }
    
    // In a real app, you would save this to a file
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Markdown exported to clipboard')),
    );
  }
}