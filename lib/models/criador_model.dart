class CriadorPerfil {
  int? id;
  String nome;
  String siglaClube; // Editável (Ex: SOGO)
  String logoPath;
  List<String> racasPrincipais; // Até 4 raças
  String cidade;
  String estado;

  CriadorPerfil({
    this.id,
    required this.nome,
    required this.siglaClube,
    required this.logoPath,
    required this.racasPrincipais,
    required this.cidade,
    required this.estado,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'siglaClube': siglaClube,
      'logoPath': logoPath,
      'racasSelecionadas': racasPrincipais.join(','),
      'cidade': cidade,
      'estado': estado,
    };
  }

  factory CriadorPerfil.fromMap(Map<String, dynamic> map) {
    return CriadorPerfil(
      id: map['id'],
      nome: map['nome'] ?? '',
      siglaClube: map['siglaClube'] ?? '',
      logoPath: map['logoPath'] ?? '',
      racasPrincipais: map['racasSelecionadas'] != null && map['racasSelecionadas'].toString().isNotEmpty
          ? map['racasSelecionadas'].toString().split(',')
          : [],
      cidade: map['cidade'] ?? '',
      estado: map['estado'] ?? '',
    );
  }
}
