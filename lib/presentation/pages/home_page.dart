import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/constants/app_constants.dart';
import 'ppt_editor_page.dart';
import 'settings_page.dart';
import 'brand_management_page.dart';
import 'collaboration_page.dart';
import 'help_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Custom Title Bar for Desktop
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
          const SizedBox(width: 16),
          Text(
            AppConstants.appName,
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.slideshow,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Welcome to AI PPT Desktop',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'Create professional presentations with AI assistance',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          // Main Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PPTEditorPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Create New Presentation'),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Open existing presentation
                },
                icon: const Icon(Icons.folder_open),
                label: const Text('Open Existing'),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Feature Cards
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFeatureCard(
                icon: Icons.mic,
                title: 'Voice to PPT',
                description: 'Create presentations from audio recordings',
                onTap: () {
                  // TODO: Navigate to voice to PPT
                },
              ),
              const SizedBox(width: 16),
              _buildFeatureCard(
                icon: Icons.videocam,
                title: 'Video to PPT',
                description: 'Extract content from video files',
                onTap: () {
                  // TODO: Navigate to video to PPT
                },
              ),
              const SizedBox(width: 16),
              _buildFeatureCard(
                icon: Icons.people,
                title: 'Collaborate',
                description: 'Work together in real-time',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CollaborationPage(
                        presentationId: 'demo',
                        presentationTitle: 'Demo Presentation',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Settings, Brand Management, and Help
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.settings),
                label: const Text('Settings'),
              ),
              const SizedBox(width: 24),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const BrandManagementPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.branding_watermark),
                label: const Text('Brand Management'),
              ),
              const SizedBox(width: 24),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const HelpPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.help_outline),
                label: const Text('Help'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                icon,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose && mounted) {
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('Are you sure you want to close?'),
            content: const Text('Unsaved changes will be lost.'),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                  windowManager.destroy();
                },
              ),
            ],
          );
        },
      );
    }
  }
}