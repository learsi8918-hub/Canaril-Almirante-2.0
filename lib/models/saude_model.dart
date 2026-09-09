/// -----------------------------------------------------------------------
/// MODELO DE DADOS DA FICHA MÉDICA (SANIDADE DO PLANTEL)
/// -----------------------------------------------------------------------

class OcorrenciaSaude {
  final String id;
  final String identificadorAve; // Conecta com o identificadorOficial da Ave (Clube-Anilha)
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

  /// -----------------------------------------------------------------------
  /// MAPEAMENTO SERIALIZADOR PARA PERSISTÊNCIA NO SQLITE
  /// -----------------------------------------------------------------------

  // Converte o prontuário em um Mapa (JSON/Dicionário) para salvar no banco
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'identificadorAve': identificadorAve,
      'dataDiagnostico': dataDiagnostico.toIso8601String(), // Datas viram texto ISO
      'doencaOuSintoma': doencaOuSintoma,
      'tratamentoAplicado': tratamentoAplicado,
      'statusTratamento': statusTratamento,
    };
  }

  // Reconstrói o prontuário a partir dos dados em formato de Mapa vindos do SQLite
  factory OcorrenciaSaude.fromMap(Map<String, dynamic> map) {
    return OcorrenciaSaude(
      id: map['id'],
      identificadorAve: map['identificadorAve'],
      dataDiagnostico: DateTime.parse(map['dataDiagnostico']),
      doencaOuSintoma: map['doencaOuSintoma'],
      tratamentoAplicado: map['tratamentoAplicado'],
      statusTratamento: map['statusTratamento'] ?? 'Em Tratamento',
    );
  }
}
