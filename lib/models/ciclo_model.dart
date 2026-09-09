class CicloReproducao {
  final String idGaiola;
  final String idMacho; // Clube-Anilha do Macho
  final String idFemea; // Clube-Anilha da Fêmea
  final DateTime dataInicioChoco;
  int quantidadeOvos;
  int ovosFerteis;
  int filhotesVivos;
  String tipoManejoMacho; // "Sempre Junto", "Separado no 3º Ovo", "Gaiola Divisória"

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
}
