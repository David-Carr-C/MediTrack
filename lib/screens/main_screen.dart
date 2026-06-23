import 'package:fluent_ui/fluent_ui.dart';
import 'package:medi_track/components/navigation_component.dart';
import 'package:medi_track/models/user_role.dart';
import 'package:medi_track/screens/login_screen.dart';
import 'package:medi_track/screens/role_selection_screen.dart';
import 'package:medi_track/services/auth_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isDark = false;
  UserRole? _selectedRole;
  Session? _session;

  void _logout() {
    setState(() {
      _session = null;
      _selectedRole = null;
    });
  }

  Widget _buildHome() {
    final session = _session;
    if (session != null) {
      return NavigationComponent(
        session: session,
        onLogout: _logout,
        isDark: _isDark,
        onThemeChanged: (v) => setState(() => _isDark = v),
      );
    }

    final role = _selectedRole;
    if (role != null) {
      return LoginScreen(
        role: role,
        onLoggedIn: (s) => setState(() => _session = s),
        onBack: () => setState(() => _selectedRole = null),
      );
    }

    return RoleSelectionScreen(
      onRoleSelected: (r) => setState(() => _selectedRole = r),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'MediTrack',
      debugShowCheckedModeBanner: false,
      theme: _isDark ? _buildDarkTheme() : _buildLightTheme(),
      home: _buildHome(),
    );
  }

  FluentThemeData _buildLightTheme() => FluentThemeData(
    brightness: Brightness.light,
    navigationPaneTheme: NavigationPaneThemeData(
      backgroundColor: Colors.grey[50],
    ),
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
