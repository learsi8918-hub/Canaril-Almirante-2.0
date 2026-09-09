import 'package:flutter/material.dart';
import '../models/ave_model.dart';

class BaixaScreen extends StatefulWidget {
  const BaixaScreen({Key? key}) : super(key: key);

  @override
  State<BaixaScreen> createState() => _BaixaScreenState();
}

class _BaixaScreenState extends State<BaixaScreen> {
  final List<Ave> _historicoBaixas = [
    Ave(
      anilha: '003',
      clubeSigla: 'SO',
      sexo: 'M',
      tipoFob: 'Canário de Cor',
      mutacaoRaca: 'Amarelo Mosaico',
      porteDetalhe: 'Sem Topete',
      comTopete: false,
      fotoPath: '',
      origemTipo: 'Adquirido de Outro Canaril',
      status: 'Vendida',
      dataBaixa: DateTime.now().subtract(const Duration(days: 30)),
      motivoBaixaDetalhe: 'Vendido para o Canaril Oliveira - Valor: R\$ 150,00',
    ),
    Ave(
      anilha: '019',
      clubeSigla: 'FOB',
      sexo: 'F',
      tipoFob: 'Canário de Porte',
      mutacaoRaca: 'Gloster Corona',
      porteDetalhe: 'Com Topete',
      comTopete: true,
      fotoPath: '',
      origemTipo: 'Nascido no Canaril',
      status: 'Morta',
      dataBaixa: DateTime.now().subtract(const Duration(days: 5)),
      motivoBaixaDetalhe: 'Óbito por retenção de ovo (Ovo atravessado).',
    ),
  ];

  final List<String> _avesAtivasParaBaixa = ['SO-012', 'FOB-014', 'SO-005'];
  final _formKey = GlobalKey<FormState>();
  String _aveSelecionada = 'SO-012';
  String _tipoBaixaSelecionado = 'Vendida';
  final _motivoController = TextEditingController();

  void _confirmarBaixaPlantel() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _historicoBaixas.add(
          Ave(
            anilha: _aveSelecionada,
            clubeSigla: 'SO',
            sexo: 'U',
            tipoFob: 'Canário de Cor',
            mutacaoRaca: 'Atualizado',
            porteDetalhe: 'Sem Topete',
            comTopete: false,
            fotoPath: '',
            origemTipo: 'Nascido no Canaril',
            status: _tipoBaixaSelecionado,
            dataBaixa: DateTime.now(),
            motivoBaixaDetalhe: _motivoController.text,
          ),
        );
        _motivoController.clear();
      });
      Navigator.pop(context);
    }
  }

  Color _getBaixaColor(String status) {
    if (status == 'Vendida') return Colors.blue;
    if (status == 'Doada') return Colors.teal;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🍂 Baixa de Plantel'), backgroundColor: const Color(0xFF1E1E1E)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("📜 Histórico de Saídas e Baixas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
            Expanded(
              child: _historicoBaixas.isEmpty
                  ? const Center(child: Text("Nenhuma baixa registrada nesta temporada."))
                  : ListView.builder(
                      itemCount: _historicoBaixas.length,
                      itemBuilder: (context, index) {
                        final aveBaixada = _historicoBaixas[index];
                        final dataStr = aveBaixada.dataBaixa != null ? '${aveBaixada.dataBaixa!.day}/${aveBaixada.dataBaixa!.month}/${aveBaixada.dataBaixa!.year}' : '---';
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: _getBaixaColor(aveBaixada.status).withOpacity(0.2), border: Border.all(color: _getBaixaColor(aveBaixada.status)), borderRadius: BorderRadius.circular(8)),
                              child: Text(aveBaixada.status.toUpperCase(), style: TextStyle(color: _getBaixaColor(aveBaixada.status), fontWeight: FontWeight.bold, fontSize: 10)),
                            ),
                            title: Text('${aveBaixada.identificadorOficial} - ${aveBaixada.mutacaoRaca}'),
                            subtitle: Text('Motivo: ${aveBaixada.motivoBaixaDetalhe ?? "Não especificado"}\nData: $dataStr'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFFD700),
        child: const Icon(Icons.gavel, color: Colors.black),
        onPressed: () => _abrirFormularioBaixa(context),
      ),
    );
  }

  void _abrirFormularioBaixa(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("🍂 Dar Baixa em Canário", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Selecione a Ave (Anilha)', border: OutlineInputBorder()),
                  value: _aveSelecionada,
                  items: _avesAtivasParaBaixa.map((id) => DropdownMenuItem(value: id, child: Text(id))).toList(),
                  onChanged: (val) => setState(() => _aveSelecionada = val!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Tipo de Saída', border: OutlineInputBorder()),
                  value: _tipoBaixaSelecionado,
                  items: const [
                    DropdownMenuItem(value: 'Vendida', child: Text('Venda')),
                    DropdownMenuItem(value: 'Doada', child: Text('Doação')),
                    DropdownMenuItem(value: 'Morta', child: Text('Óbito (Morte)')),
                  ],
                  onChanged: (val) => setState(() => _tipoBaixaSelecionado = val!),
                ),
                const SizedBox(height: 12),
                TextFormField(controller: _motivoController, decoration: const InputDecoration(labelText: 'Detalhes (Preço, comprador ou óbito)', border: OutlineInputBorder()), validator: (val) => val!.isEmpty ? 'Por favor, insira uma justificativa' : null),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700)),
                    onPressed: _confirmarBaixaPlantel,
                    child: const Text('Confirmar Saída do Sistema', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
