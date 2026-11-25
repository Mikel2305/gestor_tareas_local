import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_tareas_local/main.dart';
import 'package:gestor_tareas_local/data/app_database.dart';
import 'package:drift/native.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(
      NativeDatabase.memory(),
    );
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('La pantalla inicial se muestra sin errores', (tester) async {
    await tester.pumpWidget(
      GestorTareasApp(database: database),
    );

    await tester.pumpAndSettle();

    expect(find.text('Gestor de tareas'), findsOneWidget);
    expect(find.text('Agregar tarea'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Todavia no hay tareas guardadas'), findsOneWidget);

    // DESMONTAR LA PANTALLA Y CANCELAR EL STREAM
    await tester.pumpWidget(const SizedBox.shrink());

    // AVANZAR EL RELOJ PARA PROCESAR LA LIMPIEZA DE DRIFT
    await tester.pump(const Duration(milliseconds: 1));
  });


  testWidgets('No permite agregar tareas con espacios', (tester) async {
    await tester.pumpWidget(
      GestorTareasApp(database: database),
    );

    await tester.enterText(
      find.byType(TextField),
      '   ',
    );

    await tester.tap(find.text('Agregar tarea'));
    await tester.pump();

    expect(
      find.text('Escribe un titulo para la tarea'),
      findsOneWidget,
    );

    final tareas = await database.select(database.tareas).get();

    expect(tareas, isEmpty);

    // DESMONTAR LA PANTALLA Y PROCESAR LA LIMPIEZA DE DRIFT
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });


}
