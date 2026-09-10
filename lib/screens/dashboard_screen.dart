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

  // Controladores do Formulário de Configuração
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
      switch (corLogo) {
        case 'azul': _corDestaqueLogo = const Color(0xFF29B6F6); break;
        case 'verde': _corDestaqueLogo = const Color(0xFF66BB6A); break;
        case 'vermelho': _corDestaqueLogo = const Color(0xFFEF5350); break;
        case 'amarelo':
        default:
          _corDestaqueLogo = const Color(0xFFFFD700);
      }
    });
  }

  void _salvarConfiguracoesCriador() async {
    if (_formKeyCriador.currentState!.validate()) {
      final novoPerfil = CriadorPerfil(
        id: 1, // ID fixo para manter apenas um perfil único no banco
        nome: _nomeController.text,
        siglaClube: _clubeController.text,
        logoPath: _logoSelecionadaCor,
        racasPrincipais: _perfil?.racasPrincipais ?? [],
        cidade: _cidadeController.text,
        estado: _estadoController.text,
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
                    const Text("📝 Configurar Perfil do Criador", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
                    const Text("🎨 Escolha a Logo do Canaril (Define o Tema):", style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
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
                      onChanged: (val) => setModalState(() => _logoSelecionadaCor = val!),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: _corDestaqueLogo),
                        onPressed: _salvarConfiguracoesCriador,
                        child: const Text('Salvar Dados do Canaril', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
    if (_carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    List<Ave> rankingMachos = _plantelReal.where((a) => a.sexo == 'M').toList()
      ..sort((a, b) => b.taxaFertilidade.compareTo(a.taxaFertilidade));
    
    List<Ave> rankingFemeas = _plantelReal.where((a) => a.sexo == 'F').toList()
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
            Card(
              color: const Color(0xFF1A1A1A),
              shape: RoundedRectangleBorder(side: BorderSide(color: _corDestaqueLogo.withOpacity(0.6)), borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _perfil == null
                    ? ListTile(
                        title: const Text("Perfil do Canaril Não Configurado"),
                        subtitle: const Text("Clique na engrenagem no topo para registrar seus dados."),
                        trailing: Icon(Icons.arrow_forward_ios, color: _corDestaqueLogo, size: 16),
                        onTap: _abrirPainelEdicaoCriador,
                      )
                    : Row(
                        children: [
                          CircleAvatar(radius: 28, backgroundColor: _corDestaqueLogo, child: const Icon(Icons.gavel, color: Colors.black)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_perfil!.nome, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Text(_perfil!.siglaClube.isNotEmpty ? '🏅 Clube: ${_perfil!.siglaClube}' : '🏅 Sem clube associado', style: TextStyle(color: _corDestaqueLogo, fontSize: 13, fontWeight: FontWeight.bold)),
                                Text('📍 ${_perfil!.cidade} - ${_perfil!.estado}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
            Text("🚹 Melhores Reprodutores (Machos)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _corDestaqueLogo)),
            const SizedBox(height: 8),
            rankingMachos.isEmpty
                ? const Padding(padding: EdgeInsets.all(8.0), child: Text("Nenhum macho registrado no plantel ativo.", style: TextStyle(color: Colors.grey, fontSize: 13)))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: rankingMachos.length,
                    itemBuilder: (context, index) {
                      final ave = rankingMachos[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.male, color: Colors.blue),
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

  // Controladores do Formulário de Configuração
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
      switch (corLogo) {
        case 'azul': _corDestaqueLogo = const Color(0xFF29B6F6); break;
        case 'verde': _corDestaqueLogo = const Color(0xFF66BB6A); break;
        case 'vermelho': _corDestaqueLogo = const Color(0xFFEF5350); break;
        case 'amarelo':
        default:
          _corDestaqueLogo = const Color(0xFFFFD700);
      }
    });
  }

  void _salvarConfiguracoesCriador() async {
    if (_formKeyCriador.currentState!.validate()) {
      final novoPerfil = CriadorPerfil(
        id: 1, // ID fixo para manter apenas um perfil único no banco
        nome: _nomeController.text,
        siglaClube: _clubeController.text,
        logoPath: _logoSelecionadaCor,
        racasPrincipais: _perfil?.racasPrincipais ?? [],
        cidade: _cidadeController.text,
        estado: _estadoController.text,
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
                    const Text("📝 Configurar Perfil do Criador", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
                    const Text("🎨 Escolha a Logo do Canaril (Define o Tema):", style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
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
                      onChanged: (val) => setModalState(() => _logoSelecionadaCor = val!),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: _corDestaqueLogo),
                        onPressed: _salvarConfiguracoesCriador,
                        child: const Text('Salvar Dados do Canaril', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
    if (_carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    List<Ave> rankingMachos = _plantelReal.where((a) => a.sexo == 'M').toList()
      ..sort((a, b) => b.taxaFertilidade.compareTo(a.taxaFertilidade));
    
    List<Ave> rankingFemeas = _plantelReal.where((a) => a.sexo == 'F').toList()
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
            Card(
              color: const Color(0xFF1A1A1A),
              shape: RoundedRectangleBorder(side: BorderSide(color: _corDestaqueLogo.withOpacity(0.6)), borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _perfil == null
                    ? ListTile(
                        title: const Text("Perfil do Canaril Não Configurado"),
                        subtitle: const Text("Clique na engrenagem no topo para registrar seus dados."),
                        trailing: Icon(Icons.arrow_forward_ios, color: _corDestaqueLogo, size: 16),
                        onTap: _abrirPainelEdicaoCriador,
                      )
                    : Row(
                        children: [
                          CircleAvatar(radius: 28, backgroundColor: _corDestaqueLogo, child: const Icon(Icons.gavel, color: Colors.black)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_perfil!.nome, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Text(_perfil!.siglaClube.isNotEmpty ? '🏅 Clube: ${_perfil!.siglaClube}' : '🏅 Sem clube associado', style: TextStyle(color: _corDestaqueLogo, fontSize: 13, fontWeight: FontWeight.bold)),
                                Text('📍 ${_perfil!.cidade} - ${_perfil!.estado}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
            Text("🚹 Melhores Reprodutores (Machos)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _corDestaqueLogo)),
            const SizedBox(height: 8),
            rankingMachos.isEmpty
                ? const Padding(padding: EdgeInsets.all(8.0), child: Text("Nenhum macho registrado no plantel ativo.", style: TextStyle(color: Colors.grey, fontSize: 13)))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: rankingMachos.length,
                    itemBuilder: (context, index) {
                      final ave = rankingMachos[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.male, color: Colors.blue),
                    
