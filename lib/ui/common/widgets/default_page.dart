import 'package:cleteci_cross_platform/ui/common/view_model/default_page.dart';
import 'package:cleteci_cross_platform/ui/common/widgets/default_app_bar.dart';
import 'package:flutter/material.dart';

class DefaultPage extends StatefulWidget {
  const DefaultPage({super.key, required this.title});

  final String title;

  @override
  State<DefaultPage> createState() => _DefaultPageState();
}

class _DefaultPageState extends State<DefaultPage> {
  String _appBarTitle = appDestinations.first.label;
  int _selectedEntryIndex = 0;

  final sidebarTitle = 'Apps';

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
      body: pages[_selectedEntryIndex],
      drawer: NavigationDrawer(
        onDestinationSelected: (int index) {
          updateSelectedIndex(index);
          updateAppBarTitle(appDestinations[index].label);
          Navigator.pop(context);
        },
        selectedIndex: _selectedEntryIndex,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
            child: Text(
              sidebarTitle,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ...appDestinations.map((DrawerEntryDestination destination) {
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
