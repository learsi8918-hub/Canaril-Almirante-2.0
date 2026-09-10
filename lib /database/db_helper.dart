import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/ave_model.dart';
import '../models/criador_model.dart';

class DbHelper {
  DbHelper._(); static final instance=DbHelper._(); Database? _db;
  Future<Database> get db async=>_db??=await _open();
  Future<Database> _open() async { final p=join(await getDatabasesPath(),'canary_control_pro.db'); return openDatabase(p,version:2,onCreate:_create,onUpgrade:(d,oldV,newV) async {if(oldV<2){await d.execute('ALTER TABLE criador ADD COLUMN senha_hash TEXT');}}); }
  Future<void> _create(Database d,int v) async {
    await d.execute('CREATE TABLE criador(id INTEGER PRIMARY KEY AUTOINCREMENT,nome TEXT NOT NULL,sigla_clube TEXT NOT NULL,cidade TEXT,estado TEXT,logo_path TEXT,senha_hash TEXT)');
    await d.execute('CREATE TABLE aves(id INTEGER PRIMARY KEY AUTOINCREMENT,clube_sigla TEXT NOT NULL,anilha TEXT NOT NULL,ano_nascimento TEXT,sexo TEXT NOT NULL,nome TEXT,segmento_fob TEXT,raca TEXT,mutacao TEXT,categoria_plumagem TEXT,mutacao_escrita TEXT,com_topete INTEGER DEFAULT 0,numero_gaiola TEXT,origem_tipo TEXT,status TEXT,pai_id INTEGER,mae_id INTEGER,observacoes TEXT, UNIQUE(clube_sigla,anilha))');
    await d.execute('CREATE TABLE ciclos(id INTEGER PRIMARY KEY AUTOINCREMENT,sistema TEXT NOT NULL,manejo_macho TEXT,data_inicio TEXT)');
    await d.execute('CREATE TABLE ciclo_femeas(id INTEGER PRIMARY KEY AUTOINCREMENT,ciclo_id INTEGER NOT NULL,femea_id INTEGER NOT NULL,macho_id INTEGER NOT NULL,gaiola TEXT NOT NULL,data_juntamento TEXT NOT NULL,UNIQUE(ciclo_id,femea_id))');
    await d.execute('CREATE TABLE posturas(id INTEGER PRIMARY KEY AUTOINCREMENT,ciclo_femea_id INTEGER NOT NULL,numero INTEGER,data_primeiro_ovo TEXT,data_ovoscopia TEXT,data_nascimento_prevista TEXT,data_anilhamento_prevista TEXT,data_desmame_prevista TEXT,observacao TEXT)');
    await d.execute('CREATE TABLE ovos(id INTEGER PRIMARY KEY AUTOINCREMENT,postura_id INTEGER NOT NULL,femea_id INTEGER NOT NULL,numero INTEGER,data_postura TEXT,resultado_ovoscopia TEXT)');
    await d.execute('CREATE TABLE filhotes(id INTEGER PRIMARY KEY AUTOINCREMENT,ovo_id INTEGER,pai_id INTEGER,mae_id INTEGER,data_nascimento TEXT,sexo TEXT,clube_sigla TEXT,anilha TEXT,numero_gaiola TEXT,pigmentacao TEXT,data_anilhamento TEXT,data_desmame TEXT,status TEXT,observacoes TEXT)');
    await d.execute('CREATE TABLE baixas(id INTEGER PRIMARY KEY AUTOINCREMENT,ave_id INTEGER NOT NULL,data TEXT NOT NULL,motivo TEXT NOT NULL,numero_anilha TEXT,clube_sigla TEXT,observacao TEXT)');
    await d.execute('CREATE TABLE lembretes(id INTEGER PRIMARY KEY AUTOINCREMENT,tipo TEXT,titulo TEXT,data_hora TEXT NOT NULL,ave_id INTEGER,ciclo_id INTEGER,status TEXT DEFAULT "agendado")');
    await d.execute('CREATE TABLE saude(id INTEGER PRIMARY KEY AUTOINCREMENT,ave_id INTEGER,data_diagnostico TEXT,doenca_sintoma TEXT,tratamento TEXT,duracao_dias INTEGER,status TEXT)');
    await d.execute('CREATE TABLE retrocruzamentos(id INTEGER PRIMARY KEY AUTOINCREMENT,individuo_id INTEGER NOT NULL,alvo_id INTEGER NOT NULL,geracao INTEGER NOT NULL,observacoes TEXT)');
  }
  Future<Criador?> criador() async {final rows=await (await db).query('criador',limit:1);return rows.isEmpty?null:Criador.fromMap(rows.first);}
  Future<int> salvarCriador(Criador c) async {final d=await db; if(c.id==null)return d.insert('criador',c.toMap()); return d.update('criador',c.toMap(),where:'id=?',whereArgs:[c.id]);}
  Future<int> upsertAve(Ave a) async {final d=await db; return d.insert('aves',a.toMap(),conflictAlgorithm:ConflictAlgorithm.replace);}
  Future<List<Ave>> aves() async {final rows=await (await db).query('aves',orderBy:'id DESC');return rows.map(Ave.fromMap).toList();}
  Future<Map<String,dynamic>> resumo() async {final d=await db; final a=Sqflite.firstIntValue(await d.rawQuery('SELECT COUNT(*) FROM aves'))??0; final ovos=Sqflite.firstIntValue(await d.rawQuery('SELECT COUNT(*) FROM ovos'))??0; final fert=Sqflite.firstIntValue(await d.rawQuery("SELECT COUNT(*) FROM ovos WHERE resultado_ovoscopia='Fértil'"))??0; return {'aves':a,'ovos':ovos,'ferteis':fert,'fertilidade':ovos==0?0:(fert*100/ovos)};}
}
