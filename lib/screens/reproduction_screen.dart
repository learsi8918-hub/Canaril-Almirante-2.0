import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import '../core/theme_controller.dart';
import '../database/db_helper.dart';
import '../services/notification_service.dart';

class ReproductionScreen extends StatefulWidget {
  final AppThemeController theme;
  const ReproductionScreen({super.key, required this.theme});
  @override State<ReproductionScreen> createState() => _ReproState();
}

class _ReproState extends State<ReproductionScreen> {
  List<Map<String, Object?>> cycles = [];

  @override void initState() { super.initState(); load(); }

  Future<void> load() async {
    final d = await DBHelper.db;
    cycles = await d.rawQuery('SELECT c.*, m.anilha ma, f.anilha fa FROM ciclos c LEFT JOIN aves m ON m.id=c.macho_id LEFT JOIN aves f ON f.id=c.femea_id ORDER BY c.id DESC');
    if (mounted) setState(() {});
  }

  Future<DateTime?> pickDate(DateTime initial) => showDatePicker(
    context: context, firstDate: DateTime(2020), lastDate: DateTime(2100), initialDate: initial,
  );

  Future<void> newCycle() async {
    final d = await DBHelper.db;
    final birds = await d.query('aves', where: 'status=?', whereArgs: ['ATIVA']);
    final males = birds.where((x) => x['sexo'] == 'Macho').toList();
    final females = birds.where((x) => x['sexo'] == 'Fêmea').toList();
    if (males.isEmpty || females.isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cadastre pelo menos um macho e uma fêmea ativa.')));
      return;
    }
    int? male = males.first['id'] as int;
    int? female = females.first['id'] as int;
    String system = 'Monogamia';
    final cage = TextEditingController();
    DateTime date = DateTime.now();
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialog) => AlertDialog(
          title: const Text('Novo ciclo reprodutivo'),
          content: SizedBox(width: 500, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButtonFormField<String>(value: system, items: ['Monogamia','Bigamia','Poligamia'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) { if (v != null) setDialog(() => system = v); }, decoration: const InputDecoration(labelText: 'Sistema')),
            DropdownButtonFormField<int>(value: male, items: males.map((x) => DropdownMenuItem(value: x['id'] as int, child: Text('${x['anilha']} ${x['nome'] ?? ''}'))).toList(), onChanged: (v) => setDialog(() => male = v), decoration: const InputDecoration(labelText: 'Macho')),
            DropdownButtonFormField<int>(value: female, items: females.map((x) => DropdownMenuItem(value: x['id'] as int, child: Text('${x['anilha']} ${x['nome'] ?? ''}'))).toList(), onChanged: (v) => setDialog(() => female = v), decoration: const InputDecoration(labelText: 'Fêmea')),
            TextField(controller: cage, decoration: const InputDecoration(labelText: 'Gaiola')),
            ListTile(title: Text('Data de união: ${DateFormat('dd/MM/yyyy').format(date)}'), trailing: const Icon(Icons.calendar_month), onTap: () async { final x = await pickDate(date); if (x != null) setDialog(() => date = x); }),
          ]))),
          actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')), FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Criar ciclo'))],
        ),
      ),
    );
    if (ok != true || male == null || female == null) return;
    final id = await d.insert('ciclos', {'gaiola': cage.text.trim(), 'sistema': system, 'macho_id': male, 'femea_id': female, 'data_uniao': date.toIso8601String(), 'status': 'ATIVO'});
    await _schedule(id, date);
    await load();
  }

  Future<void> _schedule(int cycleId, DateTime firstEgg) async {
    final dates = [
      ('Ovoscopia', firstEgg.add(const Duration(days: 6))),
      ('Nascimento previsto', firstEgg.add(const Duration(days: 14))),
      ('Anilhamento', firstEgg.add(const Duration(days: 19))),
      ('Desmame', firstEgg.add(const Duration(days: 46))),
    ];
    final d = await DBHelper.db;
    for (final x in dates) {
      final lid = await d.insert('lembretes', {'ciclo_id': cycleId, 'titulo': x.$1, 'data': x.$2.toIso8601String(), 'tipo': x.$1});
      await NotificationService.instance.schedule(lid, x.$1, 'Canary Control Pro — ciclo reprodutivo', x.$2);
    }
  }

  Future<void> addEgg(Map<String, Object?> cycle) async {
    final n = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: const Text('Registrar ovo'), content: TextField(controller: n, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Número do ovo')),
      actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Salvar'))],
    ));
    if (ok != true) return;
    final d = await DBHelper.db;
    final count = Sqflite.firstIntValue(await d.rawQuery('SELECT COUNT(*) FROM ovos WHERE ciclo_id=?', [cycle['id']])) ?? 0;
    final dt = DateTime.now();
    await d.insert('ovos', {'ciclo_id': cycle['id'], 'numero': int.tryParse(n.text) ?? count + 1, 'data_postura': dt.toIso8601String(), 'mae_id': cycle['femea_id'], 'pai_id': cycle['macho_id'], 'ovoscopia_data': dt.add(const Duration(days: 6)).toIso8601String()});
    await load();
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reprodução')),
      floatingActionButton: FloatingActionButton.extended(onPressed: newCycle, icon: const Icon(Icons.add), label: const Text('Novo ciclo')),
      body: ListView(padding: const EdgeInsets.all(12), children: [
        Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Reprodução profissional', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Cada ciclo liga macho, fêmea, gaiola e data. Bigamia/poligamia podem usar o mesmo macho em ciclos independentes.'),
        ]))),
        const SizedBox(height: 12),
        ...cycles.map((r) => Card(child: ExpansionTile(
          title: Text('Gaiola ${r['gaiola'] ?? '-'} · ${r['sistema'] ?? '-'}'),
          subtitle: Text('♂ ${r['ma'] ?? '-'}  ×  ♀ ${r['fa'] ?? '-'}'),
          children: [
            ListTile(title: const Text('Data de união'), subtitle: Text(_date(r['data_uniao']))),
            ListTile(title: const Text('Status'), subtitle: Text(r['status'] as String? ?? '-')),
            TextButton.icon(onPressed: () => addEgg(r), icon: const Icon(Icons.egg), label: const Text('Registrar ovo')),
          ],
        )))
      ]),
    );
  }

  String _date(Object? v) { if (v == null) return '-'; return DateFormat('dd/MM/yyyy').format(DateTime.tryParse(v.toString()) ?? DateTime.now()); }
}
