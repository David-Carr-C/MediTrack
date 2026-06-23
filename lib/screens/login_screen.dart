import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:medi_track/models/user_role.dart';
import 'package:medi_track/services/auth_service.dart';

/// Formulario de login reutilizable, parametrizado por [role].
class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.role,
    required this.onLoggedIn,
    required this.onBack,
  });

  final UserRole role;

  /// Notifica la sesión a la raíz tras un login exitoso.
  final ValueChanged<Session> onLoggedIn;

  /// Regresa al selector de rol.
  final VoidCallback onBack;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final session = AuthService.login(
      widget.role,
      _userController.text,
      _passwordController.text,
    );
    if (session == null) {
      setState(() => _error = 'Usuario o contraseña incorrectos.');
      return;
    }
    widget.onLoggedIn(session);
  }

  @override
  Widget build(BuildContext context) {
    final isStudent = widget.role == UserRole.student;
    return fluent.ScaffoldPage(
      content: fluent.Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: fluent.Card(
            child: fluent.Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Acceso ${widget.role.label}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                fluent.InfoLabel(
                  label: isStudent ? 'Matrícula' : 'Usuario',
                  child: fluent.TextBox(
                    controller: _userController,
                    placeholder: isStudent ? 'Ej. 202084414' : 'Ej. profesor',
                    onSubmitted: (_) => _submit(),
                  ),
                ),
                const SizedBox(height: 16),
                fluent.InfoLabel(
                  label: 'Contraseña',
                  child: fluent.PasswordBox(
                    controller: _passwordController,
                    onSubmitted: (_) => _submit(),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  fluent.InfoBar(
                    title: const Text('Error'),
                    content: Text(_error!),
                    severity: fluent.InfoBarSeverity.error,
                    onClose: () => setState(() => _error = null),
                  ),
                ],
                const SizedBox(height: 24),
                fluent.FilledButton(
                  onPressed: _submit,
                  child: const Text('Entrar'),
                ),
                const SizedBox(height: 8),
                fluent.Button(
                  onPressed: widget.onBack,
                  child: const Text('Volver'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
