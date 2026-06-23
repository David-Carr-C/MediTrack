import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:medi_track/models/student.dart';
import 'package:medi_track/screens/student_detail_screen.dart';
import 'package:medi_track/services/mock_data.dart';

/// Módulo del profesor: lista de alumnos y su avance. Solo lectura.
/// Al seleccionar un alumno muestra su detalle.
class TeacherScreen extends StatefulWidget {
  const TeacherScreen({super.key});

  @override
  State<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  Student? _selected;

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    if (selected != null) {
      return StudentDetailScreen(
        student: selected,
        onBack: () => setState(() => _selected = null),
      );
    }

    final students = MockData.students;
    return fluent.ScaffoldPage(
      header: const fluent.PageHeader(title: Text('Avance de los alumnos')),
      content: fluent.Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ListView.separated(
          itemCount: students.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _buildStudentCard(students[index]),
        ),
      ),
    );
  }

  Widget _buildStudentCard(Student student) {
    return fluent.Card(
      padding: const EdgeInsets.all(16),
      child: fluent.Row(
        children: [
          const fluent.CircleAvatar(
            radius: 24,
            child: Icon(fluent.FluentIcons.contact),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: fluent.Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.nombreCompleto,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text('${student.matricula} · ${student.carrera}'),
                const SizedBox(height: 8),
                fluent.ProgressBar(value: student.avancePromedio),
                const SizedBox(height: 4),
                Text(
                  'Avance promedio: ${student.avancePromedio.toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          fluent.Button(
            onPressed: () => setState(() => _selected = student),
            child: const Text('Ver detalle'),
          ),
        ],
      ),
    );
  }
}
