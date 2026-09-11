class Ave {
  final int? id;
  final String clubeSigla;
  final String anilha;
  final String? anoNascimento;
  final String sexo;
  final String? nome;
  final String? segmentoFob;
  final String? raca;
  final String? mutacao;
  final String? categoriaPlumagem;
  final String? mutacaoEscrita;
  final bool comTopete;
  final String? numeroGaiola;
  final String origemTipo;
  final String status;
  final int? paiId;
  final int? maeId;
  final String? observacoes;

  const Ave({this.id, required this.clubeSigla, required this.anilha, this.anoNascimento,
    required this.sexo, this.nome, this.segmentoFob, this.raca, this.mutacao,
    this.categoriaPlumagem, this.mutacaoEscrita, this.comTopete = false,
    this.numeroGaiola, this.origemTipo = 'Adquirido', this.status = 'Ativo',
    this.paiId, this.maeId, this.observacoes});

  Map<String,Object?> toMap() => {'id':id,'clube_sigla':clubeSigla,'anilha':anilha,'ano_nascimento':anoNascimento,
    'sexo':sexo,'nome':nome,'segmento_fob':segmentoFob,'raca':raca,'mutacao':mutacao,
    'categoria_plumagem':categoriaPlumagem,'mutacao_escrita':mutacaoEscrita,'com_topete':comTopete?1:0,
    'numero_gaiola':numeroGaiola,'origem_tipo':origemTipo,'status':status,'pai_id':paiId,'mae_id':maeId,'observacoes':observacoes};
  factory Ave.fromMap(Map<String,Object?> m)=>Ave(id:m['id'] as int?,clubeSigla:m['clube_sigla'] as String? ?? '',anilha:m['anilha'] as String? ?? '',anoNascimento:m['ano_nascimento'] as String?,sexo:m['sexo'] as String? ?? 'M',nome:m['nome'] as String?,segmentoFob:m['segmento_fob'] as String?,raca:m['raca'] as String?,mutacao:m['mutacao'] as String?,categoriaPlumagem:m['categoria_plumagem'] as String?,mutacaoEscrita:m['mutacao_escrita'] as String?,comTopete:(m['com_topete'] as int? ?? 0)==1,numeroGaiola:m['numero_gaiola'] as String?,origemTipo:m['origem_tipo'] as String? ?? 'Adquirido',status:m['status'] as String? ?? 'Ativo',paiId:m['pai_id'] as int?,maeId:m['mae_id'] as int?,observacoes:m['observacoes'] as String?);
}
