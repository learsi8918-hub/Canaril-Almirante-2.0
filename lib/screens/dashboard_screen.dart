import 'package:flutter/material.dart';
import '../models/ave_model.dart';
import '../models/criador_model.dart';
import '../database/db_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  CriadorPerfil? _perfil;
  Color _corDestaqueLogo = const Color(0xFFFFD700);
  List<Ave> _plantelReal = [];
  bool _carregando = true;

  final _formKeyCriador = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _clubeController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController();
  String _logoSelecionadaCor = 'amarelo';

  @override
  void initState() {
    super.initState();
    _carregarDadosDoCanaril();
  }

  Future<void> _carregarDadosDoCanaril() async {
    setState(() => _carregando = true);
    final perfilSalvo = await DBHelper.instance.buscarPerfil();
    final avesSalvas = await DBHelper.instance.buscarAvesAtivas();
    setState(() {
      _plantelReal = avesSalvas;
      if (perfilSalvo != null) {
        _perfil = perfilSalvo;
        _nomeController.text = _perfil!.nome;
        _clubeController.text = _perfil!.siglaClube;
        _cidadeController.text = _perfil!.cidade;
        _estadoController.text = _perfil!.estado;
        _logoSelecionadaCor = _perfil!.logoPath;
        _atualizarCoresDoAplicativo(_logoSelecionadaCor);
      }
      _carregando = false;
    });
  }

  void _atualizarCoresDoAplicativo(String corLogo) {
    setState(() {
      if (corLogo == 'azul') _corDestaqueLogo = const Color(0xFF29B6F6);
      else if (corLogo == 'verde') _corDestaqueLogo = const Color(0xFF66BB6A);
      else if (corLogo == 'vermelho') _corDestaqueLogo = const Color(0xFFEF5350);
      else _corDestaqueLogo = const Color(0xFFFFD700);
    });
  }

  void _salvarConfiguracoesCriador() async {
    if (_formKeyCriador.currentState!.validate()) {
      final novoPerfil = CriadorPerfil(id: 1, nome: _nomeController.text, siglaClube: _clubeController.text, logoPath: _logoSelecionadaCor, racasPrincipais: _perfil?.racasPrincipais ?? [], cidade: _cidadeController.text, estado: _estadoController.text);
      await DBHelper.instance.salvarPerfil(novoPerfil);
      _carregarDadosDoCanaril();
      Navigator.pop(context);
    }
  }

  void _abrirPainelEdicaoCriador() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
          child: Form(
            key: _formKeyCriador,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Configurar Criador", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextFormField(controller: _nomeController, decoration: const InputDecoration(labelText: 'Nome Canaril')),
                TextFormField(controller: _clubeController, decoration: const InputDecoration(labelText: 'Clube (Ex: SOGO)')),
                TextFormField(controller: _cidadeController, decoration: const InputDecoration(labelText: 'Cidade')),
                TextFormField(controller: _estadoController, decoration: const InputDecoration(labelText: 'Estado')),
                DropdownButtonFormField<String>(
                  value: _logoSelecionadaCor,
                  items: const [DropdownMenuItem(value: 'amarelo', child: Text('Logo Amarela')), DropdownMenuItem(value: 'azul', child: Text('Logo Azul')), DropdownMenuItem(value: 'verde', child: Text('Logo Verde')), DropdownMenuItem(value: 'vermelho', child: Text('Logo Vermelha'))],
                  onChanged: (val) => setModalState(() => _logoSelecionadaCor = val!),
                ),
                const SizedBox(height: 16),
                ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: _corDestaqueLogo), onPressed: _salvarConfiguracoesCriador, child: const Text('Salvar Perfil', style: TextStyle(color: Colors.black))),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final machos = _plantelReal.where((a) => a.sexo == 'M').toList()..sort((a, b) => b.taxaFertilidade.compareTo(a.taxaFertilidade));
    final femeas = _plantelReal.where((a) => a.sexo == 'F').toList()..sort((a, b) => b.taxaFertilidade.compareTo(a.taxaFertilidade));

    return Scaffold(
      appBar: AppBar(title: const Text('🦅 CanaryControl Pro'), actions: [IconButton(icon: const Icon(Icons.settings), onPressed: _abrirPainelEdicaoCriador)]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _perfil == null
                    ? ListTile(title: const Text("Configurar Canaril"), subtitle: const Text("Clique para preencher dados."), onTap: _abrirPainelEdicaoCriador)
                    : Row(children: [CircleAvatar(backgroundColor: _corDestaqueLogo, child: const Icon(Icons.gavel)), const SizedBox(width: 12), Text(_perfil!.nome, style: const TextStyle(fontWeight: FontWeight.bold))]),
              ),
            ),
            const SizedBox(height: 16),
            Text("🚹 Machos", style: TextStyle(fontWeight: FontWeight.bold, color: _corDestaqueLogo)),
            machos.isEmpty ? const Text("Nenhum cadastrado.") : ListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: machos.length, itemBuilder: (context, i) => Card(child: ListTile(title: Text(machos[i].identificadorOficial)))),
            const SizedBox(height: 16),
            Text("Letras Matrizes", style: TextStyle(fontWeight: FontWeight.bold, color: _corDestaqueLogo)),
            femeas.isEmpty ? const Text("Nenhuma cadastrada.") : ListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: femeas.length, itemBuilder: (context, i) => Card(child: ListTile(title: Text(femeas[i].identificadorOficial)))),
          ],
        ),
      ),
    );
  }
}
