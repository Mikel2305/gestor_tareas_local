import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

// Tabla donde se guardaran las tareas
@DataClassName('TareaDb')
class Tareas extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get titulo => text().withLength(min: 1, max: 200)();

  BoolColumn get completada => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Tareas])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_abrirConexion());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  // Consultar
  Stream<List<TareaDb>> observarTareas() {
    return (select(tareas)..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .watch();
  }

  // Insertar
  Future<int> agregarTarea(String titulo) {
    return into(tareas).insert(
      TareasCompanion.insert(titulo: titulo),
    );
  }

  
  // Cambiar estado
  Future<bool> cambiarEstado(int id, bool completada) async {
    final filasActualizadas =
        await (update(tareas)..where((t) => t.id.equals(id))).write(
      TareasCompanion(completada: Value(completada)),
    );

    return filasActualizadas > 0;
  }

  // Editar titulo
  Future<bool> editarTarea(int id, String nuevoTitulo) async {
    final filasActualizadas =
        await (update(tareas)..where((t) => t.id.equals(id))).write(
      TareasCompanion(titulo: Value(nuevoTitulo)),
    );

    return filasActualizadas > 0;
  }


  // Eliminar por id
  Future<int> eliminarTarea(int id) {
    return (delete(tareas)..where((t) => t.id.equals(id))).go();
  }
}

// Conexión
QueryExecutor _abrirConexion() {
  return driftDatabase(
    name: 'gestor_tareas_local',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}
