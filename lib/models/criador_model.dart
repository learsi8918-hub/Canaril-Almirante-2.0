class CriadorPerfil {
  final int? id;
  final String nome;
  final String? clube; // Opcional (Pode ficar em branco)
  final String logoPath; // Caminho da imagem que ditará a cor customizada do App
  final List<String> racasPrincipais; // Limitação lógica de até 4 raças
  final String cidade;
  final String estado;

  CriadorPerfil({
    this.id,
    required this.nome,
    this.clube,
    required this.logoPath,
    required this.racasPrincipais,
    required this.cidade,
    required this.estado,
  });

  // Converte o Perfil para o SQLite salvando as raças como String única limpa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'clube': clube == null || clube!.isEmpty ? null : clube,
      'logoPath': logoPath,
      'racasSelecionadas': racasPrincipais.join(','), // Ex: "Gloster,Arlequim,Cobre"
      'cidade': cidade,
      'estado': estado,
    };
  }

  // Desfaz a String única trazendo de volta em formato de Lista de Raças
  factory CriadorPerfil.fromMap(Map<String, dynamic> map) {
    return CriadorPerfil(
      id: map['id'],
      nome: map['nome'],
      clube: map['clube'],
      logoPath: map['logoPath'] ?? '',
      racasPrincipais: map['racasSelecionadas'] != null && map['racasSelecionadas'].toString().isNotEmpty
          ? map['racasSelecionadas'].toString().split(',')
          : [],
      cidade: map['cidade'] ?? '',
      estado: map['estado'] ?? '',
    );
  }
}
