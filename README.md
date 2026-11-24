# Video Zone

Aplicación web de videos verticales desarrollada con Flutter. Incluye autenticación con Firebase, navegación con `go_router`, feed desplazable, reproducción de videos y panel de perfil.

## Funcionalidades

- Registro e inicio de sesión con correo y contraseña.
- Inicio de sesión con Google y Facebook.
- Validación de correo, contraseña y nombre de usuario.
- Redirección automática según el estado de Firebase Auth.
- Feed vertical con seis videos.
- Reproducción, pausa y cambio de video mediante desplazamiento.
- Información de canal, descripción, miniatura, likes y comentarios.
- Perfil del usuario y cierre de sesión.
- Identidad visual con el nombre **Video Zone**.

## Tecnologías

- Flutter y Dart
- Firebase Core y Firebase Authentication
- GoRouter
- Video Player
- Pixabay CDN
- HTTP

## Ejecución

### Requisitos

- Flutter instalado.
- Proyecto creado en Firebase.
- Métodos de acceso habilitados en Firebase Authentication:
  - Correo y contraseña
  - Google
  - Facebook

### Instalación

```powershell
git clone <URL_DEL_REPOSITORIO>
cd videos_app
flutter pub get
flutter run -d chrome
```

Si necesitas configurar otro proyecto de Firebase:

```powershell
dart pub global activate flutterfire_cli
flutterfire configure
```

Después ejecuta la aplicación:

```powershell
flutter run -d chrome
```

## Estructura del proyecto

```text
lib/
├── main.dart                 # Inicialización de Firebase y aplicación
├── firebase_options.dart     # Configuración generada por FlutterFire
├── router.dart               # Rutas y redirección según la sesión
├── theme.dart                # Colores y tema visual
├── screens/
│   ├── login_screen.dart     # Inicio de sesión
│   ├── register_screen.dart  # Registro
│   └── feed_screen.dart      # Feed vertical y perfil
├── services/
│   ├── auth_service.dart     # Operaciones de Firebase Authentication
│   └── pixabay_service.dart  # Consulta opcional a Pixabay
└── widgets/
    └── common_widgets.dart   # Componentes reutilizables

assets/videos/                # Videos locales opcionales
web/                          # Configuración e iconos web
docs/evidencias/              # Capturas y otras evidencias
 test/                        # Pruebas de validación
```

## Configuración de los videos

El feed contiene seis enlaces directos al CDN de Pixabay. También puede usar archivos locales dentro de `assets/videos/` con los nombres:

- `video1.mp4`
- `video2.mp4`
- `video3.mp4`
- `video4.mp4`
- `video5.mp4`

Los archivos locales multimedia no se incluyen en Git. Consulta `assets/videos/links.txt` para el listado de fuentes utilizadas.

## Evidencias

Coloca las capturas dentro de `docs/evidencias/` y conserva los nombres indicados en su README:

| Evidencia | Contenido |
|---|---|
| `01_login_errores.png` | Validaciones del inicio de sesión |
| `02_registro_validaciones.png` | Validaciones del registro |
| `03_google.png` | Inicio de sesión con Google |
| `04_facebook.png` | Inicio de sesión con Facebook |
| `05_feed.png` | Feed con reproducción de videos |
| `06_pausa_info.png` | Video pausado con canal y descripción |
| `07_perfil_logout.png` | Perfil y cierre de sesión |
| `08_firebase_usuarios.png` | Usuarios registrados en Firebase |

## Redirección de rutas

`appRouter` escucha los cambios de autenticación de Firebase:

- Sin sesión y fuera de login o registro: abre `/login`.
- Con sesión y en login o registro: abre `/feed`.
- Con sesión activa: conserva el acceso al feed al volver a abrir la aplicación.

## Pruebas

```powershell
flutter analyze
flutter test
```

El proyecto no debe mostrar errores ni advertencias del analizador antes de subirlo al repositorio.
