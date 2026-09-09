import 'package:flutter/material.dart';

/// -----------------------------------------------------------------------
/// MODELAGEM DOS DADOS NATIVOS (ESTRUTURA COMPLETA ANTI-TRAVAMENTO)
/// -----------------------------------------------------------------------

class CanarilPerfil {
  String nome;
  String logoPath;
  String cidade;
  String estado;
  String clube;
  String racaEspecializada;

  CanarilPerfil({
    required this.nome,
    required this.logoPath,
    required this.cidade,
    required this.estado,
    required this.clube,
    required this.racaEspecializada,
  });
}

class Ave {
  final String anilha; // Chave Primária Indexada
  final String clubeSigla; // Validação: 2 Letras (Ex: SO)
  final String sexo; // M ou F
  final String tipo; // Cor ou Porte
  final String mutacaoRaca;
  final String porteDetalhe; 
  final String status; // Ativa, Vendida, Doada, Morta
  final String origem; // Nascido no Canaril, Outro Canaril, Pet Shop
  final String? procedenciaDetalhe;
  final bool comTopete; // Controle de Gene Letal
  final String fotoPath;

  // Estatísticas de Produtividade Acumuladas
  int totalOvos = 0;
  int ovosFerteis = 0;
  int filhotesNascidos = 0;

  Ave({
    required this.anilha,
    required this.clubeSigla,
    required this.sexo,
    required this.tipo,
    required this.mutacaoRaca,
    required this.porteDetalhe,
    required this.status,
    required this.origem,
    this.procedenciaDetalhe,
    required this.comTopete,
    required this.fotoPath,
  });

  double get taxaFertilidade => totalOvos > 0 ? (ovosFerteis / totalOvos) * 100 : 0.0;
  double get taxaEclosao => ovosFerteis > 0 ? (filhotesNascidos / ovosFerteis) * 100 : 0.0;
}

class OcorrenciaSaude {
  final String id;
  final String anilhaAve;
  final DateTime data;
  final List<String> sintomas;
  final String tratamento;
  String statusFinal; // Curado, Em Tratamento, Morto

  OcorrenciaSaude({
    required this.id,
    required this.anilhaAve,
    required this.data,
    required this.sintomas,
    required this.tratamento,
    required this.statusFinal,
  });
}

class CicloReproducao {
  final String idGaiola;
  final String anilhaMacho;
  final String anilhaFemea;
  final bool ehPrimeiraPostura; // Fator Matriz Iniciante
  final int idNinhoCompartilhado; // 0 para individual, 1=Ninho A, 2=Ninho B (Bigamia)
  int quantidadeOvos;
  DateTime dataInicioChoco;
  int? ovosFerteisConstatados;
  int? filhotesNascidosVivos;
  String tipoManejoRetirada; // "Sempre Junto", "3ºOvo", "Janela_Copula"

  CicloReproducao({
    required this.idGaiola,
    required this.anilhaMacho,
    required this.anilhaFemea,
    required this.ehPrimeiraPostura,
    this.idNinhoCompartilhado = 0,
    required this.quantidadeOvos,
    required this.dataInicioChoco,
    this.ovosFerteisConstatados,
    this.filhotesNascidosVivos,
    required this.tipoManejoRetirada,
  });

  DateTime get dataOvoscopia => dataInicioChoco.add(Duration(days: 7));
  DateTime get dataBanheira => dataInicioChoco.add(Duration(days: 12));
  DateTime get dataNascimento => dataInicioChoco.add(Duration(days: 13));
  DateTime get dataAnilhamento => dataInicioChoco.add(Duration(days: 18));
}

/// -----------------------------------------------------------------------
/// BANCO DE DADOS OFICIAL DE SELEÇÃO (PADRÃO FOB ORNITOLÓGICA)
/// -----------------------------------------------------------------------

class BancoDadosFOB {
  static const List<String> categorias = ['Canário de Cor', 'Canário de Porte'];

  static const List<String> mutacoesCor = [
    'Branco Dominante', 'Branco Recessivo', 'Amarelo Intenso', 'Amarelo Nevado', 
    'Amarelo Mosaico', 'Vermelho Intenso', 'Vermelho Nevado', 'Vermelho Mosaico', 
    'Verde (Negro Amarelo)', 'Azul (Negro Branco)', 'Cobre (Negro Vermelho)', 
    'Ágata Amarelo', 'Ágata Prata', 'Ágata Vermelho Mosaico', 'Isabel', 'Canela', 
    'Pastel', 'Opala', 'Acetinado', 'Topázio', 'Eumo', 'Ônix', 'Cobalto', 'Jaspe'
  ];

  static const List<String> racasPorte = [
    'Arlequim Português', 'Gloster Corona', 'Gloster Consort', 'Raza Española', 
    'Fife Fancy', 'Lizard Oro', 'Lizard Plata', 'Lizard Azul', 'Border', 'Scotch Fancy',
    'Hosso Japonês', 'Frisado Parisiense', 'Frisado do Norte', 'Frisado do Sul', 'Fiorino'
  ];
}

/// -----------------------------------------------------------------------
/// MOCK DATA DE PRODUÇÃO COMPACTA (GARANTE CARREGAMENTO RÁPIDO SEM TRAVAR)
/// -----------------------------------------------------------------------

final List<Ave> meuPlantelGlobal = [
  Ave(anilha: '12', clubeSigla: 'SO', sexo: 'M', tipo: 'Canário de Porte', mutacaoRaca: 'Arlequim Português', porteDetalhe: 'Com Topete', status: 'Ativa', origem: 'Nascido no Canaril', comTopete: true, fotoPath: 'assets/macho1.jpg')..totalOvos=15..ovosFerteis=14..filhotesNascidos=12,
  Ave(anilha: '05', clubeSigla: 'SO', sexo: 'M', tipo: 'Canário de Porte', mutacaoRaca: 'Arlequim Português', porteDetalhe: 'Sem Topete', status: 'Ativa', origem: 'Adquirido de Outro Canaril', procedenciaDetalhe: 'Canaril Silva', comTopete: false, fotoPath: 'assets/macho2.jpg')..totalOvos=20..ovosFerteis=19..filhotesNascidos=18,
  Ave(anilha: '14', clubeSigla: 'SO', sexo: 'F', tipo: 'Canário de Cor', mutacaoRaca: 'Vermelho Mosaico', porteDetalhe: 'Sem Topete', status: 'Ativa', origem: 'Adquirido de Outro Canaril', comTopete: false, fotoPath: 'assets/femea1.jpg')..totalOvos=10..ovosFerteis=7..filhotesNascidos=4,
  Ave(anilha: '08', clubeSigla: 'SO', sexo: 'F', tipo: 'Canário de Porte', mutacaoRaca: 'Arlequim Português', porteDetalhe: 'Sem Topete', status: 'Ativa', origem: 'Nascido no Canaril', comTopete: false, fotoPath: 'assets/femea2.jpg')..totalOvos=1..ovosFerteis=0..filhotesNascidos=0,
];
