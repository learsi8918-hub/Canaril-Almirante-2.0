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
      else _corDestaqueLogo = const Color(0xFFFFD700); // Amarelo Canário Canônico
    });
  }

  void _salvarConfiguracoesCriador() async {
    if (_formKeyCriador.currentState!.validate()) {
      final novoPerfil = CriadorPerfil(
        id: 1, 
        nome: _nomeController.text, 
        siglaClube: _clubeController.text.toUpperCase(), 
        logoPath: _logoSelecionadaCor, 
        racasPrincipais: _perfil?.racasPrincipais ?? [], 
        cidade: _cidadeController.text, 
        estado: _estadoController.text
      );
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
                const Text("📝 Configuração de Criatório Profissional", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 16),
                TextFormField(controller: _nomeController, decoration: const InputDecoration(labelText: 'Nome do Canaril', border: OutlineInputBorder()), validator: (val) => val!.isEmpty ? 'Informe o nome' : null),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _clubeController, 
                  maxLength: 2, // Restrição rigorosa solicitada: duas letras
                  decoration: const InputDecoration(labelText: 'Sigla do Clube (Apenas 2 Letras. Ex: OZ, GO)', border: OutlineInputBorder(), counterText: ""), 
                  validator: (val) => val!.length != 2 ? 'A sigla precisa ter exatamente 2 letras' : null
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _cidadeController, decoration: const InputDecoration(labelText: 'Cidade', border: OutlineInputBorder()), validator: (val) => val!.isEmpty ? 'Informe a cidade' : null)),
                    const SizedBox(width: 12),
                    Expanded(child: TextFormField(controller: _estadoController, decoration: const InputDecoration(labelText: 'UF', border: OutlineInputBorder()), validator: (val) => val!.isEmpty ? 'Informe o estado' : null)),
                  ],
                ),
                const SizedBox(height: 16),
                const Text("🎨 Logo do Canaril (Reconhecimento Cromático Automático):", style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _logoSelecionadaCor,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'amarelo', child: Text('Logo Brasão Ouro (Tema Amarelo Canário)')),
                    DropdownMenuItem(value: 'azul', child: Text('Logo Marítima (Tema Azul Safira)')),
                    DropdownMenuItem(value: 'verde', child: Text('Logo Ornitológica (Tema Verde Esmeralda)')),
                    DropdownMenuItem(value: 'vermelho', child: Text('Logo Rubra (Tema Vermelho Intenso)')),
                  ],
                  onChanged: (val) => setModalState(() => _logoSelecionadaCor = val!),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: _corDestaqueLogo), onPressed: _salvarConfiguracoesCriador, child: const Text('Salvar e Sincronizar Identidade', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                ),
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
      appBar: AppBar(title: const Text('🦅 Central CanaryControl Pro'), backgroundColor: const Color(0xFF1E1E1E), actions: [IconButton(icon: Icon(Icons.settings, color: _corDestaqueLogo), onPressed: _abrirPainelEdicaoCriador)]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: const Color(0xFF1A1A1A),
              shape: RoundedRectangleBorder(side: BorderSide(color: _corDestaqueLogo.withOpacity(0.5)), borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _perfil == null
                    ? ListTile(title: const Text("Criatório Não Configurado"), subtitle: const Text("Clique para abrir o cadastro inicial de produção."), trailing: Icon(Icons.arrow_forward_ios, color: _corDestaqueLogo, size: 14), onTap: _abrirPainelEdicaoCriador)
                    : Row(children: [CircleAvatar(backgroundColor: _corDestaqueLogo, child: const Icon(Icons.gavel, color: Colors.black)), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_perfil!.nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text('🏅 Clube Oficial: ${_perfil!.siglaClube} | 📍 ${_perfil!.cidade}-${_perfil!.estado}', style: TextStyle(color: _corDestaqueLogo, fontSize: 12, fontWeight: FontWeight.w500))])]),
              ),
            ),
            const SizedBox(height: 24),
            Text("🚹 Melhores Reprodutores Ativos (Ranking Machos)", style: TextStyle(fontWeight: FontWeight.bold, color: _corDestaqueLogo, fontSize: 15)),
            const SizedBox(height: 8),
            machos.isEmpty 
                ? const Text("Nenhum reprodutor operando no banco de dados local.", style: TextStyle(color: Colors.grey, fontSize: 12)) 
                : ListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: machos.length, itemBuilder: (context, i) => Card(child: ListTile(leading: const Icon(Icons.male, color: Colors.blue), title: Text(machos[i].identificadorOficial), subtitle: Text('Gaiola: ${machos[i].numeroGaiola} | Status: ${machos[i].status}'), trailing: Text('${machos[i].taxaFertilidade.toStringAsFixed(0)}% Fert', style: TextStyle(color: _corDestaqueLogo, fontWeight: FontWeight.bold))))),
            const SizedBox(height: 24),
            Text("🚺 Melhores Matrizes Ativas (Ranking Fêmeas)", style: TextStyle(fontWeight: FontWeight.bold, color: _corDestaqueLogo, fontSize: 15)),
            const SizedBox(height: 8),
            femeas.isEmpty 
                ? const Text("Nenhuma matriz operando no banco de dados local.", style: TextStyle(color: Colors.grey, fontSize: 12)) 
            : ListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: femeas.length, itemBuilder: (context, i) => Card(child: ListTile(leading: const Icon(Icons.female, color: Colors.pink), title: Text(femeas[i].identificadorOficial), subtitle: Text('Gaiola: ${femeas[i].numeroGaiola} | Status: ${femeas[i].status}'), trailing: Text('${femeas[i].taxaFertilidade.toStringAsFixed(0)}% Fert', style: TextStyle(color: _corDestaqueLogo, fontWeight: FontWeight.bold))))),],),),);}}
