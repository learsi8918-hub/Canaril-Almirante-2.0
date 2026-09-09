/// -----------------------------------------------------------------------
/// MODELO DE DADOS DE REPRODUÇÃO (CALCULADORA BIOLÓGICA DE CHOCO)
/// -----------------------------------------------------------------------

class CicloReproducao {
  final String idGaiola;
  final String idMacho;          // Clube-Anilha do Macho
  final String idFemea;          // Clube-Anilha da Fêmea
  final DateTime dataInicioChoco;
  int quantidadeOvos;
  int ovosFerteis;
  int filhotesVivos;
  String tipoManejoMacho;        // "Sempre Junto", "Separado no 3º Ovo", "Gaiola Divisória"

  CicloReproducao({
    required this.idGaiola,
    required this.idMacho,
    required this.idFemea,
    required this.dataInicioChoco,
    this.quantidadeOvos = 0,
    this.ovosFerteis = 0,
    this.filhotesVivos = 0,
    required this.tipoManejoMacho,
  });

  // Gatilhos biológicos automatizados baseados na data do choco
  DateTime get dataOvoscopia => dataInicioChoco.add(const Duration(days: 7));
  DateTime get dataBanheira => dataInicioChoco.add(const Duration(days: 12));
  DateTime get dataNascimento => dataInicioChoco.add(const Duration(days: 13));
  DateTime get dataAnilhamento => dataInicioChoco.add(const Duration(days: 18));

  /// -----------------------------------------------------------------------
  /// MAPEAMENTO SERIALIZADOR PARA PERSISTÊNCIA NO SQLITE
  /// -----------------------------------------------------------------------

  // Converte as informações do choco em um Mapa para salvar no SQLite
  Map<String, dynamic> toMap() {
    return {
      'idGaiola': idGaiola,
      'idMacho': idMacho,
      'idFemea': idFemea,
      'dataInicioChoco': dataInicioChoco.toIso8601String(), // Convertido para texto ISO
      'quantidadeOvos': quantidadeOvos,
      'ovosFerteis': ovosFerteis,
      'filhotesVivos': filhotesVivos,
      'tipoManejoMacho': tipoManejoMacho,
    };
  }

  // Reconstrói as informações do choco vindas em formato de Mapa do SQLite
  factory CicloReproducao.fromMap(Map<String, dynamic> map) {
    return CicloReproducao(
      idGaiola: map['idGaiola'],
      idMacho: map['idMacho'],
      idFemea: map['idFemea'],
      dataInicioChoco: DateTime.parse(map['dataInicioChoco']),
      quantidadeOvos: map['quantidadeOvos'] ?? 0,
      ovosFerteis: map['ovosFerteis'] ?? 0,
      filhotesVivos: map['filhotesVivos'] ?? 0,
      tipoManejoMacho: map['tipoManejoMacho'] ?? 'Sempre Junto',
    );
  }
}
