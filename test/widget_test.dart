// Smoke test del flujo de entrada de MediTrack.

import 'package:flutter_test/flutter_test.dart';

import 'package:medi_track/main.dart';

void main() {
  testWidgets('Arranca en el selector de rol', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // La pantalla inicial ofrece elegir entre Alumno y Profesor.
    expect(find.text('Alumno'), findsOneWidget);
    expect(find.text('Profesor'), findsOneWidget);
  });
}
