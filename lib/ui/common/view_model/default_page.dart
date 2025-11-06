import 'package:cleteci_cross_platform/ui/common/widgets/page_component.dart';
import 'package:cleteci_cross_platform/ui/ocr/widgets/ocr.dart';
import 'package:cleteci_cross_platform/ui/speech_to_text/widgets/speech_to_text_screen.dart';
import 'package:cleteci_cross_platform/ui/settings/widgets/theme_settings_screen.dart';
import 'package:flutter/material.dart';

List<Widget> pages = <Widget>[
  const PageComponent(title: 'Dashboard', icon: Icons.widgets, color: Color(0xFF2196F3)),
  const OCRScreen(title: 'Textract', icon: Icons.camera_alt, color: Colors.green),
  const SpeechToTextScreen(),
  const ThemeSettingsScreen(),
];

class DrawerEntryDestination {
  const DrawerEntryDestination(
    this.index,
    this.label,
    this.disabled,
    this.icon,
    this.selectedIcon,
  );

  final int index;
  final String label;
  final bool disabled;
  final Widget icon;
  final Widget selectedIcon;
}

final List<DrawerEntryDestination> appDestinations = <DrawerEntryDestination>[
  const DrawerEntryDestination(
    0,
    'Dashboard',
    false,
    Icon(Icons.widgets_outlined),
    Icon(Icons.widgets),
  ),
  const DrawerEntryDestination(
    1,
    'Textract',
    false,
    Icon(Icons.format_paint_outlined),
    Icon(Icons.format_paint),
  ),
  const DrawerEntryDestination(
    2,
    'Speech to Text',
    false,
    Icon(Icons.mic_outlined),
    Icon(Icons.mic),
  ),
  const DrawerEntryDestination(
    3,
    'Theme Settings',
    false,
    Icon(Icons.palette_outlined),
    Icon(Icons.palette),
  ),
];
