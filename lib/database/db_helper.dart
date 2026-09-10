import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/ave_model.dart';
import '../models/saude_model.dart';
import '../models/ciclo_model.dart';
import '../models/criador_model.dart';

class DBHelper {
  static const String _dbName = 'canaril_control_pro.db';
  static const int _dbVersion = 3; // Upgrade de versão para suporte a gatilhos automáticos

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

  Future<void> _onCreate(Database db, int version) async {
    // 1. Tabela de Perfil do Criador (Suporte a Logo e Cores Customizadas)
    await db.execute('''
      CREATE TABLE perfil_criador (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        siglaClube TEXT NOT NULL, -- Validação de 2 letras na UI
        logoPath TEXT NOT NULL,    -- Caminho ou HEX extraído da cor
        cidade TEXT NOT NULL,
        estado TEXT NOT NULL
      )
    ''');

    // 2. Tabela de Aves (Com trava de topete, rastreamento de origem, filiação e gaiola)
    await db.execute('''
      CREATE TABLE aves (
        anilha TEXT NOT NULL,
        clubeSigla TEXT NOT NULL, -- Strict: 2 letras
        sexo TEXT NOT NULL,       -- M ou F
        segmentoFob TEXT NOT NULL, -- Cor, Porte, Canto
        variacao TEXT NOT NULL,   -- Amarelo Mosaico, Arlequim Português, etc.
        mutacaoEscrita TEXT,      -- Portador de Jaspe, etc.
        comTopete INTEGER NOT NULL,-- 1 = Sim, 0 = Não
        numeroGaiola TEXT NOT NULL,
        origemTipo TEXT NOT NULL,  -- Nascido, Adquirido, PetShop
        nomeCriadorOrigem TEXT,
        clubeOrigem TEXT,
        status TEXT NOT NULL,     // Macho: Reprodução, Tratamento | Fêmea: Descanso, Choco, Postura, com Filhotes
        idPaiAnilha TEXT,         -- Para Árvore Genealógica
        idMaeAnilha TEXT,         -- Para Árvore Genealógica
        totalOvos INTEGER DEFAULT 0,
        ovosFerteis INTEGER DEFAULT 0,
        filhotesNascidos INTEGER DEFAULT 0,
        abandonosNinho INTEGER DEFAULT 0,
        observacoes TEXT,
        PRIMARY KEY (clubeSigla, anilha)
      )
    ''');

    // 3. Tabela de Reprodução Avançada (Suporte a Monogamia, Bigamia e Poligamia de Gaiola)
    await db.execute('''
      CREATE TABLE ciclos_reproducao (
        idGaiola TEXT NOT NULL,
        sistemaAcasalamento TEXT NOT NULL, -- Monogamia, Bigamia, Poligamia
        idMacho TEXT NOT NULL,              -- Clube-Anilha
        idFemea TEXT NOT NULL,              -- Clube-Anilha
        tipoManejoMacho TEXT NOT NULL,      -- Sempre Junto, 3º Ovo, Janela_Copula (5h-9h)
        dataInicioChoco TEXT NOT NULL,
        quantidadeOvos INTEGER DEFAULT 0,
        ovosFerteis INTEGER DEFAULT 0,
        filhotesVivos INTEGER DEFAULT 0,
        PRIMARY KEY (idGaiola, idFemea)     -- Permite mais de uma fêmea na mesma gaiola (Bigamia)
      )
    ''');

    // 4. Tabela Sanitária (Controle de ciclos de remédio e tratamentos)
    await db.execute('''
      CREATE TABLE historico_saude (
        id TEXT PRIMARY KEY,
        identificadorAve TEXT NOT NULL,
        dataDiagnostico TEXT NOT NULL,
        doencaOuSintoma TEXT NOT NULL,
        tratamentoAplicado TEXT NOT NULL,
        duracaoDias INTEGER DEFAULT 5,     -- Ciclos padrão (Ex: 5 dias)
        statusTratamento TEXT NOT NULL     -- Em Tratamento, Curado, Óbito
      )
    ''');
  }

  /// -----------------------------------------------------------------------
  /// OPERAÇÕES DO BANCO DE DADOS (RESOLUÇÃO DE CONFLITOS DE GRAVAÇÃO)
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

  Future<int> salvarAve(Ave ave) async {
    final db = await instance.database;
    return await db.insert(
      'aves',
      ave.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // Corrige a trava de não permitir salvar atualizando o registro
    );
  }

  Future<List<Ave>> buscarAvesAtivas() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('aves');
    return List.generate(maps.length, (i) => Ave.fromMap(maps[i]));
  }

  /// -----------------------------------------------------------------------
  /// ALGORITMO RECURSIVO EXCLUSIVO DA ÁRVORE GENEALÓGICA DO FILHOTE
  /// -----------------------------------------------------------------------
  Future<Map<String, dynamic>> obterArvoreGenealogica(String clubeSigla, String anilha) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> resultado = await db.query(
      'aves',
      where: 'clubeSigla = ? AND anilha = ?',
      whereArgs: [clubeSigla, anilha],
      limit: 1,
    );

    if (resultado.isEmpty) {
      return {'identificador': '$clubeSigla-$anilha', 'variacao': 'Sem registro ancestral'};
    }

    final ave = resultado.first;
    final String? paiAnilha = ave['idPaiAnilha'];
    final String? maeAnilha = ave['idMaeAnilha'];

    return {
      'identificador': '$clubeSigla-$anilha',
      'variacao': ave['variacao'],
      'mutacao': ave['mutacaoEscrita'] ?? '',
      'pai': paiAnilha != null ? await obterArvoreGenealogica(clubeSigla, paiAnilha) : 'Pai Desconhecido',
      'mae': maeAnilha != null ? await obterArvoreGenealogica(clubeSigla, maeAnilha) : 'Mãe Desconhecida',
    };
  }

  // Métodos Sanitários e de Ciclos
  Future<int> salvarCicloReproducao(CicloReproducao ciclo) async {
    final db = await instance.database;
    return await db.insert('ciclos_reproducao', ciclo.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<CicloReproducao>> buscarCiclosAtivos() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('ciclos_reproducao');
    return List.generate(maps.length, (i) => CicloReproducao.fromMap(maps[i]));
  }
}
