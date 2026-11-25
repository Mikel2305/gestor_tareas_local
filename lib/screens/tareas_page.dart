import 'package:flutter/material.dart';
import '../data/app_database.dart';
import '../models/tarea.dart';

class TareasPage extends StatefulWidget {
  final AppDatabase database;

  const TareasPage({
    super.key,
    required this.database,
  });

  @override
  State<TareasPage> createState() => _TareasPageState();
}

class _TareasPageState extends State<TareasPage> {
  final TextEditingController _tituloController =
      TextEditingController();

  // AGREGAR UNA TAREA
  Future<void> _agregarTarea() async {
    final titulo = _tituloController.text.trim();

    if (titulo.isEmpty) {
      _mostrarMensaje('Escribe un titulo para la tarea');
      return;
    }

    await widget.database.agregarTarea(titulo);

    _tituloController.clear();
    _mostrarMensaje('Tarea agregada correctamente');
  }

  // CAMBIAR EL ESTADO DE UNA TAREA
  Future<void> _alternarCompletada(
    Tarea tarea,
    bool completada,
  ) async {
    await widget.database.cambiarEstado(
      tarea.id,
      completada,
    );
  }

  // EDITAR EL TITULO DE UNA TAREA
  Future<void> _editarTarea(Tarea tarea) async {
    final controller = TextEditingController(
      text: tarea.titulo,
    );

    final nuevoTitulo = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar tarea'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Nuevo titulo',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, controller.text);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (nuevoTitulo == null) {
      return;
    }

    final titulo = nuevoTitulo.trim();

    if (titulo.isEmpty) {
      _mostrarMensaje('El titulo no puede estar vacio');
      return;
    }

    await widget.database.editarTarea(
      tarea.id,
      titulo,
    );

    _mostrarMensaje('Tarea actualizada correctamente');
  }

  // ELIMINAR UNA TAREA
  Future<void> _eliminarTarea(Tarea tarea) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar tarea'),
          content: Text(
            '¿Deseas eliminar "${tarea.titulo}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    await widget.database.eliminarTarea(tarea.id);

    _mostrarMensaje('Tarea eliminada correctamente');
  }

  // MOSTRAR MENSAJES
  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestor de tareas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Nueva tarea',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _agregarTarea(),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _agregarTarea,
              icon: const Icon(Icons.add),
              label: const Text('Agregar tarea'),
            ),
            const SizedBox(height: 12),
            const Text(
              'Mis tareas',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),

            // CONSULTAR Y MOSTRAR TAREAS DE SQLITE
            Expanded(
              child: StreamBuilder(
                stream: widget.database.observarTareas(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error al consultar las tareas'),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final registros = snapshot.data!;

                  final tareas = registros.map((registro) {
                    return Tarea(
                      id: registro.id,
                      titulo: registro.titulo,
                      completada: registro.completada,
                    );
                  }).toList();

                  if (tareas.isEmpty) {
                    return const Center(
                      child: Text('Todavia no hay tareas guardadas'),
                    );
                  }

                  return ListView.builder(
                    itemCount: tareas.length,
                    itemBuilder: (context, index) {
                      final tarea = tareas[index];

                      return Card(
                        child: ListTile(
                          leading: Checkbox(
                            value: tarea.completada,
                            onChanged: (valor) {
                              if (valor != null) {
                                _alternarCompletada(
                                  tarea,
                                  valor,
                                );
                              }
                            },
                          ),
                          title: Text(
                            tarea.titulo,
                            style: TextStyle(
                              decoration: tarea.completada
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          subtitle: Text('ID: ${tarea.id}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Editar',
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editarTarea(tarea),
                              ),
                              IconButton(
                                tooltip: 'Eliminar',
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _eliminarTarea(tarea),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
