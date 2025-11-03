import 'package:cleteci_cross_platform/ui/common/widgets/page_component.dart';
import 'package:cleteci_cross_platform/ui/ocr/widgets/ocr.dart';
import 'package:flutter/material.dart';

List<Widget> pages = <Widget>[
  PageComponent(title: 'Dashboard', icon: Icons.widgets, color: Color(0xFF2196F3)),
  OCRScreen(title: 'Textract', icon: Icons.camera_alt, color: Colors.green),
  PageComponent(title: 'Speech To Text', icon: Icons.mic, color: Color(0xFFFF9800)),
  const SettingsPage(),
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
    Icon(Icons.format_paint_outlined),
    Icon(Icons.format_paint),
  ),
  const DrawerEntryDestination(
    3,
    'Settings',
    false,
    Icon(Icons.settings_outlined),
    Icon(Icons.settings),
  ),
];
