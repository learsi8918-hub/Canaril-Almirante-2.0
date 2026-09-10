class Ave {
  final String anilha;         
  final String clubeSigla;      // Strict: 2 letras (Ex: OZ, GZ, GO)
  final String sexo;            // 'M' ou 'F'
  final String segmentoFob;     // 'Cor', 'Porte' ou 'Canto'
  final String variacao;        // Ex: Amarelo Mosaico, Arlequim Português, Timbrado Espanhol
  final String mutacaoEscrita;  // Ex: Portador de Jaspe
  final bool comTopete;         // Identificador para trava letal homozigótica
  String numeroGaiola;         
  final String origemTipo;      // 'Nascido no Canaril', 'Adquirido de Outro Canaril', 'Pet Shop / Loja de Animais'
  final String? nomeCriadorOrigem;
  final String? clubeOrigem;       
  final String? idPaiAnilha;       
  final String? idMaeAnilha;       
  String status;                // Macho: Reprodução, Em Tratamento | Fêmea: Descanso, Choco, Postura, Com Filhotes

  // Estatísticas Reais Acumuladas (Sem exemplos fixos)
  int totalOvos = 0;
  int ovosFerteis = 0;
  int filhotesNascidos = 0;
  int abandonosNinho = 0;
  String observacoes;

  Ave({
    required this.anilha,
    required this.clubeSigla,
    required this.sexo,
    required this.segmentoFob,
    required this.variacao,
    required this.mutacaoEscrita,
    required this.comTopete,
    required this.numeroGaiola,
    required this.origemTipo,
    this.nomeCriadorOrigem,
    this.clubeOrigem,
    this.idPaiAnilha,
    this.idMaeAnilha,
    required this.status,
    this.observacoes = '',
  });

  String get identificadorOficial => '$clubeSigla-$anilha';
  double get taxaFertilidade => totalOvos > 0 ? (ovosFerteis / totalOvos) * 100 : 0.0;
  double get taxaNascimento => ovosFerteis > 0 ? (filhotesNascidos / ovosFerteis) * 100 : 0.0;

  Map<String, dynamic> toMap() {
    return {
      'anilha': anilha,
      'clubeSigla': clubeSigla,
      'sexo': sexo,
      'segmentoFob': segmentoFob,
      'variacao': variacao,
      'mutacaoEscrita': mutacaoEscrita,
      'comTopete': comTopete ? 1 : 0,
      'numeroGaiola': numeroGaiola,
      'origemTipo': origemTipo,
      'nomeCriadorOrigem': nomeCriadorOrigem,
      'clubeOrigem': clubeOrigem,
      'idPaiAnilha': idPaiAnilha,
      'idMaeAnilha': idMaeAnilha,
      'status': status,
      'totalOvos': totalOvos,
      'ovosFerteis': ovosFerteis,
      'filhotesNascidos': filhotesNascidos,
      'abandonosNinho': abandonosNinho,
      'observacoes': observacoes,
    };
  }

  factory Ave.fromMap(Map<String, dynamic> map) {
    return Ave(
      anilha: map['anilha'] ?? '',
      clubeSigla: map['clubeSigla'] ?? '',
      sexo: map['sexo'] ?? 'M',
      segmentoFob: map['segmentoFob'] ?? 'Canário de Cor',
      variacao: map['variacao'] ?? '',
      mutacaoEscrita: map['mutacaoEscrita'] ?? '',
      comTopete: map['comTopete'] == 1,
      numeroGaiola: map['numeroGaiola'] ?? '',
      origemTipo: map['origemTipo'] ?? 'Nascido no Canaril',
      nomeCriadorOrigem: map['nomeCriadorOrigem'],
      clubeOrigem: map['clubeOrigem'],
      idPaiAnilha: map['idPaiAnilha'],
      idMaeAnilha: map['idMaeAnilha'],
      status: map['status'] ?? 'Descanso',
      observacoes: map['observacoes'] ?? '',
    )
      ..totalOvos = map['totalOvos'] ?? 0
      ..ovosFerteis = map['ovosFerteis'] ?? 0
      ..filhotesNascidos = map['filhotesNascidos'] ?? 0
      ..abandonosNinho = map['abandonosNinho'] ?? 0;
  }
}

class CatalogoOficialFOB {
  static const List<String> segmentos = ['Canário de Cor', 'Canário de Porte', 'Canário de Canto'];
  static const List<String> variacoesCor = ['Branco Dominante', 'Branco Recessivo', 'Amarelo Intenso', 'Amarelo Mosaico', 'Vermelho Intenso', 'Vermelho Mosaico', 'Cobre Intenso', 'Ágata Prata'];
  static const List<String> variacoesPorte = ['Arlequim Português', 'Gloster Corona', 'Gloster Consort', 'Raza Española', 'Fife Fancy', 'Lizard Oro'];
  static const List<String> variacoesCanto = ['Timbrado Espanhol', 'Harzer Roller', 'Malinois Waterslager'];
}
