class Ave {
  final String anilha;         
  final String clubeSigla;     
  final String sexo;           
  final String tipoFob;        
  final String mutacaoRaca;    
  final String porteDetalhe;   
  final bool comTopete;        
  final String fotoPath;
  
  final bool ehPortador;       
  final String? mutacaoPortada;
  final String fatorMorfologico; 

  // Novas Regras de Controle de Plantel Avançado e Origem
  final String origemTipo;         // 'Nascido no Canaril', 'Adquirido de Outro Canaril', 'Pet Shop / Loja'
  final String? canarilProcedencia;// Nome do criatório de onde veio
  final String? clubeOrigem;       // Clube associado da ave comprada

  // Mapeamento de Filiação (Árvore Genealógica)
  final String? idPaiAnilha;       
  final String? idMaeAnilha;       

  String status;               
  DateTime? dataBaixa;         
  String? motivoBaixaDetalhe;  

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
    required this.origemTipo,
    this.canarilProcedencia,
    this.clubeOrigem,
    this.idPaiAnilha,
    this.idMaeAnilha,
    this.ehPortador = false,
    this.mutacaoPortada,
    this.fatorMorfologico = 'Fator Puro',
    this.status = 'Ativa',
    this.dataBaixa,
    this.motivoBaixaDetalhe,
  });

  String get identificadorOficial => '$clubeSigla-$anilha';

  double get taxaFertilidade => totalOvos > 0 ? (ovosFerteis / totalOvos) * 100 : 0.0;
  double get taxaEclosao => ovosFerteis > 0 ? (filhotesNascidos / ovosFerteis) * 100 : 0.0;

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
      'ehPortador': ehPortador ? 1 : 0,
      'mutacaoPortada': mutacaoPortada,
      'fatorMorfologico': fatorMorfologico,
      'status': status,
      'dataBaixa': dataBaixa?.toIso8601String(), 
      'motivoBaixaDetalhe': motivoBaixaDetalhe,
      'totalOvos': totalOvos,
      'ovosFerteis': ovosFerteis,
      'filhotesNascidos': filhotesNascidos,
      'origemTipo': origemTipo,
      'canarilProcedencia': canarilProcedencia,
      'clubeOrigem': clubeOrigem,
      'idPaiAnilha': idPaiAnilha,
      'idMaeAnilha': idMaeAnilha,
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
      ehPortador: map['ehPortador'] == 1,
      mutacaoPortada: map['mutacaoPortada'],
      fatorMorfologico: map['fatorMorfologico'] ?? 'Fator Puro',
      status: map['status'] ?? 'Ativa',
      dataBaixa: map['dataBaixa'] != null ? DateTime.parse(map['dataBaixa']) : null,
      motivoBaixaDetalhe: map['motivoBaixaDetalhe'],
      origemTipo: map['origemTipo'] ?? 'Nascido no Canaril',
      canarilProcedencia: map['canarilProcedencia'],
      clubeOrigem: map['clubeOrigem'],
      idPaiAnilha: map['idPaiAnilha'],
      idMaeAnilha: map['idMaeAnilha'],
    )
      ..totalOvos = map['totalOvos'] ?? 0
      ..ovosFerteis = map['ovosFerteis'] ?? 0
      ..filhotesNascidos = map['filhotesNascidos'] ?? 0;
  }
}

class BancoDadosFOB {
  static const List<String> categorias = ['Canário de Cor', 'Canário de Porte'];
  static const List<String> mutacoesCor = [
    'Branco Dominante', 'Branco Recessivo', 'Amarelo Mosaico', 'Vermelho Mosaico', 'Ágata Amarelo', 'Cobre'
  ];
  static const List<String> racasPorte = [
    'Arlequim Português', 'Gloster Corona', 'Gloster Consort', 'Raza Española', 'Fife Fancy'
  ];
}
