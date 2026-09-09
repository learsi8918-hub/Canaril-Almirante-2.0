import 'package:flutter/material.dart';

class ExportacaoScreen extends StatefulWidget {
  const ExportacaoScreen({Key? key}) : super(key: key);

  @override
  State<ExportacaoScreen> createState() => _ExportacaoScreenState();
}

class _ExportacaoScreenState extends State<ExportacaoScreen> {
  bool _exportandoPlantel = false;
  bool _exportandoBaixas = false;
  String _logOperacao = "Selecione um relatório para gerar o arquivo de auditoria ornitológica.";

  // Função simulando a compilação e exportação de strings estruturadas (padrão CSV/Texto)
  void _gerarRelatorioTexto(String tipo) {
    setState(() {
      if (tipo == 'plantel') _exportandoPlantel = true;
      if (tipo == 'baixas') _exportandoBaixas = true;
    });

    // Simula o delay de compilação dos dados do banco local SQLite
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _exportandoPlantel = false;
        _exportandoBaixas = false;
        
        if (tipo == 'plantel') {
          _logOperacao = "✅ SUCESSO: Arquivo 'plantel_ativo_fob.csv' gerado!\n\n"
              "Conteúdo compilado:\n"
              "ANILHA;CLUBE;SEXO;MUTAÇÃO;TOPETE;FERTILIDADE\n"
              "012;SO;M;Arlequim Português;Com Topete;93.3%\n"
              "005;SO;M;Arlequim Português;Sem Topete;95.0%\n"
              "014;FOB;F;Vermelho Mosaico;Sem Topete;70.0%";
        } else {
          _logOperacao = "✅ SUCESSO: Arquivo 'historico_baixas.csv' gerado!\n\n"
              "Conteúdo compilado:\n"
              "DATA_BAIXA;ANILHA;STATUS;MOTIVO\n"
              "10/08/2026;003;Vendida;Canaril Oliveira - R\$150\n"
              "04/09/2026;019;Morta;Retenção de ovo atravessado";
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Central de Exportação de Dados'),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "💾 Exportar Relatórios do Canaril",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 6),
            const Text(
              "Gere arquivos locais para backup ou compartilhamento de dados do seu plantel.",
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Botão 1: Exportar Plantel
            Card(
              child: ListTile(
                leading: const Icon(Icons.badge, color: Color(0xFFFFD700)),
                title: const Text("Plantel de Matrizes Ativas"),
                subtitle: const Text("Gera planilha de aves, linhagens FOB e taxas de fertilidade acumuladas."),
                trailing: _exportandoPlantel 
                    ? const CircularProgressIndicator(color: Color(0xFFFFD700))
                    : IconButton(
                        icon: const Icon(Icons.download, color: Colors.green),
                        onPressed: () => _gerarRelatorioTexto('plantel'),
                      ),
              ),
            ),
            const SizedBox(height: 10),

            // Botão 2: Exportar Baixas
            Card(
              child: ListTile(
                leading: const Icon(Icons.gavel, color: Colors.redAccent),
                title: const Text("Histórico Completo de Baixas"),
                subtitle: const Text("Gera relatório de auditoria de aves vendidas, doadas ou óbitos."),
                trailing: _exportandoBaixas 
                    ? const CircularProgressIndicator(color: Color(0xFFFFD700))
                    : IconButton(
                        icon: const Icon(Icons.download, color: Colors.green),
                        onPressed: () => _gerarRelatorioTexto('baixas'),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Console/Visualizador de Saída do Arquivo
            const Text("🖥️ Console do Sistema (Log de Exportação):", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade800),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _logOperacao,
                    style: const TextStyle(fontFamily: 'Courier', fontSize: 13, color: Colors.lightBlueAccent),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
