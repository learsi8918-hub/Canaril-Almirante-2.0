import 'package:flutter/material.dart';
import '../models/ave_model.dart';
import '../models/criador_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final CriadorPerfil _perfil = CriadorPerfil(
    nome: "Canaril Central",
    clube: "SO-Goiás",
    logoPath: "assets/logo_canaril.jpg",
    racasPrincipais: ["Arlequim Português", "Vermelho Mosaico", "Gloster Corona", "Raza Española"],
    cidade: "Mineiros",
    estado: "GO",
  );

  Color _corDestaqueLogo = const Color(0xFFFFD700);

  final List<Ave> _plantel = [
    Ave(
      anilha: '012', 
      clubeSigla: 'SO', 
      sexo: 'M', 
      tipoFob: 'Canário de Porte', 
      mutacaoRaca: 'Arlequim Português', 
      porteDetalhe: 'Com Topete', 
      comTopete: true, 
      fotoPath: '',
      origemTipo: 'Adquirido de Outro Canaril',
      canarilProcedencia: 'Canaril Silva',
      clubeOrigem: 'FOB',
    )..totalOvos=15..ovosFerteis=14..filhotesNascidos=12,
    Ave(
      anilha: '005', 
      clubeSigla: 'SO', 
      sexo: 'M', 
      tipoFob: 'Canário de Porte', 
      mutacaoRaca: 'Arlequim Português', 
      porteDetalhe: 'Sem Topete', 
      comTopete: false, 
      fotoPath: '',
      origemTipo: 'Nascido no Canaril',
    )..totalOvos=20..ovosFerteis=19..filhotesNascidos=18,
    Ave(
      anilha: '014', 
      clubeSigla: 'FOB', 
      sexo: 'F', 
      tipoFob: 'Canário de Cor', 
      mutacaoRaca: 'Vermelho Mosaico', 
      porteDetalhe: 'Sem Topete', 
      comTopete: false, 
      fotoPath: '',
      origemTipo: 'Pet Shop / Loja',
      canarilProcedencia: 'Mundo Animal S/A',
    )..totalOvos=10..ovosFerteis=7..filhotesNascidos=4,
  ];

  Ave? machoSelecionado;
  Ave? femeaSelecionada;
  String logGenetico = "Selecione um casal de aves ativas para validar a viabilidade genética.";
  bool possuiRiscoLetal = false;

  @override
  void initState() {
    super.initState();
    _detectarPaletaDaLogo();
  }

  void _detectarPaletaDaLogo() {
    setState(() {
      if (_perfil.logoPath.contains('canaril')) {
        _corDestaqueLogo = const Color(0xFFFFD700);
      } else {
        _corDestaqueLogo = const Color(0xFF00E676);
      }
    });
  }

  void _analisarCruzamento() {
    if (machoSelecionado == null || femeaSelecionada == null) return;

    setState(() {
      if (machoSelecionado!.comTopete && femeaSelecionada!.comTopete) {
        possuiRiscoLetal = true;
        logGenetico = "⚠️ TRAVA GENÉTICA DE ALERTA: Ambos possuem topete! Risco de 25% de mortalidade embrionária.";
      } else {
        possuiRiscoLetal = false;
        logGenetico = "✅ Cruzamento Seguro. Linhagem de ${machoSelecionado!.mutacaoRaca} em conformidade.";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Ave> rankingReprodutores = List.from(_plantel)
      ..sort((a, b) => b.taxaFertilidade.compareTo(a.taxaFertilidade));

    return Scaffold(
      appBar: AppBar(
        title: const Text('🦅 CanaryControl Pro'),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: const Color(0xFF1A1A1A),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: _corDestaqueLogo.withOpacity(0.5), width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: _corDestaqueLogo,
                          child: const Icon(Icons.gavel, color: Colors.black, size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_perfil.nome, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 2),
                              if (_perfil.clube != null && _perfil.clube!.isNotEmpty)
                                Text('🏅 Clube: ${_perfil.clube}', style: TextStyle(color: _corDestaqueLogo, fontSize: 13, fontWeight: FontWeight.w500))
                              else
                                const Text('🏅 Sem filiação a clube cadastrada', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              const SizedBox(height: 2),
                              Text('📍 ${_perfil.cidade} - ${_perfil.estado}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: Colors.grey),
                    const Text("🧬 Especialização do Criatório (Até 4 Raças):", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _perfil.racasPrincipais.map((raca) => Chip(
                        label: Text(raca, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black)),
                        backgroundColor: _corDestaqueLogo,
                      )).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text("🔬 Laboratório de Cruzamento", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<Ave>(
                            decoration: const InputDecoration(labelText: 'Macho (M)', border: OutlineInputBorder()),
                            value: machoSelecionado,
                            items: _plantel.where((a) => a.sexo == 'M').map((ave) => DropdownMenuItem(value: ave, child: Text(ave.identificadorOficial))).toList(),
                            onChanged: (val) { setState(() => machoSelecionado = val); _analisarCruzamento(); },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<Ave>(
                            decoration: const InputDecoration(labelText: 'Fêmea (F)', border: OutlineInputBorder()),
                            value: femeaSelecionada,
                            items: _plantel.where((a) => a.sexo == 'F').map((ave) => DropdownMenuItem(value: ave, child: Text(ave.identificadorOficial))).toList(),
                            onChanged: (val) { setState(() => femeaSelecionada = val); _analisarCruzamento(); },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(logGenetico, style: TextStyle(color: possuiRiscoLetal ? Colors.red : _corDestaqueLogo, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text("📋 Detalhes de Procedência e Linhagem", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _plantel.length,
              itemBuilder: (context, index) {
                final ave = _plantel[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: Icon(Icons.egg, color: _corDestaqueLogo),
                    title: Text('${ave.identificadorOficial} - ${ave.mutacaoRaca}'),
                    subtitle: Text('Procedência: ${ave.origemTipo}' + (ave.canarilProcedencia != null ? ' (${ave.canarilProcedencia})' : '')),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
