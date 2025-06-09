import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';

class NavigationComponent extends StatefulWidget {
  const NavigationComponent({super.key});

  @override
  State<NavigationComponent> createState() => _NavigationComponentState();
}

class _NavigationComponentState extends State<NavigationComponent> {
  int _selectedIndex = 0;

  _onClickLeadingButton() {}

  @override
  Widget build(BuildContext context) {
    return fluent.NavigationView(
      appBar: fluent.NavigationAppBar(
        leading: Center(
          child: IconButton(
            icon: const Icon(fluent.FluentIcons.expand_menu),
            onPressed: _onClickLeadingButton,
          ),
        ),
      ),
      pane: fluent.NavigationPane(
        displayMode: fluent.PaneDisplayMode.auto,
        items: [
          fluent.PaneItem(
            icon: const Icon(fluent.FluentIcons.home),
            title: const Text('Menu'),
            body: Center(child: Text('Home Screen')),
          ),
          fluent.PaneItem(
            icon: const Icon(fluent.FluentIcons.calendar),
            title: const Text(''),
            body: fluent.ScaffoldPage(
              header: const fluent.PageHeader(title: Text('Progress')),
              content: Center(child: fluent.ProgressBar()),
            ),
          ),
          fluent.PaneItem(
            icon: const Icon(fluent.FluentIcons.settings),
            title: const Text('Configuración'),
            body: Center(child: Text('Settings Screen')),
          ),
        ],
        selected: _selectedIndex,
        onChanged: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
