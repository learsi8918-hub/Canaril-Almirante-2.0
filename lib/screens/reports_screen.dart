import 'package:flutter/material.dart';
import '../core/theme_controller.dart';
import '../database/db_helper.dart';

class ReportsScreen extends StatefulWidget {
  final AppThemeController theme;
  const ReportsScreen({super.key, required this.theme});
  @override State<ReportsScreen> createState() => _ReportsState();
}

class _ReportsState extends State<ReportsScreen> {
  List<Map<String, Object?>> data = [];
  @override void initState() { super.initState(); load(); }
  Future<void> load() async {
    final d = await DBHelper.db;
    data = await d.rawQuery('SELECT a.id,a.anilha,a.nome,a.sexo,COUNT(o.id) ovos,SUM(CASE WHEN o.resultado="Fértil" THEN 1 ELSE 0 END) ferteis,SUM(CASE WHEN o.resultado="Infértil" THEN 1 ELSE 0 END) inferteis FROM aves a LEFT JOIN ovos o ON (o.pai_id=a.id OR o.mae_id=a.id) WHERE a.status="ATIVA" GROUP BY a.id ORDER BY ferteis DESC, ovos DESC');
    if (mounted) setState(() {});
  }
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Relatórios')), body: RefreshIndicator(onRefresh: load, child: ListView(padding: const EdgeInsets.all(12), children: [
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Desempenho reprodutivo', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text('Ranking calculado a partir dos ovos e resultados registrados. Fêmeas em primeira postura devem ser avaliadas com histórico próprio, sem descarte automático.'),
      ]))),
      const SizedBox(height: 12),
      ...data.asMap().entries.map((entry) {
        final index = entry.key; final r = entry.value;
        final eggs = (r['ovos'] as int? ?? 0); final fert = (r['ferteis'] as int? ?? 0); final infert = (r['inferteis'] as int? ?? 0);
        final pct = eggs == 0 ? 0.0 : fert / eggs * 100;
        return Card(child: ListTile(leading: CircleAvatar(child: Text('${index + 1}')), title: Text('${r['anilha']} ${r['nome'] ?? ''}'), subtitle: Text('${r['sexo']} · Ovos: $eggs · Férteis: $fert · Inférteis: $infert'), trailing: Text('${pct.toStringAsFixed(0)}%')));
      }),
    ])));
  }
}
