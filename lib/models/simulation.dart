/// Tipos de simulación disponibles.
enum SimulationType { femurCut, hipCut, kneeCut }

/// Nombres amigables (en español) para cada simulación.
const Map<SimulationType, String> simulationNames = {
  SimulationType.femurCut: 'Corte de Fémur',
  SimulationType.hipCut: 'Renderizado de Colon',
  SimulationType.kneeCut: 'Contacto Aguja con Tejido',
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

  const SimulationProgress({
    required this.type,
    required this.percent,
    this.completed = false,
    this.date,
    this.screenshots = const [],
  });
}
