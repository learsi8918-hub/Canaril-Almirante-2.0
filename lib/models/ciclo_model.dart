class CicloReproducao {
  final String idGaiola;         
  final String sistemaAcasalamento; 
  final String idMacho;          
  final String idFemea;          
  final DateTime dataInicioChoco;
  final String tipoManejoMacho;  // Sempre Junto, Sai no 3º Ovo, Janela_Copula
  int quantidadeOvos;
  int ovosFerteis;
  int filhotesVivos;

  CicloReproducao({
    required this.idGaiola,
    required this.sistemaAcasalamento,
    required this.idMacho,
    required this.idFemea,
    required this.dataInicioChoco,
    required this.tipoManejoMacho,
    this.quantidadeOvos = 0,
    this.ovosFerteis = 0,
    this.filhotesVivos = 0,
  });

  DateTime get dataOvoscopia => dataInicioChoco.add(const Duration(days: 7));
  DateTime get dataBanheira => dataInicioChoco.add(const Duration(days: 12));
  DateTime get dataNascimento => dataInicioChoco.add(const Duration(days: 13));

  Map<String, dynamic> toMap() {
    return {
      'idGaiola': idGaiola,
      'sistemaAcasalamento': sistemaAcasalamento,
      'idMacho': idMacho,
      'idFemea': idFemea,
      'dataInicioChoco': dataInicioChoco.toIso8601String(),
      'tipoManejoMacho': tipoManejoMacho,
      'quantidadeOvos': quantidadeOvos,
      'ovosFerteis': ovosFerteis,
      'filhotesVivos': filhotesVivos,
    };
  }

  factory CicloReproducao.fromMap(Map<String, dynamic> map) {
    return CicloReproducao(
      idGaiola: map['idGaiola'] ?? '',
      sistemaAcasalamento: map['sistemaAcasalamento'] ?? 'Monogamia',
      idMacho: map['idMacho'] ?? '',
      idFemea: map['idFemea'] ?? '',
      dataInicioChoco: DateTime.parse(map['dataInicioChoco']),
      tipoManejoMacho: map['tipoManejoMacho'] ?? 'Sempre Junto',
      quantidadeOvos: map['quantidadeOvos'] ?? 0,
      ovosFerteis: map['ovosFerteis'] ?? 0,
      filhotesVivos: map['filhotesVivos'] ?? 0,
    );
  }
}
