import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:sqflite/sqflite.dart';

import '../database/db_helper.dart';

class AppThemeController extends ChangeNotifier {
  // ---------------------------------------------------------------------------
  // IDENTIDADE VISUAL
  // ---------------------------------------------------------------------------

  Color primary = const Color(0xFF2E7D32);
  Color secondary = const Color(0xFF66BB6A);
  Color surface = const Color(0xFFF7F8F6);
  Color onPrimary = Colors.white;

  String? logoPath;

  String breederName = '';
  String houseName = '';
  String city = '';
  String state = '';
  String club = 'Nenhum';
  String clubCode = '';

  // ---------------------------------------------------------------------------
  // UTILITÁRIOS DE COR
  // ---------------------------------------------------------------------------

  Color _hex(String? value, Color fallback) {
    if (value == null || value.trim().isEmpty) {
      return fallback;
    }

    final clean = value.replaceAll('#', '').trim();

    final parsed = int.tryParse(clean, radix: 16);

    if (parsed == null) {
      return fallback;
    }

    return Color(parsed | 0xFF000000);
  }

  String _toHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  Color _textColorFor(Color color) {
    return color.computeLuminance() > 0.52
        ? Colors.black
        : Colors.white;
  }

  // ---------------------------------------------------------------------------
  // CARREGAR PERFIL
  // ---------------------------------------------------------------------------

  Future<void> load() async {
    final db = await DBHelper.db;

    final rows = await db.query(
      'perfil_criador',
      limit: 1,
    );

    if (rows.isEmpty) {
      return;
    }

    final profile = rows.first;

    houseName = (profile['nome_canaril'] ?? '') as String;
    breederName = (profile['nome_criador'] ?? '') as String;

    city = (profile['cidade'] ?? '') as String;
    state = (profile['estado'] ?? '') as String;

    final savedClub = (profile['clube'] ?? '') as String;

    club = savedClub.trim().isEmpty
        ? 'Nenhum'
        : savedClub;

    clubCode = (profile['sigla_clube'] ?? '') as String;

    logoPath = profile['logo_path'] as String?;

    primary = _hex(
      profile['cor_primaria'] as String?,
      primary,
    );

    secondary = _hex(
      profile['cor_secundaria'] as String?,
      secondary,
    );

    surface = _hex(
      profile['cor_fundo'] as String?,
      surface,
    );

    onPrimary = _textColorFor(primary);

    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // SALVAR PERFIL E IDENTIDADE VISUAL
  // ---------------------------------------------------------------------------

  Future<void> saveProfile({
    String? logo,
    Uint8List? logoBytes,
  }) async {
    // Se uma nova logo foi selecionada, a identidade visual
    // é recalculada exclusivamente a partir dela.
    if (logoBytes != null) {
      final palette = extractPalette(logoBytes);

      primary = palette.$1;
      secondary = palette.$2;
      surface = palette.$3;

      onPrimary = _textColorFor(primary);
    }

    if (logo != null && logo.trim().isNotEmpty) {
      logoPath = logo;
    }

    final db = await DBHelper.db;

    await db.insert(
      'perfil_criador',
      {
        'id': 1,
        'nome_canaril': houseName,
        'nome_criador': breederName,
        'sigla_clube': clubCode,
        'clube': club,
        'logo_path': logoPath,
        'cidade': city,
        'estado': state,
        'cor_primaria': _toHex(primary),
        'cor_secundaria': _toHex(secondary),
        'cor_fundo': _toHex(surface),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // EXTRAÇÃO DA PALETA DA LOGO
  // ---------------------------------------------------------------------------
  //
  // Retorna:
  //
  // 1. primary   = cor principal da identidade
  // 2. secondary = segunda cor relevante
  // 3. surface   = fundo suave derivado da identidade
  //
  // A extração ignora:
  // - branco quase puro
  // - preto quase puro
  // - tons muito acinzentados
  //
  // Isso evita que o fundo da logo domine a identidade do aplicativo.
  // ---------------------------------------------------------------------------

  (Color, Color, Color) extractPalette(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);

    if (decoded == null) {
      return (
        primary,
        secondary,
        surface,
      );
    }

    final resized = img.copyResize(
      decoded,
      width: 100,
      height: 100,
    );

    // Agrupa as cores em blocos para evitar centenas de pequenas
    // variações da mesma cor.
    final Map<int, int> counts = {};

    for (final pixel in resized) {
      final r = pixel.r.toInt();
      final g = pixel.g.toInt();
      final b = pixel.b.toInt();

      final maxChannel = [r, g, b].reduce(
        (a, c) => a > c ? a : c,
      );

      final minChannel = [r, g, b].reduce(
        (a, c) => a < c ? a : c,
      );

      final saturation = maxChannel - minChannel;

      // Ignora branco/fundo muito claro.
      if (r > 242 && g > 242 && b > 242) {
        continue;
      }

      // Ignora preto absoluto ou quase absoluto.
      if (r < 18 && g < 18 && b < 18) {
        continue;
      }

      // Ignora cinzas muito neutros.
      if (saturation < 20) {
        continue;
      }

      // Quantização da cor.
      final qr = r ~/ 16;
      final qg = g ~/ 16;
      final qb = b ~/ 16;

      final key = (qr << 16) | (qg << 8) | qb;

      counts[key] = (counts[key] ?? 0) + 1;
    }

    if (counts.isEmpty) {
      return (
        primary,
        secondary,
        surface,
      );
    }

    final ranked = counts.entries.toList()
      ..sort(
        (a, b) => b.value.compareTo(a.value),
      );

    Color colorFromKey(int key) {
      final qr = (key >> 16) & 255;
      final qg = (key >> 8) & 255;
      final qb = key & 255;

      final r = (qr * 16 + 8).clamp(0, 255);
      final g = (qg * 16 + 8).clamp(0, 255);
      final b = (qb * 16 + 8).clamp(0, 255);

      return Color.fromARGB(
        255,
        r,
        g,
        b,
      );
    }

    // -----------------------------------------------------------------------
    // ESCOLHE A PRIMEIRA COR RELEVANTE
    // -----------------------------------------------------------------------

    final primaryColor = colorFromKey(
      ranked.first.key,
    );

    // -----------------------------------------------------------------------
    // ESCOLHE UMA SEGUNDA COR REALMENTE DIFERENTE
    // -----------------------------------------------------------------------

    Color secondaryColor = primaryColor;

    for (final entry in ranked.skip(1)) {
      final candidate = colorFromKey(entry.key);

      final difference = _colorDistance(
        primaryColor,
        candidate,
      );

      if (difference > 45) {
        secondaryColor = candidate;
        break;
      }
    }

    // Se não encontrou uma segunda cor suficientemente diferente,
    // usa uma variação calculada da principal.
    if (secondaryColor == primaryColor) {
      secondaryColor = _createSecondary(primaryColor);
    }

    // -----------------------------------------------------------------------
    // FUNDO
    // -----------------------------------------------------------------------
    //
    // O fundo não deve ser a cor forte da logo.
    // Criamos um fundo extremamente claro baseado na cor principal.
    // Assim a identidade continua presente sem prejudicar a leitura.
    // -----------------------------------------------------------------------

    final bg = _createSurface(primaryColor);

    return (
      primaryColor,
      secondaryColor,
      bg,
    );
  }

  // ---------------------------------------------------------------------------
  // DISTÂNCIA ENTRE CORES
  // ---------------------------------------------------------------------------

  double _colorDistance(
    Color a,
    Color b,
  ) {
    final dr = a.r.toDouble() - b.r.toDouble();
    final dg = a.g.toDouble() - b.g.toDouble();
    final db = a.b.toDouble() - b.b.toDouble();

    return (dr * dr + dg * dg + db * db).sqrt();
  }

  // ---------------------------------------------------------------------------
  // CRIA COR SECUNDÁRIA QUANDO A LOGO TEM UMA ÚNICA COR DOMINANTE
  // ---------------------------------------------------------------------------

  Color _createSecondary(Color base) {
    final hsl = HSLColor.fromColor(base);

    final newLightness = hsl.lightness > 0.55
        ? (hsl.lightness - 0.20).clamp(0.20, 0.80)
        : (hsl.lightness + 0.20).clamp(0.20, 0.80);

    return hsl
        .withLightness(newLightness)
        .toColor();
  }

  // ---------------------------------------------------------------------------
  // CRIA FUNDO DERIVADO DA COR PRINCIPAL
  // ---------------------------------------------------------------------------

  Color _createSurface(Color base) {
    final hsl = HSLColor.fromColor(base);

    return hsl
        .withSaturation(
          (hsl.saturation * 0.18).clamp(0.02, 0.25),
        )
        .withLightness(0.97)
        .toColor();
  }
}

// -----------------------------------------------------------------------------
// EXTENSÃO MATEMÁTICA
// -----------------------------------------------------------------------------

extension _DoubleSqrt on double {
  double sqrt() {
    if (this <= 0) {
      return 0;
    }

    double x = this;

    for (int i = 0; i < 12; i++) {
      x = 0.5 * (x + this / x);
    }

    return x;
  }
}
