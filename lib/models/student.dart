import 'package:medi_track/models/simulation.dart';

/// Datos de un alumno y su avance en las simulaciones.
class Student {
  final String matricula;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String fechaNacimiento;
  final String carrera;
  final String semestre;
  final String email;
  final List<SimulationProgress> avances;

  const Student({
    required this.matricula,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.fechaNacimiento,
    required this.carrera,
    required this.semestre,
    required this.email,
    this.avances = const [],
  });

  String get nombreCompleto => '$nombre $apellidoPaterno $apellidoMaterno';

  /// Porcentaje de avance promedio sobre todas las simulaciones registradas.
  double get avancePromedio {
    if (avances.isEmpty) return 0;
    final total = avances.fold<double>(0, (sum, a) => sum + a.percent);
    return total / avances.length;
  }
}
