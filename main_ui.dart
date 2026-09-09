import 'package:flutter/material.dart';
import 'app_core.dart';

class AplicativoHome extends StatefulWidget {
  @override
  _AplicativoHomeState createState() => _AplicativoHomeState();
}

class _AplicativoHomeState extends State<AplicativoHome> {
  int _abaSelecionada = 0;
  
  // Instância inicial do perfil do seu canaril
  final CanarilPerfil perfil = CanarilPerfil(
    nome: 'Canaril Almirante',
    logoPath: 'assets/logo.png',
    cidade: 'Mineiros',
    estado: 'GO',
    clube: 'SO (SOGO)',
    racaEspecializada: 'Arlequim Português',
  );

  @override
  Widget build(BuildContext context) {
    // Cores oficiais estabelecidas para a identidade do Canaril Almirante
    final corPrimaria = Color(0xFF1E3A8A); // Azul Náutico
    final corSecundaria = Color(0xFFD4AF37); // Dourado de Elite

    final List<Widget> _telas = [
      _construirTelaHome(corPrimaria, corSecundaria),
      _construirTelaReproducao(corPrimaria),
      _construirTelaPlantel(corPrimaria),
      _construirTelaSaude(corPrimaria),
    ];

    return Scaffold(
      backgroundColor: Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: corPrimaria,
        elevation: 4,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🦅 ${perfil.nome}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
            Text('${perfil.clube} | ${perfil.cidade}-${perfil.estado}', style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
      body: _telas[_abaSelecionada],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _abaSelecionada,
        selectedItemColor: corPrimaria,
        unselectedItemColor: Colors.slateSecondary,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _abaSelecionada = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Painel'),
          BottomNavigationBarItem(icon: Icon(Icons.egg_alt), label: 'Reprodução'),
          BottomNavigationBarItem(icon: Icon(Icons.flutter_dash), label: 'Plantel'),
          BottomNavigationBarItem(icon: Icon(Icons.health_and_safety), label: 'Saúde'),
        ],
      ),
    );
  }

  /// -----------------------------------------------------------------------
  /// TELA 1: PAINEL PRINCIPAL & RANKING REATIVO DE REPRODUTORES (MACHOS/FÊMEAS)
  /// -----------------------------------------------------------------------
  Widget _construirTelaHome(Color primaria, Color secundaria) {
    // Ordena os machos e fêmeas dinamicamente por eficiência reprodutiva
    List<Ave> machosRanking = meuPlantelGlobal.where((a) => a.sexo == 'M').toList();
    machosRanking.sort((a, b) => b.taxaFertilidade.compareTo(a.taxaFertilidade));

    List<Ave> femeasRanking = meuPlantelGlobal.where((a) => a.sexo == 'F').toList();
    femeasRanking.sort((a, b) => b.taxaEclosao.compareTo(a.taxaEclosao));

    return ListView(
      padding: EdgeInsets.all(12),
      children: [
        Card(
          elevation: 2,
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🏆 Ranking de Eficiência (Temporada 2026)', style: TextStyle(fontWeight: FontWeight.bold, color: primaria)),
                Divider(),
                Text('👑 Reprodutores Líderes (Fertilidade)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ...machosRanking.map((m) => ListTile(
                  leading: CircleAvatar(backgroundColor: primaria, child: Text('M', style: TextStyle(color: Colors.white))),
                  title: Text('Anilha: ${m.clubeSigla}-${m.anilha} (${m.mutacaoRaca})'),
                  trailing: Text('${m.taxaFertilidade.toStringAsFixed(1)}%', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                )).toList(),
                SizedBox(height: 10),
                Text('👑 Matrizes Líderes (Eclosão / Filhotes)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ...femeasRanking.map((f) => ListTile(
                  leading: CircleAvatar(backgroundColor: secundaria, child: Text('F', style: TextStyle(color: Colors.white))),
                  title: Text('Anilha: ${f.clubeSigla}-${f.anilha} (${f.mutacaoRaca})'),
                  trailing: Text('${f.taxaEclosao.toStringAsFixed(1)}%', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                )).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// -----------------------------------------------------------------------
  /// TELA 2: GERENCIAMENTO DE REPRODUÇÃO (BIGAMIA, SUB-NINHOS & MATRIZ INICIANTE)
  /// -----------------------------------------------------------------------
  Widget _construirTelaReproducao(Color primaria) {
    // Instanciando o choco real configurado na Gaiola 12
    final chocoFemea15 = CicloReproducao(
      idGaiola: '12',
      anilhaMacho: '05',
      anilhaFemea: '14',
      ehPrimeiraPostura: false,
      idNinhoCompartilhado: 2, // Ninho B
      quantidadeOvos: 4,
      dataInicioChoco: DateTime(2026, 9, 9),
      tipoManejoRetirada: 'Janela_Copula'
    );

    final chocoFemea08 = CicloReproducao(
      idGaiola: '12',
      anilhaMacho: '05',
      anilhaFemea: '08',
      ehPrimeiraPostura: true, // PROTETOR DE MATRIZ INICIANTE ATIVO
      idNinhoCompartilhado: 1, // Ninho A
      quantidadeOvos: 1,
      dataInicioChoco: DateTime(2026, 9, 9),
      tipoManejoRetirada: 'Janela_Copula'
    );

    return ListView(
      padding: EdgeInsets.all(12),
      children: [
        Card(
          elevation: 3,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                color: primaria,
                child: Text('🪺 Gaiola 12 - Sistema de Bigamia Compartilhada', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('⚡ Reprodutor Comum: Macho 05 (Arlequim Consort)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Divider(),
                    
                    // SUB-NINHO A: MATRIZ INICIANTE PROTEGIDA
                    _itemNinhoBigamia(chocoFemea08, 'Ninho A (Fêmea 08)'),
                    SizedBox(height: 10),
                    
                    // SUB-NINHO B: CHOCO ATIVO
                    _itemNinhoBigamia(chocoFemea15, 'Ninho B (Fêmea 15)'),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _itemNinhoBigamia(CicloReproducao ciclo, String tituloNinho) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tituloNinho, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[900])),
              if (ciclo.ehPrimeiraPostura)
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.orange[100], borderRadius: BorderRadius.circular(4)),
                  child: Text('🛡️ Matriz Iniciante Protegida', style: TextStyle(fontSize: 10, color: Colors.orange[900], fontWeight: FontWeight.bold)),
                )
            ],
          ),
          SizedBox(height: 5),
          Text('• Ovos na Postura: ${ciclo.quantidadeOvos}', style: TextStyle(fontSize: 13)),
          Text('• 🔬 Ovoscopia programada: 16/Set/2026', style: TextStyle(fontSize: 12, color: Colors.slateSecondary)),
          Text('• 🐣 Nascimento Estimado: 22/Set/2026', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green[700])),
        ],
      ),
    );
  }
  
