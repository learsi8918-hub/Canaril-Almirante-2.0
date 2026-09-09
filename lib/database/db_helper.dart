import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/ave_model.dart';
import '../models/saude_model.dart';
import '../models/ciclo_model.dart';
import '../models/criador_model.dart';

class DBHelper {
  static const String _dbName = 'canaril_control.db';
  static const int _dbVersion = 2; // Versão incrementada para atualizar tabelas

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
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabela de Aves atualizada com campos detalhados de procedência
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
        origemTipo TEXT,          -- Nascido, Adquirido, PetShop
        canarilProcedencia TEXT,  -- Nome do canaril de origem
        clubeOrigem TEXT,         -- Clube da ave adquirida
        idPaiAnilha TEXT,         -- Para Árvore Genealógica
        idMaeAnilha TEXT,         -- Para Árvore Genealógica
        PRIMARY KEY (clubeSigla, anilha)
      )
    ''');

    await db.execute('''
      CREATE TABLE historico_saude (
        id TEXT PRIMARY KEY,
        identificadorAve TEXT,
        dataDiagnostico TEXT,
        doencaOuSintoma TEXT,
        treatmentoAplicado TEXT,
        statusTratamento TEXT
      )
    ''');

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

    // Nova tabela para persistir o Perfil do Criador e Temas Dinâmicos
    await db.execute('''
      CREATE TABLE perfil_criador (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT,
        clube TEXT,
        logoPath TEXT,
        racasSelecionadas TEXT,   -- Salvo como String separada por vírgulas
        cidade TEXT,
        estado TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Scripts de migração caso o app já estivesse rodando na V1
      await db.execute('ALTER TABLE aves ADD COLUMN origemTipo TEXT;');
      await db.execute('ALTER TABLE aves ADD COLUMN canarilProcedencia TEXT;');
      await db.execute('ALTER TABLE aves ADD COLUMN clubeOrigem TEXT;');
      await db.execute('ALTER TABLE aves ADD COLUMN idPaiAnilha TEXT;');
      await db.execute('ALTER TABLE aves ADD COLUMN idMaeAnilha TEXT;');
      await db.execute('''
        CREATE TABLE perfil_criador (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nome TEXT,
          clube TEXT,
          logoPath TEXT,
          racasSelecionadas TEXT,
          cidade TEXT,
          estado TEXT
        )
      ''');
    }
  }

  /// -----------------------------------------------------------------------
  /// CRUD - CRIPTO/PERFIL DO CRIADOR
  /// -----------------------------------------------------------------------
  Future<int> salvarPerfil(CriadorPerfil perfil) async {
    final db = await instance.database;
    return await db.insert(
      'perfil_criador',
      perfil.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<CriadorPerfil?> buscarPerfil() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('perfil_criador', limit: 1);
    if (maps.isEmpty) return null;
    return CriadorPerfil.fromMap(maps.first);
  }

  /// -----------------------------------------------------------------------
  /// CRUD - AVES (COM RASTREAMENTO DE PAIS PARA GENEALOGIA)
  /// -----------------------------------------------------------------------
  Future<int> salvarAve(Ave ave) async {
    final db = await instance.database;
    return await db.insert('aves', ave.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Ave>> buscarAvesAtivas() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('aves', where: 'status = ?', whereArgs: ['Ativa']);
    return List.generate(maps.length, (i) => Ave.fromMap(maps[i]));
  }

  // Busca recursiva para montar a Árvore Genealógica (Pai e Mãe)
  Future<Map<String, dynamic>> buscarArvoreGenealogica(String anilha) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> resultado = await db.query('aves', where: 'anilha = ?', whereArgs: [anilha], limit: 1);
    
    if (resultado.isEmpty) return {'anilha': anilha, 'erro': 'Não encontrada'};
    
    final ave = resultado.first;
    return {
      'ave': ave['clubeSigla'] + '-' + ave['anilha'] + ' (' + ave['mutacaoRaca'] + ')',
      'pai': ave['idPaiAnilha'] != null ? await buscarArvoreGenealogica(ave['idPaiAnilha']) : 'Pai Desconhecido',
      'mae': ave['idMaeAnilha'] != null ? await buscarArvoreGenealogica(ave['idMaeAnilha']) : 'Mãe Desconhecida',
    };
  }

  /// -----------------------------------------------------------------------
  /// CRUD - MÓDULOS SANITÁRIO E REPRODUTIVO MANTIDOS
  /// -----------------------------------------------------------------------
  Future<int> salvarOcorrenciaSaude(OcorrenciaSaude ocorrencia) async {
    final db = await instance.database;
    return await db.insert('historico_saude', ocorrencia.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<OcorrenciaSaude>> buscarHistoricoSaude() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('historico_saude', orderBy: 'dataDiagnostico DESC');
    return List.generate(maps.length, (i) => OcorrenciaSaude.fromMap(maps[i]));
  }

  Future<int> salvarCicloReproducao(CicloReproducao ciclo) async {
    final db = await instance.database;
    return await db.insert('ciclos_reproducao', ciclo.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<CicloReproducao>> buscarCiclosAtivos() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('ciclos_reproducao', orderBy: 'dataInicioChoco DESC');
    return List.generate(maps.length, (i) => CicloReproducao.fromMap(maps[i]));
  }
}
