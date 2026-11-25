# Gestor de tareas local

Aplicación multiplataforma desarrollada con **Flutter**, **Dart**, **SQLite** y **Drift**, que permite administrar tareas mediante una base de datos local, sin depender de servidores ni servicios externos.

## 1. Características

La aplicación permite:

- Agregar tareas con validación de títulos vacíos.
- Consultar las tareas almacenadas.
- Editar el título de una tarea.
- Marcar tareas como completadas o pendientes.
- Eliminar tareas mediante su identificador.
- Conservar los datos después de cerrar y volver a abrir la aplicación.

## 2. Tecnologías utilizadas

| Tecnología | Uso |
|---|---|
| Flutter | Desarrollo de la interfaz multiplataforma |
| Dart | Lenguaje de programación |
| SQLite | Almacenamiento local de datos |
| Drift | Acceso y administración de SQLite |
| drift_flutter | Configuración de la conexión con la base de datos |
| build_runner | Generación de código de Drift |

## 3. Arquitectura del proyecto

La aplicación está organizada de la siguiente manera:

```text
lib/
├── main.dart
├── data/
│   ├── app_database.dart
│   └── app_database.g.dart
├── models/
│   └── tarea.dart
└── screens/
    └── tareas_page.dart

test/
├── widget_test.dart
└── app_database_test.dart

web/
├── drift_worker.js
└── sqlite3.wasm
```

**Descripción de los componentes:**

- `main.dart`: inicializa la aplicación y la conexión con la base de datos.
- `data/app_database.dart`: define la tabla de tareas y las operaciones CRUD.
- `data/app_database.g.dart`: contiene el código generado por Drift.
- `models/tarea.dart`: representa el modelo de una tarea.
- `screens/tareas_page.dart`: contiene la interfaz y las acciones del usuario.
- `test/`: contiene las pruebas automatizadas.
- `web/`: contiene los recursos necesarios para ejecutar SQLite mediante WebAssembly en el navegador.

## 4. Estructura de la base de datos

Se utiliza una tabla llamada `Tareas` con los siguientes campos:

| Campo | Tipo | Descripción |
|---|---|---|
| id | INTEGER | Identificador autoincremental |
| titulo | TEXT | Nombre de la tarea |
| completada | BOOLEAN | Estado de la tarea |

El campo `id` funciona como clave primaria. El estado de una tarea tiene `false` como valor predeterminado.

## 5. Instalación y ejecución

### Requisitos

- Flutter SDK.
- Dart SDK compatible con el proyecto.
- Visual Studio con las herramientas de desarrollo para Windows, si se ejecuta en Windows.
- Google Chrome, si se ejecuta en web.

### Instalar dependencias

```bash
flutter pub get
```

### Generar código de Drift

```bash
dart run build_runner build
```

### Ejecutar en Windows

```bash
flutter run -d windows
```

### Ejecutar en Chrome

```bash
flutter run -d chrome
```

## 6. Pruebas automatizadas

Para ejecutar todas las pruebas:

```bash
flutter test
```

Se implementaron cinco pruebas automatizadas:

1. Verificar que la pantalla inicial se muestre correctamente.
2. Comprobar la inserción y consulta de tareas.
3. Comprobar la edición del título y el cambio de estado.
4. Comprobar la eliminación de tareas mediante su ID.
5. Verificar que no se permitan títulos vacíos o compuestos solamente por espacios.

## 7. Compatibilidad y persistencia

Se comprobó la ejecución de la aplicación en:

- **Windows:** persistencia de datos después de cerrar y volver a abrir la aplicación.
- **Google Chrome:** persistencia de datos después de recargar la página.

En web se utilizan los recursos `sqlite3.wasm` y `drift_worker.js`, junto con el almacenamiento compatible proporcionado por Drift.

La solución está desarrollada con Flutter y Drift para un enfoque multiplataforma. Las plataformas adicionales deben verificarse en sus respectivos entornos.

## 8. Autoría

Proyecto académico desarrollado como parte de la asignatura de Programación de Dispositivos Móviles.

Repositorio: https://github.com/Mikel2305/gestor_tareas_local
