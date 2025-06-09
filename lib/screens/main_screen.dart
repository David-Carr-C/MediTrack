import 'package:fluent_ui/fluent_ui.dart';
import 'package:medi_track/components/navigation_component.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isDark = false;

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'MediTrack',
      debugShowCheckedModeBanner: false,
      theme: _isDark ? _buildDarkTheme() : _buildLightTheme(),
      home: NavigationComponent(
        appBar: NavigationAppBar(
          title: const Text('MediTrack'),
          automaticallyImplyLeading: false,
          actions: Row(
            children: [
              ToggleSwitch(
                checked: _isDark,
                onChanged: (v) => setState(() => _isDark = v),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  FluentThemeData _buildLightTheme() => FluentThemeData(
    brightness: Brightness.light,
    navigationPaneTheme: NavigationPaneThemeData(
      backgroundColor: Colors.grey[50],
    ),
    // Añade Acrylic en el scaffold para profundidad
    buttonTheme: ButtonThemeData(),
  );

  FluentThemeData _buildDarkTheme() => FluentThemeData(
    brightness: Brightness.dark,
    navigationPaneTheme: NavigationPaneThemeData(
      backgroundColor: Colors.grey[900],
    ),
    buttonTheme: ButtonThemeData(),
  );
}
