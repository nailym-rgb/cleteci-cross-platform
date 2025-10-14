
import 'package:cleteci_cross_platform/ui/common/widgets/page_component.dart';
import 'package:flutter/material.dart';

const List<Widget> pages = <Widget>[
  PageComponent(title: 'Dashboard', icon: Icons.widgets, color: Colors.blue),
  PageComponent(title: 'OCR', icon: Icons.camera_alt, color: Colors.green),
  PageComponent(title: 'Speech To Text', icon: Icons.mic, color: Colors.orange),
  PageComponent(title: 'Settings', icon: Icons.settings, color: Colors.grey),
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
  DrawerEntryDestination(
    0,
    'Dashboard',
    false,
    const Icon(Icons.widgets_outlined),
    const Icon(Icons.widgets),
  ),
  DrawerEntryDestination(
    1,
    'OCR',
    false,
    Icon(Icons.format_paint_outlined),
    Icon(Icons.format_paint),
  ),
  DrawerEntryDestination(
    2,
    'Speech to Text',
    false,
    Icon(Icons.format_paint_outlined),
    Icon(Icons.format_paint),
  ),
  DrawerEntryDestination(
    3,
    'Settings',
    false,
    const Icon(Icons.settings_outlined),
    const Icon(Icons.settings),
  ),
];
