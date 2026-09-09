class OcorrenciaSaude {
  final String id;
  final String identificadorAve; // Conecta com o identificadorOficial (Clube-Anilha)
  final DateTime dataDiagnostico;
  final String doencaOuSintoma;
  final String tratamentoAplicado;
  String statusTratamento;       // 'Em Tratamento', 'Curado', 'Morta (Sequela)'

  OcorrenciaSaude({
    required this.id,
    required this.identificadorAve,
    required this.dataDiagnostico,
    required this.doencaOuSintoma,
    required this.tratamentoAplicado,
    required this.statusTratamento,
  });
}
