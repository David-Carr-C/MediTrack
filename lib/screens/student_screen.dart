import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:medi_track/services/graphql.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final String matricula = '202084414';
  final String nombre = 'Irvin';
  final String apellidoPaterno = 'Gómez';
  final String apellidoMaterno = 'López';
  final String fechaNacimiento = '15/03/2003';
  final String carrera = 'Ingeniería en Sistemas';
  final String semestre = '6° Semestre';
  final String email = 'jake.gomez@alumno.buap.mx';

  @override
  Widget build(BuildContext context) {
    return fluent.ScaffoldPage(
      content: fluent.Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
        child: fluent.Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            fluent.Card(
              backgroundColor: Color(0xFFEFEBE9),
              child: fluent.Padding(
                padding: const EdgeInsets.all(20),
                child: fluent.Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    fluent.Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        fluent.CircleAvatar(
                          radius: 36,
                          foregroundImage: const AssetImage(
                            'assets/avatar.png',
                          ),
                          child: const Icon(fluent.FluentIcons.contact),
                        ),
                        const SizedBox(width: 16),
                        fluent.Text('$nombre $apellidoPaterno'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const fluent.Divider(),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 500;
                        return isWide
                            ? fluent.Row(
                              children: [
                                _buildInfoColumn(),
                                const SizedBox(width: 40),
                                _buildContactColumn(),
                              ],
                            )
                            : fluent.Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoColumn(),
                                const SizedBox(height: 20),
                                _buildContactColumn(),
                              ],
                            );
                      },
                    ),
                    const SizedBox(height: 20),
                    // Botones de acción
                    fluent.Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        fluent.Button(
                          child: const Text('Editar Perfil'),
                          onPressed: () async {
                            // Acción editar perfil
                            // String graphqlQuery = '''
                            // {
                            //   testCollection {
                            //     edges {
                            //       node {
                            //         id
                            //         test
                            //         nuevo
                            //         modificar
                            //       }
                            //     }
                            //   }
                            // }
                            // ''';

                            // var response = await GraphQLService.query(
                            //   graphqlQuery,
                            // );

                            // if (response[1].containsKey('message')) {
                            //   // ! Error
                            //   SnackBar(
                            //     content: fluent.Text(
                            //       response[1]['message'] ?? 'Error desconocido',
                            //     ),
                            //     backgroundColor: fluent.Colors.red,
                            //   );
                            // }

                            // // ! Exito
                            // print(response);
                          },
                        ),
                        const SizedBox(width: 12),
                        fluent.Button(
                          style: fluent.ButtonStyle(),
                          child: const Text('Cerrar Sesión'),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Columna con datos académicos
  fluent.Widget _buildInfoColumn() {
    return fluent.Column(
      crossAxisAlignment: fluent.CrossAxisAlignment.start,
      children: [
        _infoRow('Matrícula', matricula),
        _infoRow('Carrera', carrera),
        _infoRow('Semestre', semestre),
      ],
    );
  }

  // Columna con datos personales/contacto
  fluent.Widget _buildContactColumn() {
    return fluent.Column(
      crossAxisAlignment: fluent.CrossAxisAlignment.start,
      children: [
        _infoRow('Fecha de Nac.', fechaNacimiento),
        _infoRow('Email', email),
      ],
    );
  }

  // Fila genérica para etiqueta + valor
  fluent.Widget _infoRow(String label, String value) {
    return fluent.Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: fluent.Row(
        children: [
          fluent.Text(
            '$label:',
            style: fluent.TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          fluent.Text(value),
        ],
      ),
    );
  }
}
