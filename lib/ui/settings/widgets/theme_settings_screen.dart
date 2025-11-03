import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme_provider.dart';

class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customize Theme Colors',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Primary Color Section
            _buildColorSection(
              title: 'Primary Color',
              subtitle: 'Main color used throughout the app',
              currentColor: themeProvider.primaryColor,
              onColorChanged: (color) => themeProvider.setPrimaryColor(color),
            ),

            const SizedBox(height: 24),

            // Seed Color Section
            _buildColorSection(
              title: 'Seed Color',
              subtitle: 'Base color for generating the color scheme',
              currentColor: themeProvider.seedColor,
              onColorChanged: (color) => themeProvider.setSeedColor(color),
            ),

            const SizedBox(height: 24),

            // App Bar Text Color Section
            _buildColorSection(
              title: 'App Bar Text Color',
              subtitle: 'Text color for app bars and navigation',
              currentColor: themeProvider.appBarTextColor,
              onColorChanged: (color) => themeProvider.setAppBarTextColor(color),
            ),

            const SizedBox(height: 24),

            // Button Text Color Section
            _buildColorSection(
              title: 'Button Text Color',
              subtitle: 'Text color for buttons',
              currentColor: themeProvider.buttonTextColor,
              onColorChanged: (color) => themeProvider.setButtonTextColor(color),
            ),

            const SizedBox(height: 24),

            // Error Color Section
            _buildColorSection(
              title: 'Error Color',
              subtitle: 'Background color for error messages',
              currentColor: themeProvider.errorColor,
              onColorChanged: (color) => themeProvider.setErrorColor(color),
            ),

            const SizedBox(height: 24),

            // Error Text Color Section
            _buildColorSection(
              title: 'Error Text Color',
              subtitle: 'Text color for error messages',
              currentColor: themeProvider.errorTextColor,
              onColorChanged: (color) => themeProvider.setErrorTextColor(color),
            ),

            const SizedBox(height: 32),

            // Reset Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _showResetDialog(context, themeProvider),
                icon: const Icon(Icons.restore),
                label: const Text('Reset to Defaults'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Preview Section
            const Text(
              'Preview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildThemePreview(themeProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSection({
    required String title,
    required String subtitle,
    required Color currentColor,
    required Function(Color) onColorChanged,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: currentColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showColorPicker(context, currentColor, onColorChanged),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: const Text('Choose Color'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemePreview(ThemeProvider themeProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Bar Preview
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: themeProvider.primaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  'App Bar Preview',
                  style: TextStyle(
                    color: themeProvider.appBarTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Button Previews
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeProvider.primaryColor,
                      foregroundColor: themeProvider.buttonTextColor,
                    ),
                    child: const Text('Primary Button'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Outlined Button'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Error Message Preview
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: themeProvider.errorColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: themeProvider.errorTextColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This is an error message preview',
                      style: TextStyle(
                        color: themeProvider.errorTextColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context, Color currentColor, Function(Color) onColorChanged) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            currentColor: currentColor,
            onColorChanged: onColorChanged,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Theme'),
        content: const Text('Are you sure you want to reset the theme to default colors?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              themeProvider.resetToDefaults();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Theme reset to defaults')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class ColorPicker extends StatefulWidget {
  final Color currentColor;
  final Function(Color) onColorChanged;

  const ColorPicker({
    super.key,
    required this.currentColor,
    required this.onColorChanged,
  });

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.currentColor;
  }

  void _showCustomColorPicker(BuildContext context) {
    // Simple RGB sliders for custom color selection
    int red = _selectedColor.red;
    int green = _selectedColor.green;
    int blue = _selectedColor.blue;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Custom Color Picker'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Color preview
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, red, green, blue),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // RGB Sliders
              _buildColorSlider(
                label: 'Red',
                value: red.toDouble(),
                onChanged: (value) {
                  setState(() => red = value.toInt());
                },
              ),
              _buildColorSlider(
                label: 'Green',
                value: green.toDouble(),
                onChanged: (value) {
                  setState(() => green = value.toInt());
                },
              ),
              _buildColorSlider(
                label: 'Blue',
                value: blue.toDouble(),
                onChanged: (value) {
                  setState(() => blue = value.toInt());
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final customColor = Color.fromARGB(255, red, green, blue);
                this.setState(() {
                  _selectedColor = customColor;
                });
                widget.onColorChanged(customColor);
                Navigator.of(context).pop();
              },
              child: const Text('Select'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSlider({
    required String label,
    required double value,
    required Function(double) onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 50,
          child: Text(label),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: 0,
            max: 255,
            divisions: 255,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            value.toInt().toString(),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Current color display
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: _selectedColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Predefined colors grid
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Custom color picker button
            GestureDetector(
              onTap: () => _showCustomColorPicker(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.red, Colors.yellow, Colors.blue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.palette,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            // Predefined colors
            ..._predefinedColors.map((color) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                  widget.onColorChanged(color);
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _selectedColor == color
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).dividerColor,
                      width: _selectedColor == color ? 3 : 1,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  static const List<Color> _predefinedColors = [
    // Material Design Colors
    Color(0xFF2196F3), // Blue
    Color(0xFF4CAF50), // Green
    Color(0xFFFF9800), // Orange
    Color(0xFFE91E63), // Pink
    Color(0xFF9C27B0), // Purple
    Color(0xFF00BCD4), // Cyan
    Color(0xFF8BC34A), // Light Green
    Color(0xFFFF5722), // Deep Orange
    Color(0xFF795548), // Brown
    Color(0xFF607D8B), // Blue Grey
    Color(0xFF3F51B5), // Indigo
    Color(0xFF009688), // Teal
    Color(0xFFFFC107), // Amber
    Color(0xFF673AB7), // Deep Purple
    Color(0xFFCDDC39), // Lime
    Color(0xFF00ACC1), // Cyan 700
    Color(0xFF388E3C), // Green 700
    Color(0xFFF57C00), // Orange 700
    Color(0xFF7B1FA2), // Purple 700
    Color(0xFFC2185B), // Pink 700
    Color(0xFF1976D2), // Blue 700
    Color(0xFF689F38), // Light Green 700
    Color(0xFF455A64), // Blue Grey 700
    Color(0xFF5D4037), // Brown 700
    Color(0xFF512DA8), // Deep Purple 700
    Color(0xFFBF360C), // Deep Orange 900
    Color(0xFF0D47A1), // Blue 900
    Color(0xFF1B5E20), // Green 900
    Color(0xFFE65100), // Orange 900
    Color(0xFF4A148C), // Purple 900
    Color(0xFF880E4F), // Pink 900
    // Additional vibrant colors
    Color(0xFFFF4081), // Pink A200
    Color(0xFF00E676), // Green A200
    Color(0xFF18FFFF), // Cyan A200
    Color(0xFFFF6F00), // Orange A200
    Color(0xFFAA00FF), // Purple A200
    Color(0xFFFF1744), // Red A200
    Color(0xFF00E5FF), // Cyan A400
    Color(0xFF76FF03), // Light Green A400
    Color(0xFFFFD600), // Yellow A400
    Color(0xFF3D5AFE), // Indigo A200
    Color(0xFFD500F9), // Purple A400
    Color(0xFFFF3D00), // Deep Orange A400
    // Neutral colors
    Color(0xFF212121), // Grey 900
    Color(0xFF424242), // Grey 800
    Color(0xFF616161), // Grey 700
    Color(0xFF757575), // Grey 600
    Color(0xFF9E9E9E), // Grey 500
    Color(0xFFBDBDBD), // Grey 400
    Color(0xFFE0E0E0), // Grey 300
    Color(0xFFEEEEEE), // Grey 200
    Color(0xFFF5F5F5), // Grey 100
    Color(0xFFFAFAFA), // Grey 50
    // White and Black
    Color(0xFFFFFFFF), // White
    Color(0xFF000000), // Black
  ];
}