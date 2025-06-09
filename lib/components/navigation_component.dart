import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:medi_track/screens/student_screen.dart';

class NavigationComponent extends StatefulWidget {
  const NavigationComponent({
    super.key,
    required fluent.NavigationAppBar appBar,
  });

  @override
  State<NavigationComponent> createState() => _NavigationComponentState();
}

class _NavigationComponentState extends State<NavigationComponent> {
  int _selectedIndex = 0;

  List<fluent.NavigationPaneItem> _getPaneItems() {
    return [
      // Menú Principal
      fluent.PaneItem(
        icon: const Icon(fluent.FluentIcons.home),
        title: const Text('Menú'),
        body: const StudentScreen(),
      ),

      // Simuladores
      fluent.PaneItem(
        icon: const Icon(fluent.FluentIcons.bar_chart_vertical),
        title: const Text('Simuladores'),
        body: fluent.Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: fluent.Card(
              child: fluent.Padding(
                padding: const EdgeInsets.all(16),
                child: fluent.Column(
                  mainAxisSize: fluent.MainAxisSize.min,
                  children: const [
                    Text('Progreso de Simulación'),
                    SizedBox(height: 12),
                    fluent.ProgressRing(value: 0.5, strokeWidth: 8.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),

      // Ajustes
      fluent.PaneItem(
        icon: const Icon(fluent.FluentIcons.settings),
        title: const Text('Ajustes'),
        body: fluent.Center(
          child: fluent.Card(
            child: fluent.Padding(
              padding: const EdgeInsets.all(20),
              child: const Text('Aquí van los ajustes de la aplicación'),
            ),
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return fluent.NavigationView(
      pane: fluent.NavigationPane(
        displayMode: fluent.PaneDisplayMode.auto,
        items: _getPaneItems(),
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
