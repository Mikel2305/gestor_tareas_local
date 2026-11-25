import 'package:flutter_test/flutter_test.dart';
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

  test('Se puede agregar y consultar una tarea', () async {
    final id = await database.agregarTarea('Estudiar Flutter');

    final tareas = await database.select(database.tareas).get();

    expect(tareas.length, 1);
    expect(tareas.first.id, id);
    expect(tareas.first.titulo, 'Estudiar Flutter');
    expect(tareas.first.completada, false);
  });

  test('Se puede editar y completar una tarea', () async {
    final id = await database.agregarTarea('Hacer tarea');

    await database.editarTarea(id, 'Terminar practica');

    await database.cambiarEstado(id, true);

    final tareas = await database.select(database.tareas).get();

    expect(tareas.length, 1);
    expect(tareas.first.titulo, 'Terminar practica');
    expect(tareas.first.completada, true);
  });

  test('Se puede eliminar una tarea por su ID', () async {
    final id = await database.agregarTarea('Tarea temporal');

    final filasEliminadas = await database.eliminarTarea(id);

    final tareas = await database.select(database.tareas).get();

    expect(filasEliminadas, 1);
    expect(tareas, isEmpty);
  });
}
