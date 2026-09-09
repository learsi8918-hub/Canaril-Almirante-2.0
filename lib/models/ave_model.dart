class Ave {
  final String anilha;         // Número da anilha
  final String clubeSigla;     // Sigla do clube (Ex: FOB, SO)
  final String sexo;           // 'M' (Macho) ou 'F' (Fêmea)
  final String tipoFob;        // 'Canário de Cor' ou 'Canário de Porte'
  final String mutacaoRaca;    // Ex: Vermelho Mosaico, Arlequim Português
  final String porteDetalhe;   // 'Com Topete' ou 'Sem Topete'
  final bool comTopete;        // Trava para evitar fator letal homozigótico
  final String fotoPath;
  
  // Regras de mutações avançadas
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

  String get identificadorOficial => '$clubeSigla-$anilha';

  double get taxaFertilidade => totalOvos > 0 ? (ovosFerteis / totalOvos) * 100 : 0.0;
  double get taxaEclosao => ovosFerteis > 0 ? (filhotesNascidos / ovosFerteis) * 100 : 0.0;
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
