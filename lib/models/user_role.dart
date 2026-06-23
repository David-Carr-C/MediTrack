/// Roles disponibles en la aplicación.
enum UserRole { student, teacher }

extension UserRoleLabel on UserRole {
  /// Nombre legible en español del rol.
  String get label {
    switch (this) {
      case UserRole.student:
        return 'Alumno';
      case UserRole.teacher:
        return 'Profesor';
    }
  }
}
