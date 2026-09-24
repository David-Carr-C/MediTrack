import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:medi_track/models/simulation.dart';
import 'package:medi_track/models/student.dart';
import 'package:medi_track/services/mock_data.dart';
import 'package:medi_track/services/simulation_runner.dart';

enum _Stage { selectParticipants, selectSimulation, running, summary }

const int _minParticipants = 1;
const int _maxParticipants = 5;

class SimulationScreen extends fluent.StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends fluent.State<SimulationScreen> {
  _Stage _stage = _Stage.selectParticipants;

  final List<Student> _participants = [];
  SimulationType? _selectedType;
  int _turnIndex = 0;
  double _progress = 0.0;
  bool _usingMock = true;
  String? _error;

  SimulationProgressSource? _source;

  /// Avance guardado por cada participante en esta sesión (matrícula -> %).
  final Map<String, double> _recorded = {};

  @override
  void dispose() {
    _source?.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------
  // Selección de participantes
  // ---------------------------------------------------------------------

  void _toggleParticipant(Student student, bool? checked) {
    setState(() {
      if (checked == true) {
        if (_participants.length < _maxParticipants) {
          _participants.add(student);
        }
      } else {
        _participants.remove(student);
      }
    });
  }

  bool get _canContinueParticipants =>
      _participants.length >= _minParticipants &&
      _participants.length <= _maxParticipants;

  Widget _buildParticipantSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Participantes de la sesión',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Selecciona entre $_minParticipants y $_maxParticipants alumnos '
          '(llevas ${_participants.length}). Se turnarán en la misma corrida.',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: MockData.students.length,
          separatorBuilder: (_, __) => const SizedBox(height: 4),
          itemBuilder: (context, index) {
            final student = MockData.students[index];
            final checked = _participants.contains(student);
            final disabled =
                !checked && _participants.length >= _maxParticipants;
            return fluent.Checkbox(
              checked: checked,
              onChanged:
                  disabled ? null : (v) => _toggleParticipant(student, v),
              content: Text('${student.nombreCompleto} · ${student.matricula}'),
            );
          },
        ),
        const SizedBox(height: 20),
        fluent.FilledButton(
          onPressed:
              _canContinueParticipants
                  ? () => setState(() => _stage = _Stage.selectSimulation)
                  : null,
          child: const Text('Continuar'),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Selección de simulación
  // ---------------------------------------------------------------------

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
                  onPressed: () => _startSession(type),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulationSelector() {
    final Map<SimulationType, String> simulationImages = {
      SimulationType.femurCut: 'assets/image_femur.png',
      SimulationType.hipCut: 'assets/image_colon.png',
      SimulationType.kneeCut: 'assets/image_tejido.png',
      SimulationType.suture: 'assets/image_suture.png',
      SimulationType.injection: 'assets/image_injection.png',
      SimulationType.lapToolControl: 'assets/image_lap_tool.png',
      SimulationType.vesselHandling: 'assets/image_vessel.png',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        fluent.Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Seleccione una simulación:'),
            fluent.Button(
              onPressed:
                  () => setState(() => _stage = _Stage.selectParticipants),
              child: const Text('Cambiar participantes'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Participantes: ${_participants.map((s) => s.nombre).join(', ')}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
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

  // ---------------------------------------------------------------------
  // Sesión en curso (turnos)
  // ---------------------------------------------------------------------

  void _startSession(SimulationType type) {
    setState(() {
      _selectedType = type;
      _turnIndex = 0;
      _progress = 0.0;
      _recorded.clear();
      _error = null;
      _stage = _Stage.running;
    });
    _launchSource(type);
  }

  void _launchSource(SimulationType type) {
    final exePath = SimulationEngineConfig.executables[type];
    final logPath = SimulationEngineConfig.logPaths[type];
    final hasNativeEngine =
        exePath != null && logPath != null && File(exePath).existsSync();

    _usingMock = !hasNativeEngine;

    _source =
        hasNativeEngine
            ? NativeProgressSource(
              executablePath: exePath,
              logPath: logPath,
              onProgress: _onProgress,
              onFinished: _onSourceFinished,
              onError: _onSourceError,
            )
            : MockProgressSource(
              onProgress: _onProgress,
              onFinished: _onSourceFinished,
              onError: _onSourceError,
            );
    _source!.start();
  }

  void _onProgress(double percent) {
    if (!mounted) return;
    setState(() => _progress = percent);
  }

  void _onSourceFinished() {
    if (!mounted) return;
    // La corrida llegó a 100%: se guarda automáticamente el turno actual.
    _endCurrentTurn(autoFinished: true);
  }

  void _onSourceError(Object error) {
    if (!mounted) return;
    _source?.dispose();
    setState(() {
      _error = 'No se pudo iniciar el motor de simulación: $error';
      _stage = _Stage.selectSimulation;
    });
  }

  Student get _currentStudent => _participants[_turnIndex];

  void _endCurrentTurn({bool autoFinished = false}) {
    final student = _currentStudent;
    MockData.recordProgress(student, _selectedType!, _progress);

    final isLastTurn = _turnIndex >= _participants.length - 1;
    setState(() {
      _recorded[student.matricula] = _progress;
      if (isLastTurn || autoFinished) {
        _source?.dispose();
        _stage = _Stage.summary;
      } else {
        _turnIndex++;
      }
    });
  }

  void _cancelSession() {
    _source?.dispose();
    setState(() {
      _stage = _Stage.selectSimulation;
    });
  }

  Widget _buildRunningView() {
    final nombre = simulationNames[_selectedType]!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '$nombre: ${_progress.toStringAsFixed(1)}%',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Turno ${_turnIndex + 1} de ${_participants.length}: '
          '${_currentStudent.nombreCompleto}',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 20),
        fluent.ProgressRing(value: _progress, strokeWidth: 8.0),
        const SizedBox(height: 20),
        if (_usingMock) ...[
          fluent.InfoBar(
            title: const Text('Modo demostración'),
            content: const Text(
              'No se encontró el motor de simulación instalado; se está '
              'usando un progreso simulado.',
            ),
            severity: fluent.InfoBarSeverity.warning,
            isLong: true,
          ),
          const SizedBox(height: 16),
        ],
        fluent.Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            fluent.FilledButton(
              onPressed: () => _endCurrentTurn(),
              child: Text(
                _turnIndex >= _participants.length - 1
                    ? 'Finalizar turno y sesión'
                    : 'Finalizar turno y guardar avance',
              ),
            ),
            const SizedBox(width: 12),
            fluent.Button(
              onPressed: _cancelSession,
              child: const Text('Cancelar sesión'),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Resumen de la sesión
  // ---------------------------------------------------------------------

  Widget _buildSummary() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sesión de ${simulationNames[_selectedType]} finalizada',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ..._participants.map((student) {
          final percent = _recorded[student.matricula];
          return fluent.Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: fluent.Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(student.nombreCompleto),
                Text(
                  percent != null
                      ? '${percent.toStringAsFixed(0)}% guardado'
                      : 'Sin turno',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 20),
        fluent.FilledButton(
          onPressed: () {
            setState(() {
              _participants.clear();
              _recorded.clear();
              _selectedType = null;
              _stage = _Stage.selectParticipants;
            });
          },
          child: const Text('Nueva sesión'),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------

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
              child: SingleChildScrollView(child: _buildStage()),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStage() {
    if (_error != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          fluent.InfoBar(
            title: const Text('Error'),
            content: Text(_error!),
            severity: fluent.InfoBarSeverity.error,
            onClose: () => setState(() => _error = null),
          ),
          const SizedBox(height: 16),
          _buildStageContent(),
        ],
      );
    }
    return _buildStageContent();
  }

  Widget _buildStageContent() {
    switch (_stage) {
      case _Stage.selectParticipants:
        return _buildParticipantSelector();
      case _Stage.selectSimulation:
        return _buildSimulationSelector();
      case _Stage.running:
        return _buildRunningView();
      case _Stage.summary:
        return _buildSummary();
    }
  }
}
