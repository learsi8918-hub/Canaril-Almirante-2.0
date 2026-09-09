import 'package:flutter/material.dart';
import '../models/ave_model.dart';
import '../models/criador_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Estado Dinâmico e 100% Editável do Perfil do Criador
  CriadorPerfil _perfil = CriadorPerfil(
    nome: "Canaril Almirante",
    siglaClube: "SOGO", // Sigla oficial corrigida conforme solicitado
    logoPath: "amarelo", // Define a cor do tema dinâmico ('amarelo', 'azul', 'verde', 'vermelho')
    racasPrincipais: ["Arlequim Português", "Vermelho Mosaico"],
    cidade: "Mineiros",
    estado: "GO",
  );

  Color _corDestaqueLogo = const Color(0xFFFFD700);

  // Controladores para o formulário de edição do criador
  final _formKeyCriador = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _clubeController;
  late TextEditingController _cidadeController;
  late TextEditingController _estadoController;
  String _logoSelecionadaCor = 'amarelo';

  // Plantel de Aves ativo configurado com o Ranking de Fertilidade Duplo (M e F)
  final List<Ave> _plantelGlobal = [
    Ave(anilha: '035', clubeSigla: 'GZ', sexo: 'M', tipoFob: 'Canário de Porte', mutacaoRaca: 'Arlequim Português', porteDetalhe: 'Sem Topete', comTopete: false, fotoPath: '', numeroGaiola: '15', origemTipo: 'Nascido no Canaril')..totalOvos=20..ovosFerteis=19,
    Ave(anilha: '012', clubeSigla: 'OZ', sexo: 'F', tipoFob: 'Canário de Porte', mutacaoRaca: 'Arlequim Português', porteDetalhe: 'Com Topete', comTopete: true, fotoPath: '', numeroGaiola: '15', origemTipo: 'Adquirido de Outro Canaril', nomeCriadorOrigem: 'Canaril Silva', clubeCriadorOrigem: 'FOB')..totalOvos=15..ovosFerteis=14,
    Ave(anilha: '101', clubeSigla: 'SOGO', sexo: 'F', tipoFob: 'Canário de Cor', mutacaoRaca: 'Vermelho Mosaico', porteDetalhe: 'Sem Topete', comTopete: false, fotoPath: '', numeroGaiola: '22', origemTipo: 'Pet Shop / Loja')..totalOvos=10..ovosFerteis=6,
  ];

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: _perfil.nome);
    _clubeController = TextEditingController(text: _perfil.siglaClube);
    _cidadeController = TextEditingController(text: _perfil.cidade);
    _estadoController = TextEditingController(text: _perfil.estado);
    _logoSelecionadaCor = _perfil.logoPath;
    _atualizarCoresDoAplicativo(_logoSelecionadaCor);
  }

  // Algoritmo de Extração de Cores: Adapta o visual do aplicativo baseado na logo inserida
  void _atualizarCoresDoAplicativo(String corLogo) {
    setState(() {
      switch (corLogo) {
        case 'azul': _corDestaqueLogo = const Color(0xFF29B6F6); break;
        case 'verde': _corDestaqueLogo = const Color(0xFF66BB6A); break;
        case 'vermelho': _corDestaqueLogo = const Color(0xFFEF5350); break;
        case 'amarelo':
        default:
          _corDestaqueLogo = const Color(0xFFFFD700); // Amarelo Canário Oficial
      }
    });
  }

  void _abrirPainelEdicaoCriador() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
              child: Form(
                key: _formKeyCriador,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("📝 Editar Perfil do Criador", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 16),
                    TextFormField(controller: _nomeController, decoration: const InputDecoration(labelText: 'Nome do Canaril / Criador', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextFormField(controller: _clubeController, decoration: const InputDecoration(labelText: 'Sigla do Clube (Ex: SOGO, OZ)', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: _cidadeController, decoration: const InputDecoration(labelText: 'Cidade', border: OutlineInputBorder()))),
                        const SizedBox(width: 12),
                        Expanded(child: TextFormField(controller: _estadoController, decoration: const InputDecoration(labelText: 'Estado (UF)', border: OutlineInputBorder()))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text("🎨 Simular Upload de Logo (Muda as Cores do App):", style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _logoSelecionadaCor,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'amarelo', child: Text('Logo Amarela (Tema Tradicional)')),
                        DropdownMenuItem(value: 'azul', child: Text('Logo Azul (Tema Soft)')),
                        DropdownMenuItem(value: 'verde', child: Text('Logo Verde (Tema Ecológico)')),
                        DropdownMenuItem(value: 'vermelho', child: Text('Logo Vermelha (Tema Intenso)')),
                      ],
                      onChanged: (val) {
                        setModalState(() => _logoSelecionadaCor = val!);
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: _corDestaqueLogo),
                        onPressed: () {
                          setState(() {
                            _perfil = CriadorPerfil(
                              nome: _nomeController.text,
                              siglaClube: _clubeController.text,
                              logoPath: _logoSelecionadaCor,
                              racasPrincipais: _perfil.racasPrincipais,
                              cidade: _cidadeController.text,
                              estado: _estadoController.text,
                            );
                            _atualizarCoresDoAplicativo(_logoSelecionadaCor);
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Salvar e Aplicar Identidade', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Separação cirúrgica dos Rankings de Fertilidade por Sexo (Atributo solicitado)
    List<Ave> rankingMachos = _plantelGlobal.where((a) => a.sexo == 'M').toList()
      ..sort((a, b) => b.taxaFertilidade.compareTo(a.taxaFertilidade));
    List<Ave> rankingFemeas = _plantelGlobal.where((a) => a.sexo == 'F').toList()
      ..sort((a, b) => b.taxaFertilidade.compareTo(a.taxaFertilidade));

    return Scaffold(
      appBar: AppBar(
        title: const Text('🦅 CanaryControl Pro'),
        backgroundColor: const Color(0xFF1E1E1E),
        actions: [
          IconButton(icon: Icon(Icons.settings, color: _corDestaqueLogo), onPressed: _abrirPainelEdicaoCriador),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- CARTÃO DE APRESENTAÇÃO DO CRIADOR ---
            Card(
              color: const Color(0xFF1A1A1A),
              shape: RoundedRectangleBorder(side: BorderSide(color: _corDestaqueLogo.withOpacity(0.6)), borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(radius: 28, backgroundColor: _corDestaqueLogo, child: const Icon(Icons.gavel, color: Colors.black)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_perfil.nome, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(_perfil.siglaClube.isNotEmpty ? '🏅 Clube: ${_perfil.siglaClube}' : '🏅 Sem filiação a clube', style: TextStyle(color: _corDestaqueLogo, fontSize: 13, fontWeight: FontWeight.bold)),
                          Text('📍 ${_perfil.cidade} - ${_perfil.estado}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- RANKING DE FERTILIDADE DE MACHOS ---
            Text("🚹 Melhores Reprodutores (Machos)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _corDestaqueLogo)),
            const SizedBox(height: 8),
            
