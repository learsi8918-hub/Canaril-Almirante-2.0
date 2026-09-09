class Ave {
  final String anilha;         
  final String clubeSigla;     // Ex: SOGO, OZ, GZ
  final String sexo;           // 'M' ou 'F'
  final String tipoFob;        // Cor ou Porte
  final String mutacaoRaca;    
  final String porteDetalhe;   
  final bool comTopete;        
  final String fotoPath;
  
  // Controle de Localização e Origem Detalhado
  String numeroGaiola;         // Vinculação física no canaril
  final String origemTipo;     // 'Nascido', 'Adquirido', 'Pet Shop'
  final String? nomeCriadorOrigem; // Nome do canaril/criador que vendeu
  final String? clubeCriadorOrigem;// Sigla do clube do criador de origem

  // Histórico Reprodutivo Coletado para os Rankings
  int totalOvos = 0;
  int ovosFerteis = 0;
  int filhotesNascidos = 0;

  // Notas Editáveis do Padrão Ornitológico
  String observacaoMutacao;

  Ave({
    required this.anilha,
    required this.clubeSigla,
    required this.sexo,
    required this.tipoFob,
    required this.mutacaoRaca,
    required this.porteDetalhe,
    required this.comTopete,
    required this.fotoPath,
    required this.numeroGaiola,
    required this.origemTipo,
    this.nomeCriadorOrigem,
    this.clubeCriadorOrigem,
    this.observacaoMutacao = '',
  });

  String get identificadorOficial => '$clubeSigla-$anilha';

  double get taxaFertilidade => totalOvos > 0 ? (ovosFerteis / totalOvos) * 100 : 0.0;

  Map<String, dynamic> toMap() {
    return {
      'anilha': anilha,
      'clubeSigla': clubeSigla,
      'sexo': sexo,
      'tipoFob': tipoFob,
      'mutacaoRaca': mutacaoRaca,
      'porteDetalhe': porteDetalhe,
      'comTopete': comTopete ? 1 : 0,
      'fotoPath': fotoPath,
      'numeroGaiola': numeroGaiola,
      'origemTipo': origemTipo,
      'nomeCriadorOrigem': nomeCriadorOrigem,
      'clubeCriadorOrigem': clubeCriadorOrigem,
      'totalOvos': totalOvos,
      'ovosFerteis': ovosFerteis,
      'filhotesNascidos': filhotesNascidos,
      'observacaoMutacao': observacaoMutacao,
    };
  }

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
      numeroGaiola: map['numeroGaiola'] ?? '',
      origemTipo: map['origemTipo'] ?? 'Nascido no Canaril',
      nomeCriadorOrigem: map['nomeCriadorOrigem'],
      clubeCriadorOrigem: map['clubeCriadorOrigem'],
      observacaoMutacao: map['observacaoMutacao'] ?? '',
    )
      ..totalOvos = map['totalOvos'] ?? 0
      ..ovosFerteis = map['ovosFerteis'] ?? 0
      ..filhotesNascidos = map['filhotesNascidos'] ?? 0;
  }
}
