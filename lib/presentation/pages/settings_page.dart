import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/config/app_config.dart';
import '../../core/constants/app_constants.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  
  String _selectedLanguage = 'en';
  bool _isDarkMode = false;
  bool _enableNotifications = true;
  bool _autoSave = true;
  int _autoSaveInterval = 5; // minutes
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  void _loadSettings() {
    _userNameController.text = AppConfig.userName;
    _companyNameController.text = AppConfig.companyName;
    _selectedLanguage = AppConfig.language;
    _isDarkMode = AppConfig.isDarkMode;
  }
  
  @override
  void dispose() {
    _userNameController.dispose();
    _companyNameController.dispose();
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
            'Settings',
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Profile Section
          _buildSectionHeader('User Profile'),
          _buildUserProfileSection(),
          
          const SizedBox(height: 32),
          
          // Appearance Section
          _buildSectionHeader('Appearance'),
          _buildAppearanceSection(),
          
          const SizedBox(height: 32),
          
          // AI Settings Section
          _buildSectionHeader('AI Settings'),
          _buildAISettingsSection(),
          
          const SizedBox(height: 32),
          
          // Collaboration Section
          _buildSectionHeader('Collaboration'),
          _buildCollaborationSection(),
          
          const SizedBox(height: 32),
          
          // Advanced Section
          _buildSectionHeader('Advanced'),
          _buildAdvancedSection(),
          
          const SizedBox(height: 32),
          
          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveSettings,
              child: const Text('Save Settings'),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildUserProfileSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Avatar
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                _userNameController.text.isNotEmpty
                    ? _userNameController.text[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // User Name
            TextField(
              controller: _userNameController,
              decoration: const InputDecoration(
                labelText: 'User Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            
            // Company Name
            TextField(
              controller: _companyNameController,
              decoration: const InputDecoration(
                labelText: 'Company Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAppearanceSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Theme Toggle
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Use dark theme for the application'),
              value: _isDarkMode,
              onChanged: (value) {
                setState(() {
                  _isDarkMode = value;
                });
              },
              secondary: Icon(
                _isDarkMode ? Icons.dark_mode : Icons.light_mode,
              ),
            ),
            
            const Divider(),
            
            // Language Selection
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Language'),
              subtitle: Text(_getLanguageName(_selectedLanguage)),
              trailing: DropdownButton<String>(
                value: _selectedLanguage,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedLanguage = value;
                    });
                  }
                },
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'zh', child: Text('中文')),
                  DropdownMenuItem(value: 'ja', child: Text('日本語')),
                  DropdownMenuItem(value: 'ko', child: Text('한국어')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAISettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // AI Model Selection
            ListTile(
              leading: const Icon(Icons.psychology),
              title: const Text('AI Model'),
              subtitle: const Text('TensorFlow Lite (Local)'),
              trailing: ElevatedButton(
                onPressed: () {
                  // TODO: Open model selection dialog
                },
                child: const Text('Configure'),
              ),
            ),
            
            const Divider(),
            
            // Auto-generate suggestions
            SwitchListTile(
              title: const Text('Auto-generate Suggestions'),
              subtitle: const Text('Show AI suggestions while editing'),
              value: true,
              onChanged: (value) {
                // TODO: Implement auto-suggestions toggle
              },
              secondary: const Icon(Icons.auto_awesome),
            ),
            
            const Divider(),
            
            // Content generation style
            ListTile(
              leading: const Icon(Icons.style),
              title: const Text('Default Style'),
              subtitle: const Text('Business'),
              trailing: DropdownButton<String>(
                value: 'business',
                onChanged: (value) {
                  // TODO: Implement style selection
                },
                items: const [
                  DropdownMenuItem(value: 'business', child: Text('Business')),
                  DropdownMenuItem(value: 'academic', child: Text('Academic')),
                  DropdownMenuItem(value: 'creative', child: Text('Creative')),
                  DropdownMenuItem(value: 'minimalist', child: Text('Minimalist')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCollaborationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Notifications
            SwitchListTile(
              title: const Text('Enable Notifications'),
              subtitle: const Text('Receive collaboration notifications'),
              value: _enableNotifications,
              onChanged: (value) {
                setState(() {
                  _enableNotifications = value;
                });
              },
              secondary: const Icon(Icons.notifications),
            ),
            
            const Divider(),
            
            // Auto-save
            SwitchListTile(
              title: const Text('Auto-save'),
              subtitle: const Text('Automatically save changes'),
              value: _autoSave,
              onChanged: (value) {
                setState(() {
                  _autoSave = value;
                });
              },
              secondary: const Icon(Icons.save),
            ),
            
            if (_autoSave) ...[
              const Divider(),
              
              // Auto-save interval
              ListTile(
                leading: const Icon(Icons.timer),
                title: const Text('Auto-save Interval'),
                subtitle: Text('$_autoSaveInterval minutes'),
                trailing: DropdownButton<int>(
                  value: _autoSaveInterval,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _autoSaveInterval = value;
                      });
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('1 minute')),
                    DropdownMenuItem(value: 5, child: Text('5 minutes')),
                    DropdownMenuItem(value: 10, child: Text('10 minutes')),
                    DropdownMenuItem(value: 30, child: Text('30 minutes')),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildAdvancedSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Clear cache
            ListTile(
              leading: const Icon(Icons.cleaning_services),
              title: const Text('Clear Cache'),
              subtitle: const Text('Clear temporary files and cache'),
              trailing: ElevatedButton(
                onPressed: _clearCache,
                child: const Text('Clear'),
              ),
            ),
            
            const Divider(),
            
            // Export settings
            ListTile(
              leading: const Icon(Icons.upload),
              title: const Text('Export Settings'),
              subtitle: const Text('Export current settings to file'),
              trailing: ElevatedButton(
                onPressed: _exportSettings,
                child: const Text('Export'),
              ),
            ),
            
            const Divider(),
            
            // Import settings
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Import Settings'),
              subtitle: const Text('Import settings from file'),
              trailing: ElevatedButton(
                onPressed: _importSettings,
                child: const Text('Import'),
              ),
            ),
            
            const Divider(),
            
            // Reset to defaults
            ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('Reset to Defaults'),
              subtitle: const Text('Reset all settings to default values'),
              trailing: ElevatedButton(
                onPressed: _resetToDefaults,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                child: const Text('Reset'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'zh':
        return '中文';
      case 'ja':
        return '日本語';
      case 'ko':
        return '한국어';
      default:
        return 'English';
    }
  }
  
  void _saveSettings() {
    // Save user profile
    AppConfig.userName = _userNameController.text;
    AppConfig.companyName = _companyNameController.text;
    
    // Save appearance settings
    AppConfig.isDarkMode = _isDarkMode;
    AppConfig.language = _selectedLanguage;
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('Are you sure you want to clear the cache? This will remove temporary files.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
  
  void _exportSettings() {
    // TODO: Implement settings export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings export not yet implemented'),
        backgroundColor: Colors.orange,
      ),
    );
  }
  
  void _importSettings() {
    // TODO: Implement settings import
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings import not yet implemented'),
        backgroundColor: Colors.orange,
      ),
    );
  }
  
  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Defaults'),
        content: const Text('Are you sure you want to reset all settings to default values? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _userNameController.text = '';
                _companyNameController.text = '';
                _selectedLanguage = 'en';
                _isDarkMode = false;
                _enableNotifications = true;
                _autoSave = true;
                _autoSaveInterval = 5;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings reset to defaults'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}