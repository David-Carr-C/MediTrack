import 'package:fluent_ui/fluent_ui.dart';
import 'package:medi_track/components/navigation_component.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'Progress Screen',
      debugShowCheckedModeBanner: false,
      theme: FluentThemeData(
        brightness: Brightness.light,
        accentColor: AccentColor.swatch(const <String, Color>{
          'normal': Color(0xFF0078D4),
          'dark': Color(0xFF005A9E),
          'light': Color(0xFF68A4E6),
        }),
      ),
      home: NavigationComponent(),
    );
  }
}
