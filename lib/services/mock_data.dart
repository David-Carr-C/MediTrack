import 'package:medi_track/models/simulation.dart';
import 'package:medi_track/models/student.dart';
import 'package:medi_track/models/teacher.dart';

/// Datos de ejemplo (mock) usados mientras no hay backend.
class MockData {
  /// Perfil del profesor con sesión activa. Editable desde Ajustes.
  static Teacher teacherProfile = const Teacher(
    id: 'profesor',
    nombre: 'Dr. Profesor',
    correo: 'profesor@buap.mx',
    area: 'Ingeniería Biomédica',
  );

  /// Lista de alumnos con su avance en simulaciones.
  static final List<Student> students = [
    Student(
      matricula: '202084414',
      nombre: 'Irvin',
      apellidoPaterno: 'Gómez',
      apellidoMaterno: 'López',
      fechaNacimiento: '15/03/2003',
      carrera: 'Ingeniería en Sistemas',
      semestre: '6° Semestre',
      email: 'jake.gomez@alumno.buap.mx',
      avances: [
        SimulationProgress(
          type: SimulationType.femurCut,
          percent: 100,
          completed: true,
          date: DateTime(2025, 7, 28),
          screenshots: [
            'https://picsum.photos/seed/femur-irvin-1/640/400',
            'https://picsum.photos/seed/femur-irvin-2/640/400',
            'https://picsum.photos/seed/femur-irvin-3/640/400',
          ],
        ),
        SimulationProgress(
          type: SimulationType.hipCut,
          percent: 65,
          date: DateTime(2025, 8, 27),
          screenshots: [
            'https://picsum.photos/seed/colon-irvin-1/640/400',
            'https://picsum.photos/seed/colon-irvin-2/640/400',
          ],
        ),
        SimulationProgress(type: SimulationType.kneeCut, percent: 0),
      ],
    ),
    Student(
      matricula: '202156789',
      nombre: 'María',
      apellidoPaterno: 'Hernández',
      apellidoMaterno: 'Ruiz',
      fechaNacimiento: '02/11/2002',
      carrera: 'Ingeniería Biomédica',
      semestre: '8° Semestre',
      email: 'maria.hernandez@alumno.buap.mx',
      avances: [
        SimulationProgress(
          type: SimulationType.femurCut,
          percent: 100,
          completed: true,
          date: DateTime(2025, 6, 10),
          screenshots: [
            'https://picsum.photos/seed/femur-maria-1/640/400',
            'https://picsum.photos/seed/femur-maria-2/640/400',
          ],
        ),
        SimulationProgress(
          type: SimulationType.hipCut,
          percent: 100,
          completed: true,
          date: DateTime(2025, 7, 1),
          screenshots: [
            'https://picsum.photos/seed/colon-maria-1/640/400',
            'https://picsum.photos/seed/colon-maria-2/640/400',
            'https://picsum.photos/seed/colon-maria-3/640/400',
          ],
        ),
        SimulationProgress(
          type: SimulationType.kneeCut,
          percent: 40,
          date: DateTime(2025, 9, 5),
          screenshots: [
            'https://picsum.photos/seed/tejido-maria-1/640/400',
          ],
        ),
      ],
    ),
    Student(
      matricula: '202199001',
      nombre: 'Carlos',
      apellidoPaterno: 'Martínez',
      apellidoMaterno: 'Díaz',
      fechaNacimiento: '23/07/2003',
      carrera: 'Ingeniería en Sistemas',
      semestre: '4° Semestre',
      email: 'carlos.martinez@alumno.buap.mx',
      avances: [
        SimulationProgress(
          type: SimulationType.femurCut,
          percent: 30,
          date: DateTime(2025, 9, 12),
          screenshots: [
            'https://picsum.photos/seed/femur-carlos-1/640/400',
          ],
        ),
        SimulationProgress(type: SimulationType.hipCut, percent: 0),
        SimulationProgress(type: SimulationType.kneeCut, percent: 0),
      ],
    ),
  ];

  /// Devuelve el alumno con la matrícula dada, o el primero como respaldo.
  static Student studentByMatricula(String matricula) {
    return students.firstWhere(
      (s) => s.matricula == matricula,
      orElse: () => students.first,
    );
  }

  /// Registra el avance de [student] en la simulación [type]. Si ya existía
  /// un registro para esa simulación se actualiza (conservando comentarios
  /// y capturas previas y sin retroceder el porcentaje ya alcanzado);
  /// si no existía, se crea uno nuevo.
  static void recordProgress(
    Student student,
    SimulationType type,
    double percent,
  ) {
    final avances = student.avances;
    final index = avances.indexWhere((a) => a.type == type);
    final clamped = percent.clamp(0.0, 100.0);
    final now = DateTime.now();

    if (index == -1) {
      avances.add(
        SimulationProgress(
          type: type,
          percent: clamped,
          completed: clamped >= 100,
          date: now,
        ),
      );
      return;
    }

    final previo = avances[index];
    final nuevoPercent = clamped > previo.percent ? clamped : previo.percent;
    avances[index] = SimulationProgress(
      type: type,
      percent: nuevoPercent,
      completed: previo.completed || nuevoPercent >= 100,
      date: now,
      screenshots: previo.screenshots,
      comments: previo.comments,
    );
  }
}
