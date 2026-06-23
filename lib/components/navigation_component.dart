import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:medi_track/models/user_role.dart';
import 'package:medi_track/screens/simulation_screen.dart';
import 'package:medi_track/screens/student_screen.dart';
import 'package:medi_track/screens/teacher_screen.dart';
import 'package:medi_track/services/auth_service.dart';

/// Panel de navegación role-aware. Muestra los destinos del alumno o del
/// profesor según la sesión, con acciones de tema y cierre de sesión.
class NavigationComponent extends StatefulWidget {
  const NavigationComponent({
    super.key,
    required this.session,
    required this.onLogout,
    required this.isDark,
    required this.onThemeChanged,
  });

  final Session session;
  final VoidCallback onLogout;
  final bool isDark;
  final ValueChanged<bool> onThemeChanged;

  @override
  State<NavigationComponent> createState() => _NavigationComponentState();
}

class _NavigationComponentState extends State<NavigationComponent> {
  int _selectedIndex = 0;

  static final fluent.PaneItem _settingsPane = fluent.PaneItem(
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
  );

  List<fluent.NavigationPaneItem> _getPaneItems() {
    if (widget.session.role == UserRole.teacher) {
      return [
        fluent.PaneItem(
          icon: const Icon(fluent.FluentIcons.people),
          title: const Text('Alumnos'),
          body: const TeacherScreen(),
        ),
        _settingsPane,
      ];
    }

    return [
      fluent.PaneItem(
        icon: const Icon(fluent.FluentIcons.home),
        title: const Text('Menú'),
        body: StudentScreen(
          matricula: widget.session.userId,
          onLogout: widget.onLogout,
        ),
      ),
      fluent.PaneItem(
        icon: const Icon(fluent.FluentIcons.bar_chart_vertical),
        title: const Text('Simuladores'),
        body: const SimulationScreen(),
      ),
      _settingsPane,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return fluent.NavigationView(
      appBar: fluent.NavigationAppBar(
        title: const Text('MediTrack'),
        automaticallyImplyLeading: false,
        actions: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            fluent.ToggleSwitch(
              checked: widget.isDark,
              onChanged: widget.onThemeChanged,
            ),
            const SizedBox(width: 12),
            fluent.Button(
              onPressed: widget.onLogout,
              child: const Text('Cerrar Sesión'),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
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
