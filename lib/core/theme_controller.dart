import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../database/db_helper.dart';

class AppThemeController extends ChangeNotifier {
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

  Color _hex(String? value, Color fallback) {
    if (value == null || value.isEmpty) return fallback;
    final h = value.replaceAll('#', '');
    final v = int.tryParse(h, radix: 16);
    return v == null ? fallback : Color(v | 0xFF000000);
  }

  String _toHex(Color c) => '#${c.value.toRadixString(16).substring(2).toUpperCase()}';

  Future<void> load() async {
    final db = await DBHelper.db;
    final rows = await db.query('perfil_criador', limit: 1);
    if (rows.isEmpty) return;
    final p = rows.first;
    houseName = (p['nome_canaril'] ?? '') as String;
    breederName = (p['nome_criador'] ?? '') as String;
    city = (p['cidade'] ?? '') as String;
    state = (p['estado'] ?? '') as String;
    club = ((p['clube'] ?? 'Nenhum') as String).isEmpty ? 'Nenhum' : p['clube'] as String;
    clubCode = (p['sigla_clube'] ?? '') as String;
    logoPath = p['logo_path'] as String?;
    primary = _hex(p['cor_primaria'] as String?, primary);
    secondary = _hex(p['cor_secundaria'] as String?, secondary);
    surface = _hex(p['cor_fundo'] as String?, surface);
    onPrimary = primary.computeLuminance() > .52 ? Colors.black : Colors.white;
    notifyListeners();
  }

  Future<void> saveProfile({String? logo, Uint8List? logoBytes}) async {
    if (logoBytes != null) {
      final palette = extractPalette(logoBytes);
      primary = palette.$1;
      secondary = palette.$2;
      surface = palette.$3;
      onPrimary = primary.computeLuminance() > .52 ? Colors.black : Colors.white;
    }
    if (logo != null) logoPath = logo;
    final db = await DBHelper.db;
    await db.insert('perfil_criador', {
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
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    notifyListeners();
  }

  (Color, Color, Color) extractPalette(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return (primary, secondary, surface);
    final resized = img.copyResize(decoded, width: 80, height: 80);
    final Map<int, int> counts = {};
    for (final p in resized) {
      final r = p.r.toInt(), g = p.g.toInt(), b = p.b.toInt();
      final max = [r, g, b].reduce((a, c) => a > c ? a : c);
      final min = [r, g, b].reduce((a, c) => a < c ? a : c);
      if (max - min < 18 && max > 238) continue;
      if (max < 28) continue;
      final q = ((r ~/ 24) << 16) | ((g ~/ 24) << 8) | (b ~/ 24);
      counts[q] = (counts[q] ?? 0) + 1;
    }
    final ranked = counts.entries.toList()..sort((a,b) => b.value.compareTo(a.value));
    Color colorAt(int i, Color fallback) {
      if (ranked.isEmpty) return fallback;
      final q = ranked[i.clamp(0, ranked.length - 1)].key;
      final r = ((q >> 16) & 255) * 24 + 12;
      final g = ((q >> 8) & 255) * 24 + 12;
      final b = (q & 255) * 24 + 12;
      return Color.fromARGB(255, r.clamp(0,255), g.clamp(0,255), b.clamp(0,255));
    }
    final p = colorAt(0, primary);
    final s = colorAt(ranked.length > 1 ? 1 : 0, secondary);
    final bg = p.computeLuminance() < .28 ? const Color(0xFFF7F8F6) : const Color(0xFFFAFAFA);
    return (p, s, bg);
  }
}
