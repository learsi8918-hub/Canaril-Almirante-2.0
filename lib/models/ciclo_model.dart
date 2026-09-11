class Ciclo {
  final int? id; final String sistema; final String? manejoMacho; final DateTime? dataInicio;
  const Ciclo({this.id,required this.sistema,this.manejoMacho,this.dataInicio});
  Map<String,Object?> toMap()=>{'id':id,'sistema':sistema,'manejo_macho':manejoMacho,'data_inicio':dataInicio?.toIso8601String()};
}
