import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:crypto/crypto.dart';
import 'package:csv/csv.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get db async =>
      _db ??= await _open();

  static Future<Database> _open() async {
    final dir = await getDatabasesPath();

    return openDatabase(
      join(dir, 'canary_control_pro_v14.db'),
      version: 1,
      onCreate: (db, v) async {
        await db.execute(
          'CREATE TABLE perfil_criador ('
          'id INTEGER PRIMARY KEY, '
          'nome_canaril TEXT, '
          'nome_criador TEXT, '
          'sigla_clube TEXT, '
          'clube TEXT, '
          'logo_path TEXT, '
          'cidade TEXT, '
          'estado TEXT, '
          'cor_primaria TEXT, '
          'cor_secundaria TEXT, '
          'cor_fundo TEXT, '
          'senha_hash TEXT, '
          'senha_salt TEXT'
          ')',
        );

        await db.execute(
          'CREATE TABLE aves ('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'anilha TEXT UNIQUE, '
          'nome TEXT, '
          'gaiola TEXT, '
          'sexo TEXT, '
          'segmento TEXT, '
          'familia TEXT, '
          'raca TEXT, '
          'variedade TEXT, '
          'mutacao TEXT, '
          'topete INTEGER DEFAULT 0, '
          'origem TEXT, '
          'origem_detalhe TEXT, '
          'data_nascimento TEXT, '
          'foto_path TEXT, '
          'observacoes TEXT, '
          'status TEXT DEFAULT "ATIVA", '
          'pai_id INTEGER, '
          'mae_id INTEGER, '
          'criado_em TEXT'
          ')',
        );

        await db.execute(
          'CREATE TABLE ciclos ('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'gaiola TEXT, '
          'sistema TEXT, '
          'macho_id INTEGER, '
          'femea_id INTEGER, '
          'data_uniao TEXT, '
          'data_fim TEXT, '
          'status TEXT, '
          'observacoes TEXT'
          ')',
        );

        await db.execute(
          'CREATE TABLE ovos ('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'ciclo_id INTEGER, '
          'numero INTEGER, '
          'data_postura TEXT, '
          'mae_id INTEGER, '
          'pai_id INTEGER, '
          'ovoscopia_data TEXT, '
          'resultado TEXT, '
          'observacoes TEXT'
          ')',
        );

        await db.execute(
          'CREATE TABLE filhotes ('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'ovo_id INTEGER, '
          'anilha TEXT UNIQUE, '
          'nome TEXT, '
          'data_nascimento TEXT, '
          'pigmentacao TEXT, '
          'pai_id INTEGER, '
          'mae_id INTEGER, '
          'gaiola TEXT, '
          'status TEXT DEFAULT "ATIVO", '
          'observacoes TEXT'
          ')',
        );

        await db.execute(
          'CREATE TABLE historico_saude ('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'ave_id INTEGER, '
          'inicio TEXT, '
          'fim TEXT, '
          'doenca TEXT, '
          'medicamento TEXT, '
          'dosagem TEXT, '
          'status TEXT, '
          'observacoes TEXT'
          ')',
        );

        await db.execute(
          'CREATE TABLE baixas ('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'ave_id INTEGER, '
          'data TEXT, '
          'motivo TEXT, '
          'destino TEXT, '
          'observacoes TEXT'
          ')',
        );

        await db.execute(
          'CREATE TABLE lembretes ('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'ave_id INTEGER, '
          'ciclo_id INTEGER, '
          'titulo TEXT, '
          'data TEXT, '
          'tipo TEXT, '
          'concluido INTEGER DEFAULT 0'
          ')',
        );

        await db.execute(
          'CREATE TABLE retrocruzamentos ('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'ave_base_id INTEGER, '
          'ave_alvo_id INTEGER, '
          'geracao INTEGER, '
          'objetivo TEXT, '
          'observacoes TEXT'
          ')',
        );

        await db.execute(
          'CREATE TABLE catalogo_fob ('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'segmento TEXT, '
          'familia TEXT, '
          'raca TEXT, '
          'mutacao TEXT, '
          'categoria TEXT, '
          'codigo TEXT'
          ')',
        );

        await db.execute(
          'CREATE INDEX idx_aves_status ON aves(status)',
        );

        await db.execute(
          'CREATE INDEX idx_aves_gaiola ON aves(gaiola)',
        );

        await db.execute(
          'CREATE INDEX idx_ovos_ciclo ON ovos(ciclo_id)',
        );

        await db.execute(
          'CREATE INDEX idx_ciclos_femea ON ciclos(femea_id)',
        );

        await db.execute(
          'CREATE INDEX idx_ciclos_macho ON ciclos(macho_id)',
        );

        await _seedFob(db);
      },
    );
  }

  static Future<void> _seedFob(Database db) async {
    try {
      final text = await rootBundle.loadString(
        'assets/catalogo_fob.csv',
      );

      final rows = const CsvToListConverter().convert(text);

      if (rows.isEmpty) return;

      final h = rows.first
          .map(
            (e) => e.toString().trim().toLowerCase(),
          )
          .toList();

      int ix(String name) =>
          h.indexWhere((e) => e.contains(name));

      final isx = ix('segmento');
      final ifam = ix('subgrupo');
      final ir = ix('raça');
      final im = ix('mutação');
      final ic = ix('categoria');
      final ico = ix('código');

      final batch = db.batch();

      for (final row in rows.skip(1)) {
        String val(int i) {
          return i >= 0 && i < row.length
              ? row[i].toString().trim()
              : '';
        }

        batch.insert(
          'catalogo_fob',
          {
            'segmento': val(isx),
            'familia': val(ifam),
            'raca': val(ir),
            'mutacao': val(im),
            'categoria': val(ic),
            'codigo': val(ico),
          },
        );
      }

      await batch.commit(noResult: true);
    } catch (_) {}
  }

  static String hashPassword(
    String password,
    String salt,
  ) {
    Uint8List bytes = Uint8List.fromList(
      utf8.encode('$salt:$password'),
    );

    for (var i = 0; i < 12000; i++) {
      bytes = Uint8List.fromList(
        sha256.convert(bytes).bytes,
      );
    }

    return base64UrlEncode(bytes);
  }

  static String salt() {
    return List.generate(
      24,
      (_) => Random.secure()
          .nextInt(256)
          .toRadixString(16)
          .padLeft(2, '0'),
    ).join();
  }
}
