/// -----------------------------------------------------------------------
/// MODELO DE DADOS DA AVE E CONFIGURAÇÃO FOB (ANTI-TRAVAMENTO)
/// -----------------------------------------------------------------------

class Ave {
  final String anilha;         // Número da anilha
  final String clubeSigla;     // Sigla do clube (Ex: FOB, SO)
  final String sexo;           // 'M' (Macho) ou 'F' (Fêmea)
  final String tipoFob;        // 'Canário de Cor' ou 'Canário de Porte'
  final String mutacaoRaca;    // Ex: Vermelho Mosaico, Arlequim Português
  final String porteDetalhe;   // 'Com Topete' ou 'Sem Topete'
  final bool comTopete;        // Trava para evitar fator letal homozigótico
  final String fotoPath;
  
  // Regras de mutações avançadas e fatores genéticos
  final bool ehPortador;       
  final String? mutacaoPortada;
  final String fatorMorfologico; // 'Fator Puro' ou 'Meio Fator'

  // Controle de Ciclo de Vida (Baixas do Plantel)
  String status;               // 'Ativa', 'Vendida', 'Doada', 'Morta'
  DateTime? dataBaixa;         
  String? motivoBaixaDetalhe;  

  // Estatísticas Acumuladas para o Ranking de Produtividade
  int totalOvos = 0;
  int ovosFerteis = 0;
  int filhotesNascidos = 0;

  Ave({
    required this.anilha,
    required this.clubeSigla,
    required this.sexo,
    required this.tipoFob,
    required this.mutacaoRaca,
    required this.porteDetalhe,
    required this.comTopete,
    required this.fotoPath,
    this.ehPortador = false,
    this.mutacaoPortada,
    this.fatorMorfologico = 'Fator Puro',
    this.status = 'Ativa',
    this.dataBaixa,
    this.motivoBaixaDetalhe,
  });

  // Identificador único ornitológico legível (Ex: "SO-012")
  String get identificadorOficial => '$clubeSigla-$anilha';

  // Getters Inteligentes para os Rankings do Painel Analytics
  double get taxaFertilidade => totalOvos > 0 ? (ovosFerteis / totalOvos) * 100 : 0.0;
  double get taxaEclosao => ovosFerteis > 0 ? (filhotesNascidos / ovosFerteis) * 100 : 0.0;

  /// -----------------------------------------------------------------------
  /// MAPEAMENTO SERIALIZADOR PARA PERSISTÊNCIA NO SQLITE
  /// -----------------------------------------------------------------------

  // Converte o objeto Ave em um Mapa (JSON/Dicionário) para salvar no SQLite
  Map<String, dynamic> toMap() {
    return {
      'anilha': anilha,
      'clubeSigla': clubeSigla,
      'sexo': sexo,
      'tipoFob': tipoFob,
      'mutacaoRaca': mutacaoRaca,
      'porteDetalhe': porteDetalhe,
      'comTopete': comTopete ? 1 : 0, // SQLite não guarda booleano, usamos 1 ou 0
      'fotoPath': fotoPath,
      'ehPortador': ehPortador ? 1 : 0,
      'mutacaoPortada': mutacaoPortada,
      'fatorMorfologico': fatorMorfologico,
      'status': status,
      'dataBaixa': dataBaixa?.toIso8601String(), // Datas viram texto ISO
      'motivoBaixaDetalhe': motivoBaixaDetalhe,
      'totalOvos': totalOvos,
      'ovosFerteis': ovosFerteis,
      'filhotesNascidos': filhotesNascidos,
    };
  }

  // Reconstrói o objeto Ave a partir dos dados em formato de Mapa vindos do SQLite
  factory Ave.fromMap(Map<String, dynamic> map) {
    return Ave(
      anilha: map['anilha'],
      clubeSigla: map['clubeSigla'],
      sexo: map['sexo'],
      tipoFob: map['tipoFob'],
      mutacaoRaca: map['mutacaoRaca'],
      porteDetalhe: map['porteDetalhe'],
      comTopete: map['comTopete'] == 1,
      fotoPath: map['fotoPath'] ?? '',
      ehPortador: map['ehPortador'] == 1,
      mutacaoPortada: map['mutacaoPortada'],
      fatorMorfologico: map['fatorMorfologico'] ?? 'Fator Puro',
      status: map['status'] ?? 'Ativa',
      dataBaixa: map['dataBaixa'] != null ? DateTime.parse(map['dataBaixa']) : null,
      motivoBaixaDetalhe: map['motivoBaixaDetalhe'],
    )
      ..totalOvos = map['totalOvos'] ?? 0
      ..ovosFerteis = map['ovosFerteis'] ?? 0
      ..filhotesNascidos = map['filhotesNascidos'] ?? 0;
  }
}

/// -----------------------------------------------------------------------
/// BANCO DE DADOS FIXO DE PADRÕES DA FEDERAÇÃO (FOB)
/// -----------------------------------------------------------------------
class BancoDadosFOB {
  static const List<String> categorias = ['Canário de Cor', 'Canário de Porte'];
  static const List<String> mutacoesCor = [
    'Branco Dominante', 'Branco Recessivo', 'Amarelo Intenso', 'Amarelo Nevado', 
    'Amarelo Mosaico', 'Vermelho Intenso', 'Vermelho Nevado', 'Vermelho Mosaico', 
    'Verde (Negro Amarelo)', 'Azul (Negro Branco)', 'Cobre (Negro Vermelho)', 
    'Ágata Amarelo', 'Ágata Prata', 'Ágata Vermelho Mosaico', 'Isabel', 'Canela'
  ];
  static const List<String> racasPorte = [
    'Arlequim Português', 'Gloster Corona', 'Gloster Consort', 'Raza Española', 
    'Fife Fancy', 'Lizard Oro', 'Lizard Plata', 'Border', 'Fiorino'
  ];
}
