class Criador {
  final int? id;
  final String nome;
  final String siglaClube;
  final String? cidade;
  final String? estado;
  final String? logoPath;
  final String? senhaHash;
  Criador({this.id, required this.nome, required this.siglaClube, this.cidade, this.estado, this.logoPath, this.senhaHash});
  Map<String,dynamic> toMap()=>{'id':id,'nome':nome,'sigla_clube':siglaClube,'cidade':cidade,'estado':estado,'logo_path':logoPath,'senha_hash':senhaHash};
  factory Criador.fromMap(Map<String,dynamic> m)=>Criador(id:m['id'] as int?,nome:m['nome']??'',siglaClube:m['sigla_clube']??'',cidade:m['cidade'],estado:m['estado'],logoPath:m['logo_path'],senhaHash:m['senha_hash']);
}
