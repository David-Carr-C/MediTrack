import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:medi_track/models/student.dart';
import 'package:medi_track/services/mock_data.dart';

/// Ajustes del profesor: datos de perfil editables y alta de alumnos.
class SettingsTecherScreen extends StatefulWidget {
  const SettingsTecherScreen({super.key});
  @override
  State<SettingsTecherScreen> createState() => _SettingsTecherScreenState();
}

class _SettingsTecherScreenState extends State<SettingsTecherScreen> {
  // --- Card de perfil ---
  bool _editingProfile = false;
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _correoCtrl;
  late final TextEditingController _areaCtrl;
  String? _profileError;

  // --- Card de alta de alumno ---
  final _nuevoNombreCtrl = TextEditingController();
  final _nuevaMatriculaCtrl = TextEditingController();
  final _nuevoCorreoCtrl = TextEditingController();
  final _nuevaCarreraCtrl = TextEditingController();
  final _nuevoCicloCtrl = TextEditingController();
  String? _registerError;
  String? _registerSuccess;

  @override
  void initState() {
    super.initState();
    final t = MockData.teacherProfile;
    _nombreCtrl = TextEditingController(text: t.nombre);
    _correoCtrl = TextEditingController(text: t.correo);
    _areaCtrl = TextEditingController(text: t.area);
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _areaCtrl.dispose();
    _nuevoNombreCtrl.dispose();
    _nuevaMatriculaCtrl.dispose();
    _nuevoCorreoCtrl.dispose();
    _nuevaCarreraCtrl.dispose();
    _nuevoCicloCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return fluent.ScaffoldPage(
      header: const fluent.PageHeader(title: Text('Ajustes')),
      content: fluent.Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ListView(
          children: [
            _buildProfileCard(),
            const SizedBox(height: 20),
            _buildRegisterStudentCard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Card 1: información del profesor
  // ---------------------------------------------------------------------

  Widget _buildProfileCard() {
    return fluent.Card(
      padding: const EdgeInsets.all(20),
      child: fluent.Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          fluent.Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mi información',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (!_editingProfile)
                fluent.Button(
                  onPressed: () => setState(() => _editingProfile = true),
                  child: const fluent.Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(fluent.FluentIcons.edit, size: 14),
                      SizedBox(width: 6),
                      Text('Editar'),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_editingProfile) ..._buildProfileEditFields() else ..._buildProfileReadOnlyFields(),
          if (_profileError != null) ...[
            const SizedBox(height: 12),
            fluent.InfoBar(
              title: const Text('Error'),
              content: Text(_profileError!),
              severity: fluent.InfoBarSeverity.error,
              onClose: () => setState(() => _profileError = null),
            ),
          ],
          if (_editingProfile) ...[
            const SizedBox(height: 16),
            fluent.Row(
              children: [
                fluent.FilledButton(
                  onPressed: _saveProfile,
                  child: const Text('Guardar'),
                ),
                const SizedBox(width: 12),
                fluent.Button(
                  onPressed: _cancelProfileEdit,
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildProfileReadOnlyFields() {
    final t = MockData.teacherProfile;
    return [
      _infoRow('Nombre', t.nombre),
      _infoRow('Correo', t.correo),
      _infoRow('Área', t.area),
    ];
  }

  List<Widget> _buildProfileEditFields() {
    return [
      fluent.InfoLabel(
        label: 'Nombre',
        child: fluent.TextBox(controller: _nombreCtrl),
      ),
      const SizedBox(height: 12),
      fluent.InfoLabel(
        label: 'Correo',
        child: fluent.TextBox(controller: _correoCtrl),
      ),
      const SizedBox(height: 12),
      fluent.InfoLabel(
        label: 'Área',
        child: fluent.TextBox(controller: _areaCtrl),
      ),
    ];
  }

  void _cancelProfileEdit() {
    final t = MockData.teacherProfile;
    setState(() {
      _nombreCtrl.text = t.nombre;
      _correoCtrl.text = t.correo;
      _areaCtrl.text = t.area;
      _editingProfile = false;
      _profileError = null;
    });
  }

  void _saveProfile() {
    final nombre = _nombreCtrl.text.trim();
    final correo = _correoCtrl.text.trim();
    final area = _areaCtrl.text.trim();
    if (nombre.isEmpty || correo.isEmpty || area.isEmpty) {
      setState(() => _profileError = 'Todos los campos son obligatorios.');
      return;
    }
    if (!correo.contains('@')) {
      setState(() => _profileError = 'Ingresa un correo válido.');
      return;
    }
    setState(() {
      MockData.teacherProfile = MockData.teacherProfile.copyWith(
        nombre: nombre,
        correo: correo,
        area: area,
      );
      _editingProfile = false;
      _profileError = null;
    });
  }

  // ---------------------------------------------------------------------
  // Card 2: alta de alumno + listado de alumnos registrados
  // ---------------------------------------------------------------------

  Widget _buildRegisterStudentCard() {
    return fluent.Card(
      padding: const EdgeInsets.all(20),
      child: fluent.Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Registrar nuevo alumno',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          fluent.InfoLabel(
            label: 'Nombre',
            child: fluent.TextBox(
              controller: _nuevoNombreCtrl,
              placeholder: 'Ej. Juan Pérez López',
            ),
          ),
          const SizedBox(height: 12),
          fluent.InfoLabel(
            label: 'Matrícula',
            child: fluent.TextBox(
              controller: _nuevaMatriculaCtrl,
              placeholder: 'Ej. 202399001',
            ),
          ),
          const SizedBox(height: 12),
          fluent.InfoLabel(
            label: 'Correo',
            child: fluent.TextBox(
              controller: _nuevoCorreoCtrl,
              placeholder: 'Ej. juan.perez@alumno.buap.mx',
            ),
          ),
          const SizedBox(height: 12),
          fluent.InfoLabel(
            label: 'Área o carrera',
            child: fluent.TextBox(
              controller: _nuevaCarreraCtrl,
              placeholder: 'Ej. Ingeniería Biomédica',
            ),
          ),
          const SizedBox(height: 12),
          fluent.InfoLabel(
            label: 'Ciclo escolar',
            child: fluent.TextBox(
              controller: _nuevoCicloCtrl,
              placeholder: 'Ej. Agosto 2025 - Enero 2026',
            ),
          ),
          if (_registerError != null) ...[
            const SizedBox(height: 12),
            fluent.InfoBar(
              title: const Text('Error'),
              content: Text(_registerError!),
              severity: fluent.InfoBarSeverity.error,
              onClose: () => setState(() => _registerError = null),
            ),
          ],
          if (_registerSuccess != null) ...[
            const SizedBox(height: 12),
            fluent.InfoBar(
              title: const Text('Éxito'),
              content: Text(_registerSuccess!),
              severity: fluent.InfoBarSeverity.success,
              onClose: () => setState(() => _registerSuccess = null),
            ),
          ],
          const SizedBox(height: 16),
          fluent.FilledButton(
            onPressed: _registerStudent,
            child: const Text('Registrar alumno'),
          ),
          const SizedBox(height: 24),
          const fluent.Divider(),
          const SizedBox(height: 16),
          Text(
            'Alumnos registrados (${MockData.students.length})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: MockData.students.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) =>
                _buildStudentTile(MockData.students[index]),
          ),
        ],
      ),
    );
  }

  void _registerStudent() {
    final nombre = _nuevoNombreCtrl.text.trim();
    final matricula = _nuevaMatriculaCtrl.text.trim();
    final correo = _nuevoCorreoCtrl.text.trim();
    final carrera = _nuevaCarreraCtrl.text.trim();
    final ciclo = _nuevoCicloCtrl.text.trim();

    if ([nombre, matricula, correo, carrera, ciclo].any((s) => s.isEmpty)) {
      setState(() {
        _registerError = 'Todos los campos son obligatorios.';
        _registerSuccess = null;
      });
      return;
    }
    if (!correo.contains('@')) {
      setState(() {
        _registerError = 'Ingresa un correo válido.';
        _registerSuccess = null;
      });
      return;
    }
    final yaExiste = MockData.students.any((s) => s.matricula == matricula);
    if (yaExiste) {
      setState(() {
        _registerError = 'Ya existe un alumno con esa matrícula.';
        _registerSuccess = null;
      });
      return;
    }

    setState(() {
      MockData.students.add(
        Student(
          matricula: matricula,
          nombre: nombre,
          apellidoPaterno: '',
          apellidoMaterno: '',
          fechaNacimiento: '',
          carrera: carrera,
          semestre: ciclo,
          email: correo,
        ),
      );
      _registerError = null;
      _registerSuccess = 'Alumno registrado correctamente.';
      _nuevoNombreCtrl.clear();
      _nuevaMatriculaCtrl.clear();
      _nuevoCorreoCtrl.clear();
      _nuevaCarreraCtrl.clear();
      _nuevoCicloCtrl.clear();
    });
  }

  Widget _buildStudentTile(Student student) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            child: Icon(fluent.FluentIcons.contact, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.nombreCompleto,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '${student.matricula} · ${student.carrera}',
                  style: const TextStyle(fontSize: 12),
                ),
                if (student.email.isNotEmpty)
                  Text(
                    student.email,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ),
          if (student.semestre.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(student.semestre, style: const TextStyle(fontSize: 12)),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return fluent.Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: fluent.Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }
}
