import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/ave_model.dart';
import '../models/saude_model.dart';
import '../models/ciclo_model.dart';

class DBHelper {
  static const String _dbName = 'canaril_control.db';
  static const int _dbVersion = 1;

  // Padrão Singleton: Garante uma única conexão aberta com o banco no app
  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  // Criação física e relacional das tabelas do Canaril
  Future<void> _onCreate(Database db, int version) async {
    // 1. Tabela de Aves (Matrizes)
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
        PRIMARY KEY (clubeSigla, anilha)
      )
    ''');

    // 2. Tabela de Saúde (Histórico Clínico) - Chave Estrangeira ligada à Ave
    await db.execute('''
      CREATE TABLE historico_saude (
        id TEXT PRIMARY KEY,
        identificadorAve TEXT,
        dataDiagnostico TEXT,
        doencaOuSintoma TEXT,
        tratamentoAplicado TEXT,
        statusTratamento TEXT
      )
    ''');

    // 3. Tabela de Reprodução (Ciclos de Choco) - Chaves Estrangeiras ligadas ao Macho e Fêmea
    await db.execute('''
      CREATE TABLE ciclos_reproducao (
        idGaiola TEXT PRIMARY KEY,
        idMacho TEXT,
        idFemea TEXT,
        dataInicioChoco TEXT,
        quantidadeOvos INTEGER,
        ovosFerteis INTEGER,
        filhotesVivos INTEGER,
        tipoManejoMacho TEXT
      )
    ''');
  }

  /// -----------------------------------------------------------------------
  /// OPERAÇÕES CRUD - MÓDULO: AVES
  /// -----------------------------------------------------------------------

  Future<int> salvarAve(Ave ave) async {
    final db = await instance.database;
    return await db.insert(
      'aves',
      ave.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Ave>> buscarAvesAtivas() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'aves',
      where: 'status = ?',
      whereArgs: ['Ativa'],
      orderBy: 'anilha ASC',
    );
    return List.generate(maps.length, (i) => Ave.fromMap(maps[i]));
  }

  /// -----------------------------------------------------------------------
  /// OPERAÇÕES CRUD - MÓDULO: SAÚDE (PRONTUÁRIOS)
  /// -----------------------------------------------------------------------

  Future<int> salvarOcorrenciaSaude(OcorrenciaSaude ocorrencia) async {
    final db = await instance.database;
    return await db.insert(
      'historico_saude',
      ocorrencia.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<OcorrenciaSaude>> buscarHistoricoSaude() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('historico_saude', orderBy: 'dataDiagnostico DESC');
    return List.generate(maps.length, (i) => OcorrenciaSaude.fromMap(maps[i]));
  }

  /// -----------------------------------------------------------------------
  /// OPERAÇÕES CRUD - MÓDULO: REPRODUÇÃO (CHOCO)
  /// -----------------------------------------------------------------------

  Future<int> salvarCicloReproducao(CicloReproducao ciclo) async {
    final db = await instance.database;
    return await db.insert(
      'ciclos_reproducao',
      ciclo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CicloReproducao>> buscarCiclosAtivos() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('ciclos_reproducao', orderBy: 'dataInicioChoco DESC');
    return List.generate(maps.length, (i) => CicloReproducao.fromMap(maps[i]));
  }
}
