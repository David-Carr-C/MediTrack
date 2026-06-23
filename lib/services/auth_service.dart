import 'package:medi_track/models/user_role.dart';

/// Sesión activa tras un login exitoso.
class Session {
  final UserRole role;

  /// Identificador del usuario: matrícula del alumno o id del profesor.
  final String userId;
  final String displayName;

  const Session({
    required this.role,
    required this.userId,
    required this.displayName,
  });
}

/// Credencial mock asociada a un usuario.
class _MockCredential {
  final String password;
  final String userId;
  final String displayName;

  const _MockCredential({
    required this.password,
    required this.userId,
    required this.displayName,
  });
}

/// Autenticación mock (sin backend). Credenciales hardcodeadas por rol.
class AuthService {
  static const Map<String, _MockCredential> _students = {
    '202084414': _MockCredential(
      password: 'alumno123',
      userId: '202084414',
      displayName: 'Irvin Gómez',
    ),
    '202156789': _MockCredential(
      password: 'alumno123',
      userId: '202156789',
      displayName: 'María Hernández',
    ),
  };

  static const Map<String, _MockCredential> _teachers = {
    'profesor': _MockCredential(
      password: 'profesor123',
      userId: 'profesor',
      displayName: 'Dr. Profesor',
    ),
  };

  /// Intenta iniciar sesión. Devuelve la [Session] o `null` si las
  /// credenciales no son válidas para el rol indicado.
  static Session? login(UserRole role, String user, String password) {
    final table = role == UserRole.student ? _students : _teachers;
    final credential = table[user.trim()];
    if (credential == null || credential.password != password) {
      return null;
    }
    return Session(
      role: role,
      userId: credential.userId,
      displayName: credential.displayName,
    );
  }
}
