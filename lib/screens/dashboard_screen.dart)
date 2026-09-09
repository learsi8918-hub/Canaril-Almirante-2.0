import 'package:flutter/material.dart';
import '../models/ave_model.dart';
import '../models/saude_model.dart';
import '../models/ciclo_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Mock Data: Lista de aves iniciais injetada para simulação em tempo real
  final List<Ave> _plantel = [
    Ave(anilha: '012', clubeSigla: 'SO', sexo: 'M', tipoFob: 'Canário de Porte', mutacaoRaca: 'Arlequim Português', porteDetalhe: 'Com Topete', comTopete: true, fotoPath: '')..totalOvos=15..ovosFerteis=14..filhotesNascidos=12,
    Ave(anilha: '005', clubeSigla: 'SO', sexo: 'M', tipoFob: 'Canário de Porte', mutacaoRaca: 'Arlequim Português', porteDetalhe: 'Sem Topete', comTopete: false, fotoPath: '')..totalOvos=20..ovosFerteis=19..filhotesNascidos=18,
    Ave(anilha: '014', clubeSigla: 'FOB', sexo: 'F', tipoFob: 'Canário de Cor', mutacaoRaca: 'Vermelho Mosaico', porteDetalhe: 'Sem Topete', comTopete: false, fotoPath: '')..totalOvos=10..ovosFerteis=7..filhotesNascidos=4,
    Ave(anilha: '008', clubeSigla: 'SO', sexo: 'F', tipoFob: 'Canário de Porte', mutacaoRaca: 'Arlequim Português', porteDetalhe: 'Com Topete', comTopete: true, fotoPath: '')..totalOvos=8..ovosFerteis=6..filhotesNascidos=5,
  ];

  Ave? machoSelecionado;
  Ave? femeaSelecionada;
  String logGenetico = "Selecione um casal de aves ativas para validar a viabilidade genética do cruzamento.";
  bool possuiRiscoLetal = false;

  void _analisarCruzamento() {
    if (machoSelecionado == null || femeaSelecionada == null) return;

    setState(() {
      // Regra de Negócio: Fator Letal Homozigótico (Topete x Topete)
      if (machoSelecionado!.comTopete && femeaSelecionada!.comTopete) {
        possuiRiscoLetal = true;
        logGenetico = "⚠️ TRAVA GENÉTICA DE ALERTA: Ambos possuem topete! "
            "Risco de 25% de mortalidade embrionária nos ovos devido ao gene letal homozigótico.";
      } else if (machoSelecionado!.mutacaoRaca == 'Arlequim Português' && 
                 femeaSelecionada!.mutacaoRaca == 'Arlequim Português') {
        possuiRiscoLetal = false;
        logGenetico = "✅ Acasalamento Excelente: Par ideal para Arlequim Português (Com Topete x Sem Topete). Mantém a proporção correta e segura para a prole.";
      } else if (machoSelecionado!.mutacaoRaca != femeaSelecionada!.mutacaoRaca) {
        possuiRiscoLetal = false;
        logGenetico = "ℹ️ Retrocruzamento detectado: Cruzamento de raças/mutações diferentes. Útil para fixação ou purificação de fatores, mas gera portadores.";
      } else {
        possuiRiscoLetal = false;
        logGenetico = "✅ Cruzamento Seguro: Linhagem pura de ${machoSelecionado!.mutacaoRaca} em conformidade com as regras FOB.";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Computação do ranking dinâmico baseado na taxa de fertilidade (%) calculada no Model
    List<Ave> rankingReprodutores = List.from(_plantel)
      ..sort((a, b) => b.taxaFertilidade.compareTo(a.taxaFertilidade));

    return Scaffold(
      appBar: AppBar(
        title: const Text('🦅 CanaryControl Pro', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SEÇÃO 1: LABORATÓRIO DE ACASALAMENTO ---
            const Text("🔬 Laboratório de Cruzamento", 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Dropdown de Machos
                        Expanded(
                          child: DropdownButtonFormField<Ave>(
                            decoration: const InputDecoration(labelText: 'Macho (M)', border: OutlineInputBorder()),
                            value: machoSelecionado,
                            items: _plantel.where((a) => a.sexo == 'M' && a.status == 'Ativa').map((ave) {
                              return DropdownMenuItem(value: ave, child: Text('${ave.identificadorOficial} (${ave.porteDetalhe})'));
                            }).toList(),
                            onChanged: (val) {
                              setState(() => machoSelecionado = val);
                              _analisarCruzamento();
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Dropdown de Fêmeas
                        Expanded(
                          child: DropdownButtonFormField<Ave>(
                            decoration: const InputDecoration(labelText: 'Fêmea (F)', border: OutlineInputBorder()),
                            value: femeaSelecionada,
                            items: _plantel.where((a) => a.sexo == 'F' && a.status == 'Ativa').map((ave) {
                              return DropdownMenuItem(value: ave, child: Text('${ave.identificadorOficial} (${ave.porteDetalhe})'));
                            }).toList(),
                            onChanged: (val) {
                              setState(() => femeaSelecionada = val);
                              _analisarCruzamento();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Alerta dinâmico
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: possuiRiscoLetal ? Colors.red.withOpacity(0.15) : Colors.amber.withOpacity(0.05),
                        border: Border.all(color: possuiRiscoLetal ? Colors.red : Colors.amber),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        logGenetico,
                        style: TextStyle(color: possuiRiscoLetal ? Colors.redAccent : Colors.amber, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- SEÇÃO 2: RANKING AUTOMÁTICO DE FERTILIDADE ---
            const Text("📊 Ranking de Fertilidade (Matrizes)", 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rankingReprodutores.length,
              itemBuilder: (context, index) {
                final ave = rankingReprodutores[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: ave.sexo == 'M' ? Colors.blue.shade800 : Colors.pink.shade800,
                      child: Text(ave.sexo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    title: Text('${ave.identificadorOficial} - ${ave.mutacaoRaca}'),
                    subtitle: Text('Posturas: ${ave.totalOvos} ovos | Galados: ${ave.ovosFerteis}'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: ave.taxaFertilidade >= 80 ? Colors.green.shade900 : Colors.orange.shade900,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${ave.taxaFertilidade.toStringAsFixed(0)}%', 
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
