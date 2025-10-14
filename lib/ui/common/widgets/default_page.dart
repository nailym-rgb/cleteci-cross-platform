import 'package:cleteci_cross_platform/ui/common/widgets/default_app_bar.dart';
import 'package:cleteci_cross_platform/ui/common/widgets/page_component.dart';
import 'package:flutter/material.dart';

const List<Widget> _pages = <Widget>[
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

final List<DrawerEntryDestination> destinations = <DrawerEntryDestination>[
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

class DefaultPage extends StatefulWidget {
  const DefaultPage({super.key, required this.title});

  final String title;

  @override
  State<DefaultPage> createState() => _DefaultPageState();
}

class _DefaultPageState extends State<DefaultPage> {
  String _appBarTitle = destinations.first.label;
  int _selectedEntryIndex = 0;

  void updateSelectedIndex(int index) {
    setState(() {
      _selectedEntryIndex = index;
    });
  }

  void updateAppBarTitle(String title) {
    setState(() {
      _appBarTitle = title;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(title: _appBarTitle),
      body: _pages[_selectedEntryIndex],
      drawer: NavigationDrawer(
        onDestinationSelected: (int index) {
          updateSelectedIndex(index);
          updateAppBarTitle(destinations[index].label);
          Navigator.pop(context);
        },
        selectedIndex: _selectedEntryIndex,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
            child: Text('Apps', style: Theme.of(context).textTheme.titleSmall),
          ),
          ...destinations.map((DrawerEntryDestination destination) {
            return NavigationDrawerDestination(
              label: Text(destination.label),
              icon: destination.icon,
              selectedIcon: destination.selectedIcon,
            );
          }),
          const Padding(
            padding: EdgeInsets.fromLTRB(28, 16, 28, 10),
            child: Divider(),
          ),
        ],
      ),
    );
  }
}
