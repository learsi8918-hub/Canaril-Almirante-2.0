class CicloReproducao {
  final String idGaiola;         // Ex: "Gaiola 15"
  final String sistemaAcasalamento; // "Monogamia", "Bigamia", "Poligamia"
  final String idMacho;          // Identificador Oficial do Reprodutor (Ex: GZ-035)
  final String idFemea;          // Identificador Oficial da Fêmea Matriz (Ex: OZ-012)
  final DateTime dataInicioChoco;
  int quantidadeOvos;
  int ovosFerteis;
  int filhotesVivos;

  CicloReproducao({
    required this.idGaiola,
    required this.sistemaAcasalamento,
    required this.idMacho,
    required this.idFemea,
    required this.dataInicioChoco,
    this.quantidadeOvos = 0,
    this.ovosFerteis = 0,
    this.filhotesVivos = 0,
  });

  DateTime get dataOvoscopia => dataInicioChoco.add(const Duration(days: 7));
  DateTime get dataBanheira => dataInicioChoco.add(const Duration(days: 12));
  DateTime get dataNascimento => dataInicioChoco.add(const Duration(days: 13));
  DateTime get dataAnilhamento => dataInicioChoco.add(const Duration(days: 18));

  Map<String, dynamic> toMap() {
    return {
      'idGaiola': idGaiola,
      'sistemaAcasalamento': sistemaAcasalamento,
      'idMacho': idMacho,
      'idFemea': idFemea,
      'dataInicioChoco': dataInicioChoco.toIso8601String(),
      'quantidadeOvos': quantidadeOvos,
      'ovosFerteis': ovosFerteis,
      'filhotesVivos': filhotesVivos,
    };
  }

  factory CicloReproducao.fromMap(Map<String, dynamic> map) {
    return CicloReproducao(
      idGaiola: map['idGaiola'],
      sistemaAcasalamento: map['sistemaAcasalamento'] ?? 'Monogamia',
      idMacho: map['idMacho'] ?? '',
      idFemea: map['idFemea'] ?? '',
      dataInicioChoco: DateTime.parse(map['dataInicioChoco']),
      quantidadeOvos: map['quantidadeOvos'] ?? 0,
      ovosFerteis: map['ovosFerteis'] ?? 0,
      filhotesVivos: map['filhotesVivos'] ?? 0,
    );
  }
}
