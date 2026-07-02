import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/constants/app_constants.dart';
import '../../data/services/ppt_service.dart';
import '../../data/services/audio_service.dart';
import '../../data/services/video_service.dart';
import '../../data/services/speech_recognition_service.dart';
import '../../data/services/collaboration_service.dart';
import '../../data/services/brand_service.dart';
import '../../ai/models/model_manager.dart';
import '../../ai/processors/content_generator.dart';
import '../../ai/processors/template_recommender.dart';
import '../../ai/processors/speech_to_ppt_processor.dart';
import '../../ai/processors/video_to_ppt_processor.dart';

import 'home_page.dart';
import 'ppt_editor_page.dart';
import 'settings_page.dart';
import 'brand_management_page.dart';
import 'collaboration_page.dart';

class MainAppPage extends ConsumerStatefulWidget {
  const MainAppPage({super.key});

  @override
  ConsumerState<MainAppPage> createState() => _MainAppPageState();
}

class _MainAppPageState extends ConsumerState<MainAppPage> {
  // Services
  late final PPTService _pptService;
  late final AudioService _audioService;
  late final VideoService _videoService;
  late final SpeechRecognitionService _speechService;
  late final CollaborationService _collaborationService;
  late final BrandService _brandService;
  
  // AI Components
  late final ModelManager _modelManager;
  late final ContentGenerator _contentGenerator;
  late final TemplateRecommender _templateRecommender;
  late final SpeechToPPTProcessor _speechToPPTProcessor;
  late final VideoToPPTProcessor _videoToPPTProcessor;
  
  // State
  bool _isInitialized = false;
  String _currentView = 'home';
  
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }
  
  Future<void> _initializeServices() async {
    try {
      // Initialize services
      _pptService = PPTService();
      _audioService = AudioService();
      _videoService = VideoService();
      _speechService = SpeechRecognitionService();
      _collaborationService = CollaborationService();
      _brandService = BrandService();
      
      // Initialize AI components
      _modelManager = ModelManager();
      _contentGenerator = ContentGenerator(_modelManager);
      _templateRecommender = TemplateRecommender();
      _speechToPPTProcessor = SpeechToPPTProcessor(
        modelManager: _modelManager,
        speechService: _speechService,
        pptService: _pptService,
      );
      _videoToPPTProcessor = VideoToPPTProcessor(
        modelManager: _modelManager,
        videoService: _videoService,
        audioService: _audioService,
        speechService: _speechService,
        pptService: _pptService,
      );
      
      // Initialize services
      await _audioService.initialize();
      await _videoService.initialize();
      await _speechService.initialize();
      await _collaborationService.initialize();
      await _brandService.initialize();
      
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Failed to initialize services: $e');
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // Dispose services
    _audioService.dispose();
    _modelManager.dispose();
    _collaborationService.dispose();
    _brandService.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return _buildLoadingScreen();
    }
    
    return _buildMainApp();
  }
  
  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Center(
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
              'AI PPT Desktop',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Initializing services...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMainApp() {
    return Scaffold(
      body: Column(
        children: [
          // Main Title Bar with Navigation
          _buildMainTitleBar(),
          
          // Main Content Area
          Expanded(
            child: _buildCurrentView(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMainTitleBar() {
    return Container(
      height: 50,
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
          // App Logo and Name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.slideshow,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Navigation Tabs
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildNavTab('home', 'Home', Icons.home),
                _buildNavTab('editor', 'Editor', Icons.edit),
                _buildNavTab('voice', 'Voice', Icons.mic),
                _buildNavTab('video', 'Video', Icons.videocam),
                _buildNavTab('collaborate', 'Collaborate', Icons.people),
                _buildNavTab('brands', 'Brands', Icons.branding_watermark),
                _buildNavTab('settings', 'Settings', Icons.settings),
              ],
            ),
          ),
          
          // Window Controls
          Row(
            children: [
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
        ],
      ),
    );
  }
  
  Widget _buildNavTab(String view, String label, IconData icon) {
    final isSelected = _currentView == view;
    
    return InkWell(
      onTap: () {
        setState(() {
          _currentView = view;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCurrentView() {
    switch (_currentView) {
      case 'home':
        return const HomePage();
      case 'editor':
        return const PPTEditorPage();
      case 'voice':
        return _buildVoiceToPPTView();
      case 'video':
        return _buildVideoToPPTView();
      case 'collaborate':
        return const CollaborationPage(
          presentationId: 'current',
          presentationTitle: 'Current Presentation',
        );
      case 'brands':
        return const BrandManagementPage();
      case 'settings':
        return const SettingsPage();
      default:
        return const HomePage();
    }
  }
  
  Widget _buildVoiceToPPTView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mic,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Voice to PPT',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'Record audio or import audio files to generate presentations',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _startVoiceRecording,
                icon: const Icon(Icons.mic),
                label: const Text('Start Recording'),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: _importAudioFile,
                icon: const Icon(Icons.upload_file),
                label: const Text('Import Audio'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildVideoToPPTView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.videocam,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Video to PPT',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'Import video files to extract content and generate presentations',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _importVideoFile,
            icon: const Icon(Icons.upload_file),
            label: const Text('Import Video'),
          ),
        ],
      ),
    );
  }
  
  void _startVoiceRecording() {
    // TODO: Implement voice recording
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice recording started'),
        backgroundColor: Colors.blue,
      ),
    );
  }
  
  void _importAudioFile() {
    // TODO: Implement audio file import
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Audio import not yet implemented'),
        backgroundColor: Colors.orange,
      ),
    );
  }
  
  void _importVideoFile() {
    // TODO: Implement video file import
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Video import not yet implemented'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}