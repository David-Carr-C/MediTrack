import 'dart:async';
import 'dart:io';

import 'package:medi_track/models/simulation.dart';

/// Fuente de progreso de una simulación en curso. Abstrae de dónde viene el
/// valor de avance (0-100), para poder alternar entre un generador simulado
/// y la lectura de un proceso/motor de simulación real sin tocar la UI.
abstract class SimulationProgressSource {
  final void Function(double percent) onProgress;
  final void Function() onFinished;
  final void Function(Object error) onError;

  SimulationProgressSource({
    required this.onProgress,
    required this.onFinished,
    required this.onError,
  });

  Future<void> start();
  void dispose();
}

/// Progreso simulado mediante un timer. Se usa mientras no hay un motor de
/// simulación real integrado (o si su ejecución falla).
class MockProgressSource extends SimulationProgressSource {
  MockProgressSource({
    required super.onProgress,
    required super.onFinished,
    required super.onError,
    this.duration = const Duration(seconds: 20),
  });

  /// Tiempo que tarda en llegar de 0% a 100%.
  final Duration duration;

  Timer? _timer;
  double _percent = 0;

  @override
  Future<void> start() async {
    const tick = Duration(milliseconds: 300);
    final incrementoPorTick = 100 / (duration.inMilliseconds / tick.inMilliseconds);
    _timer = Timer.periodic(tick, (timer) {
      _percent = (_percent + incrementoPorTick).clamp(0.0, 100.0);
      onProgress(_percent);
      if (_percent >= 100.0) {
        timer.cancel();
        onFinished();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

/// Progreso leído de un proceso nativo del motor de simulación (iMSTK), vía
/// un archivo de log que el ejecutable va escribiendo en tiempo real.
///
/// Formato de log esperado: líneas CSV donde la 2da columna es un valor
/// acumulado 0-300 (segundos de sesión); se traduce a porcentaje (/300*100).
class NativeProgressSource extends SimulationProgressSource {
  NativeProgressSource({
    required super.onProgress,
    required super.onFinished,
    required super.onError,
    required this.executablePath,
    required this.logPath,
  });

  final String executablePath;
  final String logPath;

  Timer? _logTimer;
  Process? _process;

  @override
  Future<void> start() async {
    final logFile = File(logPath);
    if (logFile.existsSync()) {
      logFile.writeAsStringSync('');
    }

    try {
      _process = await Process.start(executablePath, []);
    } catch (error) {
      onError(error);
      return;
    }

    _process!.exitCode.then((_) {
      _logTimer?.cancel();
    });

    _logTimer = Timer.periodic(const Duration(seconds: 1), (_) => _readLog());
  }

  void _readLog() {
    try {
      final file = File(logPath);
      if (!file.existsSync()) return;

      final lines = file.readAsLinesSync();
      String lastValidLine = '';
      for (var i = lines.length - 1; i >= 0; i--) {
        if (lines[i].contains(',') && lines[i].trim().isNotEmpty) {
          lastValidLine = lines[i];
          break;
        }
      }
      if (lastValidLine.isEmpty) return;

      final parts = lastValidLine.split(',');
      if (parts.length < 2) return;

      final value = double.tryParse(parts[1]) ?? 0.0;
      final percent = ((value / 300) * 100).clamp(0.0, 100.0);
      onProgress(percent);

      if (percent >= 100.0) {
        dispose();
        onFinished();
      }
    } catch (error) {
      onError(error);
    }
  }

  @override
  void dispose() {
    _logTimer?.cancel();
    _logTimer = null;
    _process?.kill();
    _process = null;
  }
}

/// Rutas del ejecutable y del log de cada simulación, cuando se usa
/// [NativeProgressSource]. Debe configurarse según la instalación local del
/// motor de simulación; si una ruta no existe, la pantalla usa el progreso
/// simulado como respaldo.
class SimulationEngineConfig {
  static const Map<SimulationType, String> executables = {};
  static const Map<SimulationType, String> logPaths = {};
}
