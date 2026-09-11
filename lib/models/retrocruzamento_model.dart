class Retrocruzamento {
  final int? id; final int individuoId; final int alvoId; final int geracao; final String observacoes;
  const Retrocruzamento({this.id,required this.individuoId,required this.alvoId,required this.geracao,this.observacoes=''});
  Map<String,Object?> toMap()=>{'id':id,'individuo_id':individuoId,'alvo_id':alvoId,'geracao':geracao,'observacoes':observacoes};
}
