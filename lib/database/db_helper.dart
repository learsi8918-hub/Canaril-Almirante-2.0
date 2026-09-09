import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/ave_model.dart';

class DBHelper {
  static const String _dbName = 'canaril_control.db';
  static const int _dbVersion = 1;

  // Padrão Singleton: Garante que apenas uma conexão de banco fique aberta no app
  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Localiza a pasta segura de documentos nativa do celular (Android ou iOS)
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  // Criação física das tabelas baseadas nos seus modelos de dados
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE aves (
        anilha TEXT,
        clubeSigla TEXT,
        sexo TEXT,
        tipoFob TEXT,
        mutacaoRaca TEXT,
        porteDetalhe TEXT,
        comTopete INTEGER,
        fotoPath TEXT,
        ehPortador INTEGER,
        mutacaoPortada TEXT,
        fatorMorfologico TEXT,
        status TEXT,
        dataBaixa TEXT,
        motivoBaixaDetalhe TEXT,
        totalOvos INTEGER,
        ovosFerteis INTEGER,
        filhotesNascidos INTEGER,
        PRIMARY KEY (clubeSigla, anilha) -- Chave primária ornitológica composta
      )
    ''');
  }

  /// -----------------------------------------------------------------------
  /// OPERAÇÕES CRUD (SALVAR E BUSCAR DE FORMA SEGURA)
  /// -----------------------------------------------------------------------

  // Insere ou atualiza um canário de forma blindada contra duplicidade
  Future<int> salvarAve(Ave ave) async {
    final db = await instance.database;
    return await db.insert(
      'aves',
      ave.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // Substitui os dados se a anilha já existir
    );
  }

  // Recupera todas as aves ativas do canaril ordenadas por anilha
  Future<List<Ave>> buscarAvesAtivas() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'aves',
      where: 'status = ?',
      whereArgs: ['Ativa'],
      orderBy: 'anilha ASC',
    );

    return List.generate(maps.length, (i) {
      return Ave.fromMap(maps[i]);
    });
  }
}
