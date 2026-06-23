import 'dart:async';
import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:medi_track/models/simulation.dart';

class SimulationScreen extends fluent.StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends fluent.State<SimulationScreen> {
  SimulationType? currentSimulation;
  bool isSimulating = false;
  double progress = 0.0;
  Timer? _logTimer;
  Process? _simulationProcess;
  int _pid = 0;

  // Rutas de logs para cada simulación
  final Map<SimulationType, String> logPaths = {
    SimulationType.femurCut:
        '/home/david-carrillo/Documentos/.BUAP/medi_track/FemurObject.log',
    SimulationType.hipCut:
        '/home/david-carrillo/Documentos/.BUAP/medi_track/FemurObject.log',
    SimulationType.kneeCut:
        '/home/david-carrillo/Documentos/.BUAP/medi_track/FemurObject.log',
  };

  // Ejecutables para cada simulación
  final Map<SimulationType, String> executables = {
    SimulationType.femurCut:
        '/home/david-carrillo/Documentos/.BUAP/build/Innerbuild/Examples/FemurCut/Example-FemurCut',
    SimulationType.hipCut:
        '/home/david-carrillo/Documentos/.BUAP/build/Innerbuild/Examples/RenderingColon/Example-RenderingColon',
    SimulationType.kneeCut:
        '/home/david-carrillo/Documentos/.BUAP/build/Innerbuild/Examples/PBD/PBDTissueVolumeNeedleContact/Example-PBDTissueVolumeNeedleContact',
  };

  void _startSimulation(SimulationType type) async {
    setState(() {
      currentSimulation = type;
      isSimulating = true;
      progress = 0.0;
    });

    // Limpiar el archivo de log
    final logFile = File(logPaths[type]!);
    if (logFile.existsSync()) {
      logFile.writeAsStringSync('');
    }

    // Iniciar el proceso de simulación
    try {
      _simulationProcess = await Process.start(executables[type]!, [])
          .then((process) {
            _pid = process.pid;
          })
          .catchError((error) {
            setState(() {
              isSimulating = false;
            });
          });

      // Iniciar lectura de logs
      _startLogReader(type);
    } catch (error) {
      print('Error starting simulation: $error');
      setState(() => isSimulating = false);
    }
  }

  void _startLogReader(SimulationType type) {
    _logTimer?.cancel();
    _logTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _readLogFile(type);
    });
  }

  void _readLogFile(SimulationType type) {
    try {
      final file = File(logPaths[type]!);
      if (!file.existsSync()) return;

      final lines = file.readAsLinesSync();
      if (lines.isEmpty) return;

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
      final newProgress = (value / 300) * 100;

      setState(() {
        progress = newProgress.clamp(0.0, 100.0);
      });

      if (progress >= 100.0) {
        _stopSimulation();
      }
    } catch (e) {
      print('Error reading log: $e');
    }
  }

  void _stopSimulation() {
    if (_simulationProcess != null) {
      _simulationProcess!.kill();
      _simulationProcess = null;
    }

    if (_pid != 0) {
      Process.killPid(_pid);
      _pid = 0;
    }

    _logTimer?.cancel();
    _logTimer = null;

    setState(() {
      isSimulating = false;
      currentSimulation = null;
    });
  }

  @override
  void dispose() {
    _stopSimulation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return fluent.ScaffoldPage(
      content: fluent.Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
        child: fluent.Center(
          child: fluent.Card(
            backgroundColor: const Color(0xFFEFEBE9),
            child: fluent.Padding(
              padding: const EdgeInsets.all(20),
              child:
                  !isSimulating
                      ? _buildSimulationSelector()
                      : _buildProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimulationCard(SimulationType type, String imagePath) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.image_not_supported_outlined),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  simulationNames[type]!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                fluent.FilledButton(
                  child: const Text('Iniciar'),
                  onPressed: () => _startSimulation(type),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulationSelector() {
    // Map de imágenes de ejemplo (reemplazar con tus rutas reales)
    final Map<SimulationType, String> simulationImages = {
      SimulationType.femurCut: 'assets/image_femur.png',
      SimulationType.hipCut: 'assets/image_colon.png',
      SimulationType.kneeCut: 'assets/image_tejido.png',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Seleccione una simulación:'),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 0.8,
          children:
              SimulationType.values.map((type) {
                return _buildSimulationCard(type, simulationImages[type]!);
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return fluent.Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '${simulationNames[currentSimulation]!}: ${progress.toStringAsFixed(1)}%',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        fluent.ProgressRing(value: progress, strokeWidth: 8.0),
        const SizedBox(height: 20),
        fluent.Button(
          onPressed: _stopSimulation,
          child: const Text('Detener Simulación'),
        ),
      ],
    );
  }
}
