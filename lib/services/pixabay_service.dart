import 'dart:convert';

import 'package:http/http.dart' as http;

/// Clave de Pixabay (opcional). NO se escribe en el código para no subirla a GitHub.
/// Se pasa al ejecutar:  flutter run --dart-define=PIXABAY_KEY=tu_clave
/// Sin clave, el feed usa solo los videos locales de assets/videos/.
const String kPixabayApiKey = String.fromEnvironment('PIXABAY_KEY');

bool get hasPixabayKey => kPixabayApiKey.isNotEmpty;

class StockVideo {
  StockVideo({
    required this.id,
    required this.fileUrl,
    required this.author,
    required this.pageUrl,
    required this.isPortrait,
  });

  final int id;
  final String fileUrl; // enlace directo al .mp4
  final String author;
  final String pageUrl;
  final bool isPortrait;
}

class PixabayService {
  /// Busca videos. `query` funciona mejor en inglés
  /// (nature, city, food, travel, fitness...).
  /// Pixabay no filtra por orientación, así que los verticales salen primero.
  static Future<List<StockVideo>> search(String query, {int perPage = 50}) async {
    if (!hasPixabayKey) return const [];

    final uri = Uri.https('pixabay.com', '/api/videos/', {
      'key': kPixabayApiKey,
      'q': query,
      'per_page': '$perPage',
      'safesearch': 'true',
    });

    final res = await http.get(uri);
    if (res.statusCode == 400 || res.statusCode == 401 || res.statusCode == 403) {
      throw Exception('La clave de Pixabay no es válida.');
    }
    if (res.statusCode == 429) {
      throw Exception('Se llegó al límite de consultas de Pixabay. Intenta en un minuto.');
    }
    if (res.statusCode != 200) {
      throw Exception('Pixabay respondió con error ${res.statusCode}.');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final portrait = <StockVideo>[];
    final landscape = <StockVideo>[];

    for (final raw in (data['hits'] as List? ?? const [])) {
      final hit = raw as Map<String, dynamic>;
      final sizes = (hit['videos'] as Map<String, dynamic>?) ?? const {};

      // Prefiere calidad media (carga rápido); si no existe, baja de tamaño.
      Map<String, dynamic>? chosen;
      for (final key in ['medium', 'small', 'tiny', 'large']) {
        final s = sizes[key] as Map<String, dynamic>?;
        if (s != null && (s['url'] as String? ?? '').isNotEmpty) {
          chosen = s;
          break;
        }
      }
      if (chosen == null) continue;

      final w = (chosen['width'] as num?)?.toInt() ?? 0;
      final h = (chosen['height'] as num?)?.toInt() ?? 0;
      final video = StockVideo(
        id: (hit['id'] as num).toInt(),
        fileUrl: chosen['url'] as String,
        author: (hit['user'] as String?) ?? 'Pixabay',
        pageUrl: (hit['pageURL'] as String?) ?? 'https://pixabay.com',
        isPortrait: h > w,
      );
      (video.isPortrait ? portrait : landscape).add(video);
    }
    return [...portrait, ...landscape];
  }
}
