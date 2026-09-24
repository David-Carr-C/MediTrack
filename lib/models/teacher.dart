/// Datos de perfil de un profesor.
class Teacher {
  final String id;
  final String nombre;
  final String correo;
  final String area;

  const Teacher({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.area,
  });

  Teacher copyWith({String? nombre, String? correo, String? area}) {
    return Teacher(
      id: id,
      nombre: nombre ?? this.nombre,
      correo: correo ?? this.correo,
      area: area ?? this.area,
    );
  }
}
