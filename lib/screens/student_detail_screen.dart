import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:medi_track/models/simulation.dart';
import 'package:medi_track/models/student.dart';
import 'package:medi_track/models/teacher_comment.dart';

/// Detalle de un alumno con su avance por simulación. El profesor puede
/// dejar comentarios de retroalimentación por cada actividad.
class StudentDetailScreen extends StatefulWidget {
  const StudentDetailScreen({
    super.key,
    required this.student,
    required this.onBack,
  });

  final Student student;
  final VoidCallback onBack;

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  Student get student => widget.student;
  VoidCallback get onBack => widget.onBack;

  @override
  Widget build(BuildContext context) {
    return fluent.ScaffoldPage(
      header: fluent.PageHeader(
        title: Text(student.nombreCompleto),
        leading: fluent.IconButton(
          icon: const Icon(fluent.FluentIcons.back),
          onPressed: onBack,
        ),
      ),
      content: fluent.Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ListView(
          children: [
            fluent.Card(
              child: fluent.Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow('Matrícula', student.matricula),
                  _infoRow('Carrera', student.carrera),
                  _infoRow('Semestre', student.semestre),
                  _infoRow('Fecha de Nac.', student.fechaNacimiento),
                  _infoRow('Email', student.email),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Avance en simulaciones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...student.avances.map(_buildProgressCard),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(SimulationProgress avance) {
    final nombre = simulationNames[avance.type] ?? avance.type.name;
    return fluent.Card(
      padding: const EdgeInsets.all(16),
      child: fluent.Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          fluent.Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
              Row(
                children: [
                  if (avance.completed)
                    const Icon(
                      fluent.FluentIcons.completed,
                      color: Colors.green,
                      size: 16,
                    ),
                  const SizedBox(width: 6),
                  Text('${avance.percent.toStringAsFixed(0)}%'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          fluent.ProgressBar(value: avance.percent),
          if (avance.date != null) ...[
            const SizedBox(height: 8),
            Text(
              'Última actividad: ${_formatDate(avance.date!)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
          if (avance.screenshots.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Capturas de la actividad',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _buildGallery(avance.screenshots),
          ],
          const SizedBox(height: 12),
          const fluent.Divider(),
          const SizedBox(height: 8),
          _buildCommentsSection(avance),
        ],
      ),
    );
  }

  Widget _buildCommentsSection(SimulationProgress avance) {
    return fluent.Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        fluent.Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Retroalimentación',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            fluent.Button(
              onPressed: () => _showAddCommentDialog(avance),
              child: const fluent.Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(fluent.FluentIcons.comment_add, size: 14),
                  SizedBox(width: 6),
                  Text('Agregar comentario'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (avance.comments.isEmpty)
          const Text(
            'Aún no hay comentarios para esta actividad.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          )
        else
          fluent.Column(
            children: avance.comments
                .map((c) => _buildCommentTile(c))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildCommentTile(TeacherComment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
      ),
      width: double.infinity,
      child: fluent.Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(comment.texto, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            _formatDateTime(comment.fecha),
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showAddCommentDialog(SimulationProgress avance) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => fluent.ContentDialog(
        title: const Text('Agregar comentario'),
        constraints: const BoxConstraints(maxWidth: 480),
        content: fluent.TextBox(
          controller: controller,
          placeholder: 'Escribe tu retroalimentación para el alumno...',
          maxLines: 5,
          autofocus: true,
        ),
        actions: [
          fluent.Button(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          fluent.FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              setState(() {
                avance.comments.add(
                  TeacherComment(texto: text, fecha: DateTime.now()),
                );
              });
              Navigator.of(context).pop();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Widget _buildGallery(List<String> urls) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) => _buildThumbnail(context, urls[index]),
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context, String url) {
    return GestureDetector(
      onTap: () => _openFullImage(context, url),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          url,
          width: 176,
          height: 110,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return _placeholder(
              const fluent.ProgressRing(),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _placeholder(
              const Icon(fluent.FluentIcons.photo_error, size: 24),
            );
          },
        ),
      ),
    );
  }

  Widget _placeholder(Widget child) {
    return Container(
      width: 176,
      height: 110,
      color: Colors.grey[200],
      alignment: Alignment.center,
      child: child,
    );
  }

  void _openFullImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => fluent.ContentDialog(
        constraints: const BoxConstraints(maxWidth: 720),
        content: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.network(
            url,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return _placeholder(const fluent.ProgressRing());
            },
            errorBuilder: (context, error, stackTrace) => _placeholder(
              const Icon(fluent.FluentIcons.photo_error, size: 24),
            ),
          ),
        ),
        actions: [
          fluent.Button(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _formatDateTime(DateTime d) =>
      '${_formatDate(d)} ${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}';

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
