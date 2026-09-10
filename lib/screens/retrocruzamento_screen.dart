import 'package:flutter/material.dart';

class RetrocruzamentoScreen extends StatefulWidget {
  const RetrocruzamentoScreen({Key? key}) : super(key: key);

  @override
  State<RetrocruzamentoScreen> createState() => _RetrocruzamentoScreenState();
}

class _RetrocruzamentoScreenState extends State<RetrocruzamentoScreen> {
  final _formKeyRetro = GlobalKey<FormState>();
  final _anilhaAncestralController = TextEditingController();
  final _anilhaFilhoteController = TextEditingController();
  
  String _geracaoAlvo = 'F1 (50% Sangue Padrão)';
  String _resultadoCalculo = 'Insira as anilhas para calcular a linha de acasalamento consanguíneo de retorno.';

  void _calcularRetrocruzamento() {
    if (_formKeyRetro.currentState!.validate()) {
      setState(() {
        _resultadoCalculo = "🧬 PLANEJAMENTO DE RETROCRUZAMENTO SEGURO:\n\n"
            "Para fixar o padrão da raça do ancestral PAI/MÃE (${_anilhaAncestralController.text.toUpperCase()}):\n\n"
            "1. Cruze o Filhote (${_anilhaFilhoteController.text.toUpperCase()}) de volta com o Ancestral PAI.\n"
            "2. Geração Obtida: $_geracaoAlvo.\n"
            "3. Próximo Passo: Selecionar os melhores exemplares e repetir o acasalamento para atingir F2 (75% de pureza fenotípica).\n\n"
            "⚠️ ATENÇÃO: Monitore o vigor físico do plantel para evitar depressão por endogamia.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧬 Simulador de Retrocruzamento'), 
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKeyRetro,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("🧪 Acasalamento de Retorno ao Padrão", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text("Calcule as linhas de cruzamento de filhotes portadores com ancestrais puros para fixar mutações ou padrões FOB.", style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _anilhaAncestralController, 
                decoration: const InputDecoration(labelText: 'Anilha do Ancestral Puro (Pai/Mãe)', border: OutlineInputBorder()), 
                validator: (val) => val!.isEmpty ? 'Informe a anilha' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _anilhaFilhoteController, 
                decoration: const InputDecoration(labelText: 'Anilha do Filhote Portador', border: OutlineInputBorder()), 
                validator: (val) => val!.isEmpty ? 'Informe a anilha' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _geracaoAlvo,
                decoration: const InputDecoration(labelText: 'Geração Alvo do Retorno', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'F1 (50% Sangue Padrão)', child: Text('F1 - Primeira Geração de Retorno (50% Sangue)')),
                  DropdownMenuItem(value: 'F2 (75% Sangue Padrão)', child: Text('F2 - Segunda Geração de Retorno (75% Sangue)')),
                  DropdownMenuItem(value: 'F3 (87.5% Sangue Padrão)', child: Text('F3 - Terceira Geração (Aproximação de Pureza)')),
                ],
                onChanged: (val) => setState(() => _geracaoAlvo = val!),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity, 
                height: 48, 
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700)), 
                  onPressed: _calcularRetrocruzamento, 
                  child: const Text('Calcular Linha Genética', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
              const Text("🖥️ Resultado do Planejamento:", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade800)),
                child: Text(_resultadoCalculo, style: const TextStyle(fontFamily: 'Courier', fontSize: 13, color: Colors.greenAccent)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
