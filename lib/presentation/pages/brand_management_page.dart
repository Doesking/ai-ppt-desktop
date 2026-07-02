import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/constants/app_constants.dart';
import '../../data/services/brand_service.dart';

class BrandManagementPage extends ConsumerStatefulWidget {
  const BrandManagementPage({super.key});

  @override
  ConsumerState<BrandManagementPage> createState() => _BrandManagementPageState();
}

class _BrandManagementPageState extends ConsumerState<BrandManagementPage> {
  final BrandService _brandService = BrandService();
  
  List<BrandProfile> _brands = [];
  BrandProfile? _selectedBrand;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadBrands();
  }
  
  Future<void> _loadBrands() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _brandService.initialize();
      final brands = _brandService.getAllBrandProfiles();
      
      setState(() {
        _brands = brands;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load brands: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
            'Brand Management',
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
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    return Row(
      children: [
        // Left Panel - Brand List
        Container(
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
          child: _buildBrandList(),
        ),
        
        // Right Panel - Brand Details
        Expanded(
          child: _selectedBrand != null
              ? _buildBrandDetails()
              : _buildEmptyState(),
        ),
      ],
    );
  }
  
  Widget _buildBrandList() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Text(
                'Brand Profiles',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _createNewBrand,
                tooltip: 'Create New Brand',
              ),
            ],
          ),
        ),
        
        // Brand List
        Expanded(
          child: ListView.builder(
            itemCount: _brands.length,
            itemBuilder: (context, index) {
              final brand = _brands[index];
              final isSelected = _selectedBrand?.id == brand.id;
              
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(int.parse(brand.colors.primary.replaceFirst('#', '0xFF'))),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      brand.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                title: Text(brand.name),
                subtitle: Text(brand.description),
                selected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedBrand = brand;
                  });
                },
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem(
                      value: 'duplicate',
                      child: Text('Duplicate'),
                    ),
                    const PopupMenuItem(
                      value: 'export',
                      child: Text('Export'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                  onSelected: (value) => _handleBrandAction(value, brand),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildBrandDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand Header
          _buildBrandHeader(),
          
          const SizedBox(height: 24),
          
          // Color Palette
          _buildColorPalette(),
          
          const SizedBox(height: 24),
          
          // Typography
          _buildTypographySection(),
          
          const SizedBox(height: 24),
          
          // Logo
          _buildLogoSection(),
          
          const SizedBox(height: 24),
          
          // Actions
          _buildActionButtons(),
        ],
      ),
    );
  }
  
  Widget _buildBrandHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Color(int.parse(_selectedBrand!.colors.primary.replaceFirst('#', '0xFF'))),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      _selectedBrand!.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedBrand!.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        _selectedBrand!.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _editBrand(_selectedBrand!),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildColorPalette() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Color Palette',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildColorSwatch('Primary', _selectedBrand!.colors.primary),
                _buildColorSwatch('Secondary', _selectedBrand!.colors.secondary),
                _buildColorSwatch('Accent', _selectedBrand!.colors.accent),
                _buildColorSwatch('Background', _selectedBrand!.colors.background),
                _buildColorSwatch('Text', _selectedBrand!.colors.text),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildColorSwatch(String label, String colorHex) {
    final color = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          colorHex,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
  
  Widget _buildTypographySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Typography',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.title),
              title: const Text('Title Font'),
              subtitle: Text(_selectedBrand!.typography.titleFont),
              trailing: Text('${_selectedBrand!.typography.titleFontSize}px'),
            ),
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: const Text('Body Font'),
              subtitle: Text(_selectedBrand!.typography.bodyFont),
              trailing: Text('${_selectedBrand!.typography.bodyFontSize}px'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLogoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Logo',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Logo Path'),
              subtitle: Text(_selectedBrand!.logo.path),
            ),
            ListTile(
              leading: const Icon(Icons.format_align_center),
              title: const Text('Position'),
              subtitle: Text(_selectedBrand!.logo.position.toString().split('.').last),
            ),
            ListTile(
              leading: const Icon(Icons.aspect_ratio),
              title: const Text('Minimum Size'),
              subtitle: Text('${_selectedBrand!.logo.minimumSize}px'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _applyBrand(_selectedBrand!),
            icon: const Icon(Icons.check),
            label: const Text('Apply to Presentation'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _generateGuidelines(_selectedBrand!),
            icon: const Icon(Icons.description),
            label: const Text('Generate Guidelines'),
          ),
        ),
      ],
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.branding_watermark,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Select a brand profile',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a brand from the list or create a new one',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  void _createNewBrand() {
    // TODO: Implement brand creation dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Brand creation not yet implemented'),
        backgroundColor: Colors.orange,
      ),
    );
  }
  
  void _editBrand(BrandProfile brand) {
    // TODO: Implement brand editing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editing ${brand.name}'),
        backgroundColor: Colors.blue,
      ),
    );
  }
  
  void _handleBrandAction(String action, BrandProfile brand) {
    switch (action) {
      case 'edit':
        _editBrand(brand);
        break;
      case 'duplicate':
        _duplicateBrand(brand);
        break;
      case 'export':
        _exportBrand(brand);
        break;
      case 'delete':
        _deleteBrand(brand);
        break;
    }
  }
  
  void _duplicateBrand(BrandProfile brand) {
    // TODO: Implement brand duplication
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Duplicating ${brand.name}'),
        backgroundColor: Colors.blue,
      ),
    );
  }
  
  void _exportBrand(BrandProfile brand) {
    // TODO: Implement brand export
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting ${brand.name}'),
        backgroundColor: Colors.blue,
      ),
    );
  }
  
  void _deleteBrand(BrandProfile brand) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Brand'),
        content: Text('Are you sure you want to delete "${brand.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await _brandService.deleteBrandProfile(brand.id);
                await _loadBrands();
                
                if (_selectedBrand?.id == brand.id) {
                  setState(() {
                    _selectedBrand = null;
                  });
                }
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${brand.name} deleted'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete brand: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  void _applyBrand(BrandProfile brand) {
    // TODO: Implement brand application
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Applied ${brand.name} to current presentation'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  void _generateGuidelines(BrandProfile brand) {
    // TODO: Implement guidelines generation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Generating guidelines for ${brand.name}'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}