import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/ave_model.dart';
import '../models/saude_model.dart';
import '../models/ciclo_model.dart';
import '../models/criador_model.dart';

class DBHelper {
  static const String _dbName = 'canaril_control_pro.db';
  static const int _dbVersion = 3;

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
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE perfil_criador (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        siglaClube TEXT NOT NULL,
        logoPath TEXT NOT NULL,
        cidade TEXT NOT NULL,
        estado TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE aves (
        anilha TEXT NOT NULL,
        clubeSigla TEXT NOT NULL,
        sexo TEXT NOT NULL,
        segmentoFob TEXT NOT NULL,
        variacao TEXT NOT NULL,
        mutacaoEscrita TEXT,
        comTopete INTEGER NOT NULL,
        numeroGaiola TEXT NOT NULL,
        origemTipo TEXT NOT NULL,
        nomeCriadorOrigem TEXT,
        clubeOrigem TEXT,
        status TEXT NOT NULL,
        idPaiAnilha TEXT,
        idMaeAnilha TEXT,
        totalOvos INTEGER DEFAULT 0,
        ovosFerteis INTEGER DEFAULT 0,
        filhotesNascidos INTEGER DEFAULT 0,
        abandonosNinho INTEGER DEFAULT 0,
        observacoes TEXT,
        PRIMARY KEY (clubeSigla, anilha)
      )
    ''');

    await db.execute('''
      CREATE TABLE ciclos_reproducao (
        idGaiola TEXT NOT NULL,
        sistemaAcasalamento TEXT NOT NULL,
        idMacho TEXT NOT NULL,
        idFemea TEXT NOT NULL,
        tipoManejoMacho TEXT NOT NULL,
        dataInicioChoco TEXT NOT NULL,
        quantidadeOvos INTEGER DEFAULT 0,
        ovosFerteis INTEGER DEFAULT 0,
        filhotesVivos INTEGER DEFAULT 0,
        PRIMARY KEY (idGaiola, idFemea)
      )
    ''');

    await db.execute('''
      CREATE TABLE historico_saude (
        id TEXT PRIMARY KEY,
        identificadorAve TEXT NOT NULL,
        dataDiagnostico TEXT NOT NULL,
        doencaOuSintoma TEXT NOT NULL,
        tratamentoAplicado TEXT NOT NULL,
        duracaoDias INTEGER DEFAULT 5,
        statusTratamento TEXT NOT NULL
      )
    ''');
  }

  Future<int> salvarPerfil(CriadorPerfil perfil) async {
    final db = await instance.database;
    return await db.insert('perfil_criador', perfil.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<CriadorPerfil?> buscarPerfil() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('perfil_criador', limit: 1);
    if (maps.isEmpty) return null;
    return CriadorPerfil.fromMap(maps.first);
  }

  Future<int> salvarAve(Ave ave) async {
    final db = await instance.database;
    return await db.insert('aves', ave.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Ave>> buscarAvesAtivas() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('aves');
    return List.generate(maps.length, (i) => Ave.fromMap(maps[i]));
  }

  Future<int> salvarCicloReproducao(CicloReproducao ciclo) async {
    final db = await instance.database;
    return await db.insert('ciclos_reproducao', ciclo.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<CicloReproducao>> buscarCiclosAtivos() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('ciclos_reproducao');
    return List.generate(maps.length, (i) => CicloReproducao.fromMap(maps[i]));
  }

  Future<int> salvarOcorrenciaSaude(OcorrenciaSaude ocorrencia) async {
    final db = await instance.database;
    return await db.insert('historico_saude', ocorrencia.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<OcorrenciaSaude>> buscarHistoricoSaude() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('historico_saude', orderBy: 'dataDiagnostico DESC');
    return List.generate(maps.length, (i) => OcorrenciaSaude.fromMap(maps[i]));
  }
}
