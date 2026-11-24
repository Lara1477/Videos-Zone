import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../router.dart';
import '../services/auth_service.dart';
import '../services/pixabay_service.dart';
import '../theme.dart';
import '../widgets/common_widgets.dart';

/// Tema de los videos en línea (solo si se pasa PIXABAY_KEY). Mejor en inglés.
const String kFeedQuery = 'nature';

class _Video {
  const _Video(this.url, this.user, this.caption, this.avatarUrl, this.likes,
      this.comments);
  final String
      url; // enlace .mp4 o ruta de un archivo, ej. 'assets/videos/a.mp4'
  final String user;
  final String caption;
  final String avatarUrl;
  final int likes;
  final int comments;
}

/// Videos verticales (720x1280) incluidos en el proyecto: el feed SIEMPRE
/// tiene al menos 4 aunque no haya internet. Reemplázalos por tus propios
/// .mp4 verticales manteniendo los mismos nombres de archivo.
const List<_Video> _localVideos = [
  _Video(
    'https://cdn.pixabay.com/video/2024/08/30/228847_medium.mp4',
    '@NaturalezaViva',
    'Paisajes naturales y momentos tranquilos capturados en movimiento #naturaleza',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=160&h=160&fit=crop',
    1240,
    32,
  ),
  _Video(
    'https://cdn.pixabay.com/video/2022/03/18/111204-689949818_medium.mp4',
    '@AtardecerWorld',
    'Atardecer inolvidable con colores cálidos y vistas relajantes #atardecer',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=160&h=160&fit=crop',
    873,
    18,
  ),
  _Video(
    'https://cdn.pixabay.com/video/2026/07/15/364251_medium.mp4',
    '@ViajesAzules',
    'Escena de viaje con paisajes abiertos y una atmósfera de calma #viajes',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=160&h=160&fit=crop',
    2105,
    57,
  ),
  _Video(
    'https://cdn.pixabay.com/video/2023/04/28/160767-822213540_medium.mp4',
    '@BosqueReal',
    'Naturaleza y detalles verdes para desconectarte del ruido #naturaleza',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=160&h=160&fit=crop',
    645,
    12,
  ),
  _Video(
    'https://cdn.pixabay.com/video/2026/10/22/384550_medium.mp4',
    '@LucesUrbanas',
    'La ciudad cobra vida con movimiento, luces y energía #urbano',
    'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=160&h=160&fit=crop',
    1530,
    41,
  ),
  _Video(
    'https://cdn.pixabay.com/video/2024/03/12/203923-922675870_medium.mp4',
    '@MomentosCine',
    'Una escena cinematográfica que invita a disfrutar cada segundo #cinematografía',
    'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=160&h=160&fit=crop',
    982,
    27,
  ),
];

/// Feed vertical tipo TikTok: deslizar para cambiar de video,
/// tocar para pausar/reanudar, e información del video (usuario, texto, likes).
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _controller = PageController();
  final Set<int> _liked = {};
  List<_Video> _videos = List.of(_localVideos);
  int _current = 0;

  @override
  void initState() {
    super.initState();
    if (hasPixabayKey) _loadOnline();
  }

  /// Agrega al final videos verticales de Pixabay (opcional). Si falla,
  /// el feed sigue funcionando con los videos locales.
  Future<void> _loadOnline() async {
    try {
      final found = await PixabayService.search(kFeedQuery);
      final online = found
          .where((v) => v.isPortrait)
          .map((v) => _Video(
                v.fileUrl,
                '@${v.author.replaceAll(' ', '').toLowerCase()}',
                'Video de ${v.author} en Pixabay',
                'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=160&h=160&fit=crop',
                0,
                0,
              ))
          .toList();
      if (!mounted || online.isEmpty) return;
      setState(() => _videos = [..._localVideos, ...online]);
    } catch (_) {
      // Sin internet o clave inválida: se ignora.
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showProfile() {
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => _ProfileSheet(
        user: user,
        onLogout: () async {
          Navigator.of(sheetContext).pop();
          await AuthService.instance.signOut();
          // El redirect de go_router ya nos lleva al login; esto lo asegura.
          if (mounted) context.go(AppRoutes.login);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Mi perfil',
            iconSize: 30,
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: _showProfile,
          ),
        ],
      ),
      // Permite deslizar también con el mouse (útil al probar en Chrome).
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
        ),
        child: PageView.builder(
          controller: _controller,
          scrollDirection: Axis.vertical,
          itemCount: _videos.length,
          onPageChanged: (i) => setState(() => _current = i),
          itemBuilder: (context, i) {
            return _VideoPage(
              key: ValueKey(_videos[i].url),
              video: _videos[i],
              active: i == _current,
              liked: _liked.contains(i),
              onLike: () => setState(() {
                _liked.contains(i) ? _liked.remove(i) : _liked.add(i);
              }),
            );
          },
        ),
      ),
    );
  }
}

/// Panel con los datos del usuario y el botón de cerrar sesión.
class _ProfileSheet extends StatelessWidget {
  const _ProfileSheet({required this.user, required this.onLogout});

  final User user;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    final name = (user.displayName ?? '').trim();
    final email = user.email ?? 'Sin correo';
    final initial =
        (name.isNotEmpty ? name : email).characters.first.toUpperCase();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 38,
              backgroundColor: kAccent,
              foregroundImage:
                  user.photoURL != null ? NetworkImage(user.photoURL!) : null,
              child: Text(initial,
                  style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: kGround)),
            ),
            const SizedBox(height: 14),
            Text(name.isNotEmpty ? name : 'Usuario sin nombre',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(email, style: const TextStyle(color: kMuted)),
            const SizedBox(height: 4),
            Text('Sesión iniciada con ${AuthService.providerLabel(user)}',
                style: const TextStyle(color: kMuted, fontSize: 13)),
            const SizedBox(height: 24),
            PrimaryButton(label: 'Cerrar sesión', onPressed: onLogout),
          ],
        ),
      ),
    );
  }
}

class _VideoPage extends StatefulWidget {
  const _VideoPage({
    super.key,
    required this.video,
    required this.active,
    required this.liked,
    required this.onLike,
  });

  final _Video video;
  final bool active;
  final bool liked;
  final VoidCallback onLike;

  @override
  State<_VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<_VideoPage> {
  late final VideoPlayerController _c;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    final url = widget.video.url;
    // Si empieza con http es un enlace de internet; si no, es un archivo del proyecto.
    _c = url.startsWith('http')
        ? VideoPlayerController.networkUrl(Uri.parse(url))
        : VideoPlayerController.asset(url);
    _c.setLooping(true);
    _c.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
      if (widget.active) _safePlay();
    }).catchError((_) {
      if (mounted) setState(() => _failed = true);
    });
  }

  @override
  void didUpdateWidget(covariant _VideoPage old) {
    super.didUpdateWidget(old);
    if (!_c.value.isInitialized) return;
    if (widget.active && !old.active) {
      _c.seekTo(Duration.zero);
      _safePlay();
    } else if (!widget.active && old.active) {
      _c.pause();
    }
  }

  Future<void> _safePlay() async {
    try {
      await _c.play();
    } catch (_) {
      // Algunos navegadores bloquean el autoplay: el usuario puede tocar para reproducir.
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (!_c.value.isInitialized) return;
    setState(() {
      _c.value.isPlaying ? _c.pause() : _safePlay();
    });
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.video;
    final ready = _c.value.isInitialized;
    final paused = ready && !_c.value.isPlaying;

    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Colors.black),
        if (ready)
          FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: _c.value.size.width,
              height: _c.value.size.height,
              child: VideoPlayer(_c),
            ),
          )
        else
          Center(
            child: _failed
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'No se pudo cargar este video.\nRevisa el enlace o tu conexión.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: kMuted),
                    ),
                  )
                : const CircularProgressIndicator(color: kAccent),
          ),
        // Oscurece arriba y abajo para que el texto se lea sobre cualquier video.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x66000000),
                Color(0x00000000),
                Color(0x00000000),
                Color(0xAA000000)
              ],
              stops: [0, 0.25, 0.55, 1],
            ),
          ),
        ),
        // Tocar el video lo pausa o lo reanuda.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _togglePlay,
            child: Center(
              child: paused
                  ? Container(
                      width: 84,
                      height: 84,
                      decoration: const BoxDecoration(
                        color: Color(0x80000000),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow_rounded,
                          size: 52, color: Colors.white),
                    )
                  : null,
            ),
          ),
        ),
        SafeArea(
          child: Stack(
            children: [
              Positioned(
                left: 16,
                right: 90,
                bottom: 32,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: kAccent,
                          backgroundImage: NetworkImage(v.avatarUrl),
                        ),
                        const SizedBox(width: 8),
                        Text(v.user,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(v.caption, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              Positioned(
                right: 12,
                bottom: 32,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _RailButton(
                      icon:
                          widget.liked ? Icons.favorite : Icons.favorite_border,
                      color:
                          widget.liked ? const Color(0xFFFF4D6D) : Colors.white,
                      label: '${v.likes + (widget.liked ? 1 : 0)}',
                      semantic: 'Me gusta',
                      onTap: widget.onLike,
                    ),
                    const SizedBox(height: 20),
                    _RailButton(
                      icon: Icons.chat_bubble_outline,
                      label: '${v.comments}',
                      semantic: 'Comentarios',
                      onTap: () {},
                    ),
                    const SizedBox(height: 20),
                    _RailButton(
                      icon: Icons.ios_share,
                      label: 'Enviar',
                      semantic: 'Compartir',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RailButton extends StatelessWidget {
  const _RailButton({
    required this.icon,
    required this.label,
    required this.semantic,
    required this.onTap,
    this.color = Colors.white,
  });

  final IconData icon;
  final String label;
  final String semantic;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: semantic,
          iconSize: 34,
          icon: Icon(icon, color: color),
          onPressed: onTap,
        ),
        Text(label,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: kMuted)),
      ],
    );
  }
}
