import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/constants/app_constants.dart';

class HelpPage extends ConsumerStatefulWidget {
  const HelpPage({super.key});

  @override
  ConsumerState<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends ConsumerState<HelpPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Getting Started';
  
  final List<String> _categories = [
    'Getting Started',
    'Creating Presentations',
    'AI Features',
    'Voice & Video',
    'Collaboration',
    'Brand Management',
    'Troubleshooting',
    'FAQ',
  ];
  
  final Map<String, List<HelpItem>> _helpItems = {
    'Getting Started': [
      HelpItem(
        title: 'Welcome to AI PPT Desktop',
        content: 'AI PPT Desktop is a powerful presentation creation tool that uses artificial intelligence to help you create professional presentations quickly and easily.',
      ),
      HelpItem(
        title: 'System Requirements',
        content: '• macOS 10.15 or later\n• Windows 10 or later\n• Linux (Ubuntu 20.04+)\n• 4GB RAM minimum\n• 500MB free disk space',
      ),
      HelpItem(
        title: 'Installation Guide',
        content: '1. Download the installer for your platform\n2. Run the installer\n3. Follow the on-screen instructions\n4. Launch the application',
      ),
    ],
    'Creating Presentations': [
      HelpItem(
        title: 'Creating a New Presentation',
        content: '1. Click "Create New Presentation" on the home screen\n2. Enter your presentation topic\n3. Select a style (Business, Academic, Creative, Minimalist)\n4. Choose the number of slides\n5. Click "Generate with AI"',
      ),
      HelpItem(
        title: 'Editing Slides',
        content: '• Click on any slide to edit it\n• Use the toolbar to format text\n• Drag and drop to rearrange elements\n• Right-click for more options',
      ),
      HelpItem(
        title: 'Adding Media',
        content: '• Click "Insert" in the menu bar\n• Select "Image", "Audio", or "Video"\n• Choose your file\n• Position and resize as needed',
      ),
    ],
    'AI Features': [
      HelpItem(
        title: 'AI Content Generation',
        content: 'The AI can generate complete presentations based on your topic. It analyzes your input and creates structured content with key points, supporting details, and conclusions.',
      ),
      HelpItem(
        title: 'Smart Templates',
        content: 'AI recommends templates based on your content. The system analyzes your presentation style and suggests designs that match your brand and content type.',
      ),
      HelpItem(
        title: 'Auto Layout',
        content: 'The AI automatically adjusts layout, colors, and fonts to create visually appealing presentations. It ensures consistency and professional appearance.',
      ),
    ],
    'Voice & Video': [
      HelpItem(
        title: 'Voice to PPT',
        content: '1. Click the "Voice" tab\n2. Click "Start Recording"\n3. Speak your presentation content\n4. Click "Stop Recording"\n5. The AI will transcribe and generate slides',
      ),
      HelpItem(
        title: 'Video to PPT',
        content: '1. Click the "Video" tab\n2. Click "Import Video"\n3. Select your video file\n4. The AI will extract audio and key frames\n5. Generate presentation from video content',
      ),
      HelpItem(
        title: 'Audio Import',
        content: 'You can import existing audio files (.mp3, .wav, .aac) to generate presentations. The AI will transcribe the audio and create slides based on the content.',
      ),
    ],
    'Collaboration': [
      HelpItem(
        title: 'Starting a Collaboration Session',
        content: '1. Open a presentation\n2. Click the "Collaborate" tab\n3. Click "Start Session"\n4. Share the session link with your team\n5. Team members can join and edit in real-time',
      ),
      HelpItem(
        title: 'Real-time Editing',
        content: 'All participants can edit the presentation simultaneously. Changes are synchronized in real-time. You can see other users\' cursors and edits.',
      ),
      HelpItem(
        title: 'Comments and Feedback',
        content: 'Use the chat panel to communicate with your team. You can add comments to specific slides and receive feedback in real-time.',
      ),
    ],
    'Brand Management': [
      HelpItem(
        title: 'Setting Up Your Brand',
        content: '1. Go to Brand Management\n2. Click "Create New Brand"\n3. Enter brand name and description\n4. Set colors, fonts, and logo\n5. Save your brand profile',
      ),
      HelpItem(
        title: 'Applying Brand to Presentations',
        content: '1. Open a presentation\n2. Go to Brand Management\n3. Select your brand\n4. Click "Apply to Presentation"\n5. All slides will be updated with brand colors and fonts',
      ),
      HelpItem(
        title: 'Brand Guidelines',
        content: 'Generate brand guidelines documents that include color palettes, typography specifications, logo usage rules, and layout guidelines.',
      ),
    ],
    'Troubleshooting': [
      HelpItem(
        title: 'Application Won\'t Start',
        content: '• Check system requirements\n• Restart your computer\n• Reinstall the application\n• Check for conflicting software',
      ),
      HelpItem(
        title: 'AI Features Not Working',
        content: '• Check internet connection (for cloud AI)\n• Verify local AI models are installed\n• Restart the application\n• Check error logs in Settings',
      ),
      HelpItem(
        title: 'Performance Issues',
        content: '• Close other applications\n• Reduce presentation complexity\n• Update graphics drivers\n• Increase system RAM if possible',
      ),
    ],
    'FAQ': [
      HelpItem(
        title: 'Is my data secure?',
        content: 'Yes! AI PPT Desktop processes all AI tasks locally on your device. Your presentations and data never leave your computer unless you choose to share them.',
      ),
      HelpItem(
        title: 'Can I use it offline?',
        content: 'Yes! All core features work offline. Some advanced AI features may require internet for model updates, but basic functionality is fully offline.',
      ),
      HelpItem(
        title: 'What file formats are supported?',
        content: '• Import: .pptx, .pdf, .mp3, .wav, .mp4, .avi\n• Export: .pptx, .pdf, .png, .jpg\n• Audio: .mp3, .wav, .aac, .m4a\n• Video: .mp4, .avi, .mov, .mkv',
      ),
    ],
  };

  @override
  void dispose() {
    _searchController.dispose();
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
            child: _buildMainContent(),
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
            'Help & Documentation',
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
  
  Widget _buildMainContent() {
    return Row(
      children: [
        // Left Panel - Categories
        Container(
          width: 250,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              right: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: _buildCategoryList(),
        ),
        
        // Center - Help Content
        Expanded(
          child: _buildHelpContent(),
        ),
      ],
    );
  }
  
  Widget _buildCategoryList() {
    return Column(
      children: [
        // Search Box
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search help...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) {
              // TODO: Implement search functionality
            },
          ),
        ),
        
        // Category List
        Expanded(
          child: ListView.builder(
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategory == category;
              
              return ListTile(
                leading: Icon(
                  _getCategoryIcon(category),
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                title: Text(
                  category,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
                selected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
              );
            },
          ),
        ),
        
        // Contact Support
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              const Text(
                'Need more help?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _contactSupport,
                  icon: const Icon(Icons.support_agent),
                  label: const Text('Contact Support'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildHelpContent() {
    final items = _helpItems[_selectedCategory] ?? [];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Header
          Text(
            _selectedCategory,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getCategoryDescription(_selectedCategory),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          
          // Help Items
          ...items.map((item) => _buildHelpItemCard(item)),
        ],
      ),
    );
  }
  
  Widget _buildHelpItemCard(HelpItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              item.content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Getting Started':
        return Icons.play_circle_outline;
      case 'Creating Presentations':
        return Icons.slideshow;
      case 'AI Features':
        return Icons.auto_awesome;
      case 'Voice & Video':
        return Icons.multitrack_audio;
      case 'Collaboration':
        return Icons.people;
      case 'Brand Management':
        return Icons.branding_watermark;
      case 'Troubleshooting':
        return Icons.build;
      case 'FAQ':
        return Icons.help_outline;
      default:
        return Icons.help;
    }
  }
  
  String _getCategoryDescription(String category) {
    switch (category) {
      case 'Getting Started':
        return 'Learn the basics of AI PPT Desktop';
      case 'Creating Presentations':
        return 'How to create and edit presentations';
      case 'AI Features':
        return 'Using AI to enhance your presentations';
      case 'Voice & Video':
        return 'Creating presentations from audio and video';
      case 'Collaboration':
        return 'Working together with your team';
      case 'Brand Management':
        return 'Managing your brand identity';
      case 'Troubleshooting':
        return 'Solving common issues';
      case 'FAQ':
        return 'Frequently asked questions';
      default:
        return '';
    }
  }
  
  void _contactSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Need help? Contact our support team:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              subtitle: const Text('support@aippt.com'),
              onTap: () {
                // TODO: Open email client
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Live Chat'),
              subtitle: const Text('Available 24/7'),
              onTap: () {
                // TODO: Open live chat
              },
            ),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text('Report a Bug'),
              subtitle: const Text('Help us improve'),
              onTap: () {
                // TODO: Open bug report form
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Help item class
class HelpItem {
  final String title;
  final String content;
  
  HelpItem({
    required this.title,
    required this.content,
  });
}