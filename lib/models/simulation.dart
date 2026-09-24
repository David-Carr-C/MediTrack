import 'package:medi_track/models/teacher_comment.dart';

/// Tipos de simulación disponibles.
enum SimulationType {
  femurCut,
  hipCut,
  kneeCut,
  suture,
  injection,
  lapToolControl,
  vesselHandling,
}

/// Nombres amigables (en español) para cada simulación.
const Map<SimulationType, String> simulationNames = {
  SimulationType.femurCut: 'Corte de Fémur',
  SimulationType.hipCut: 'Renderizado de Colon',
  SimulationType.kneeCut: 'Contacto Aguja con Tejido',
  SimulationType.suture: 'Sutura de Herida',
  SimulationType.injection: 'Aplicación de Inyección',
  SimulationType.lapToolControl: 'Control de Herramienta Laparoscópica',
  SimulationType.vesselHandling: 'Sujeción de Vaso Sanguíneo',
};

/// Avance de un alumno en una simulación concreta.
class SimulationProgress {
  final SimulationType type;

  /// Porcentaje de avance (0-100).
  final double percent;

  /// Si el alumno completó la simulación.
  final bool completed;

  /// Última vez que el alumno trabajó en esta simulación.
  final DateTime? date;

  /// URLs de capturas de pantalla de la actividad del alumno.
  final List<String> screenshots;

  /// Comentarios de retroalimentación que el profesor deja sobre esta
  /// actividad. Lista mutable para poder agregar comentarios en tiempo real.
  final List<TeacherComment> comments;

  SimulationProgress({
    required this.type,
    required this.percent,
    this.completed = false,
    this.date,
    this.screenshots = const [],
    List<TeacherComment>? comments,
  }) : comments = comments ?? [];
}
