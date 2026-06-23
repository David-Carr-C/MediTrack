import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:medi_track/models/user_role.dart';

/// Pantalla inicial donde se elige el rol (Alumno / Profesor).
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key, required this.onRoleSelected});

  /// Notifica el rol elegido a la raíz de la app.
  final ValueChanged<UserRole> onRoleSelected;

  @override
  Widget build(BuildContext context) {
    return fluent.ScaffoldPage(
      content: fluent.Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: fluent.Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'MediTrack',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Seleccione cómo desea ingresar'),
              const SizedBox(height: 32),
              fluent.Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _RoleCard(
                    icon: fluent.FluentIcons.education,
                    title: 'Alumno',
                    description: 'Ver y ejecutar simulaciones',
                    onPressed: () => onRoleSelected(UserRole.student),
                  ),
                  const SizedBox(width: 24),
                  _RoleCard(
                    icon: fluent.FluentIcons.people,
                    title: 'Profesor',
                    description: 'Ver el avance de los alumnos',
                    onPressed: () => onRoleSelected(UserRole.teacher),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: fluent.Card(
        child: fluent.Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(description, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            fluent.FilledButton(
              onPressed: onPressed,
              child: const Text('Ingresar'),
            ),
          ],
        ),
      ),
    );
  }
}
