import 'package:flutter/material.dart';
import '../core/theme_controller.dart';
import '../database/db_helper.dart';

class ReproductionScreen extends StatefulWidget {
  final AppThemeController theme;

  const ReproductionScreen({
    super.key,
    required this.theme,
  });

  @override
  State<ReproductionScreen> createState() => _ReproductionScreenState();
}

class _ReproductionScreenState extends State<ReproductionScreen> {
  List<Map<String, dynamic>> cycles = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _prepareDatabase();
  }

  Future<void> _prepareDatabase() async {
    final db = await DBHelper.db;

    await _addColumnIfMissing(
      db,
      'ciclos',
      'data_primeiro_ovo',
      'TEXT',
    );

    await _addColumnIfMissing(
      db,
      'ciclos',
      'data_inicio_choco',
      'TEXT',
    );

    await _addColumnIfMissing(
      db,
      'ciclos',
      'nascimento_previsto',
      'TEXT',
    );

    await _addColumnIfMissing(
      db,
      'ciclos',
      'anilhamento_previsto',
      'TEXT',
    );

    await _addColumnIfMissing(
      db,
      'ciclos',
      'desmame_previsto',
      'TEXT',
    );

    await _loadCycles();
  }

  Future<void> _addColumnIfMissing(
    dynamic db,
    String table,
    String column,
    String type,
  ) async {
    final result = await db.rawQuery(
      'PRAGMA table_info($table)',
    );

    final exists = result.any(
      (row) => row['name'] == column,
    );

    if (!exists) {
      await db.execute(
        'ALTER TABLE $table ADD COLUMN $column $type',
      );
    }
  }

  Future<void> _loadCycles() async {
    if (!mounted) return;

    setState(() {
      loading = true;
    });

    final db = await DBHelper.db;

    final result = await db.rawQuery('''
      SELECT
        c.*,
        m.anilha AS macho_anilha,
        m.nome AS macho_nome,
        f.anilha AS femea_anilha,
        f.nome AS femea_nome
      FROM ciclos c
      LEFT JOIN aves m ON m.id = c.macho_id
      LEFT JOIN aves f ON f.id = c.femea_id
      ORDER BY
        CASE
          WHEN c.status = 'ABERTO' THEN 0
          ELSE 1
        END,
        c.data_uniao DESC
    ''');

    if (!mounted) return;

    setState(() {
      cycles = result;
      loading = false;
    });
  }

  DateTime? _date(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '--/--/----';

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatDateString(dynamic value) {
    if (value == null) return '--/--/----';

    return _formatDate(
      _date(value.toString()),
    );
  }

  DateTime _onlyDate(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }

  Future<void> _newCycle() async {
    final db = await DBHelper.db;

    final males = await db.query(
      'aves',
      where: 'sexo = ? AND status = ?',
      whereArgs: ['Macho', 'ATIVA'],
      orderBy: 'anilha ASC',
    );

    final females = await db.query(
      'aves',
      where: 'sexo = ? AND status = ?',
      whereArgs: ['Fêmea', 'ATIVA'],
      orderBy: 'anilha ASC',
    );

    if (!mounted) return;

    if (males.isEmpty || females.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cadastre pelo menos um macho e uma fêmea ativa antes de criar um ciclo.',
          ),
        ),
      );
      return;
    }

    int? maleId = males.first['id'] as int?;
    int? femaleId = females.first['id'] as int?;

    String system = 'Monogamia';
    String cage = '';

    DateTime unionDate = _onlyDate(DateTime.now());

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Novo ciclo reprodutivo'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: system,
                      decoration: const InputDecoration(
                        labelText: 'Sistema reprodutivo',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Monogamia',
                          child: Text('Monogamia'),
                        ),
                        DropdownMenuItem(
                          value: 'Bigamia',
                          child: Text('Bigamia'),
                        ),
                        DropdownMenuItem(
                          value: 'Poligamia',
                          child: Text('Poligamia'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;

                        setDialogState(() {
                          system = value;
                        });
                      },
                    ),
                    const SizedBox(height: 14),

                    DropdownButtonFormField<int>(
                      value: maleId,
                      decoration: const InputDecoration(
                        labelText: 'Macho',
                        border: OutlineInputBorder(),
                      ),
                      items: males.map((bird) {
                        final id = bird['id'] as int;

                        final ring =
                            (bird['anilha'] ?? '').toString();

                        final name =
                            (bird['nome'] ?? '').toString();

                        return DropdownMenuItem<int>(
                          value: id,
                          child: Text(
                            name.isEmpty
                                ? ring
                                : '$ring · $name',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          maleId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 14),

                    DropdownButtonFormField<int>(
                      value: femaleId,
                      decoration: const InputDecoration(
                        labelText: 'Fêmea',
                        border: OutlineInputBorder(),
                      ),
                      items: females.map((bird) {
                        final id = bird['id'] as int;

                        final ring =
                            (bird['anilha'] ?? '').toString();

                        final name =
                            (bird['nome'] ?? '').toString();

                        return DropdownMenuItem<int>(
                          value: id,
                          child: Text(
                            name.isEmpty
                                ? ring
                                : '$ring · $name',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          femaleId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Gaiola',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        cage = value.trim();
                      },
                    ),
                    const SizedBox(height: 14),

                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.event,
                        color: widget.theme.primary,
                      ),
                      title: const Text('Data da união'),
                      subtitle: Text(
                        _formatDate(unionDate),
                      ),
                      onTap: () async {
                        final selected =
                            await showDatePicker(
                          context: context,
                          initialDate: unionDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );

                        if (selected != null) {
                          setDialogState(() {
                            unionDate = _onlyDate(selected);
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: maleId == null || femaleId == null
                      ? null
                      : () async {
                          await db.insert(
                            'ciclos',
                            {
                              'gaiola': cage,
                              'sistema': system,
                              'macho_id': maleId,
                              'femea_id': femaleId,
                              'data_uniao':
                                  unionDate.toIso8601String(),
                              'status': 'ABERTO',
                            },
                          );

                          if (dialogContext.mounted) {
                            Navigator.pop(
                              dialogContext,
                              true,
                            );
                          }
                        },
                  child: const Text('Criar ciclo'),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved == true) {
      await _loadCycles();
    }
  }

  Future<void> _registerFirstEgg(
    Map<String, dynamic> cycle,
  ) async {
    final cycleId = cycle['id'] as int;

    DateTime date =
        _date(cycle['data_primeiro_ovo']?.toString()) ??
            _onlyDate(DateTime.now());

    final selected = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selected == null) return;

    final db = await DBHelper.db;

    await db.update(
      'ciclos',
      {
        'data_primeiro_ovo':
            _onlyDate(selected).toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [cycleId],
    );

    await _loadCycles();
  }

  Future<void> _registerBrooding(
    Map<String, dynamic> cycle,
  ) async {
    final cycleId = cycle['id'] as int;

    DateTime date =
        _date(cycle['data_inicio_choco']?.toString()) ??
            _onlyDate(DateTime.now());

    final selected = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selected == null) return;

    final choco = _onlyDate(selected);

    final ovoscopy = choco.add(
      const Duration(days: 6),
    );

    final birthMin = choco.add(
      const Duration(days: 13),
    );

    final birthMax = choco.add(
      const Duration(days: 15),
    );

    final banding = birthMin.add(
      const Duration(days: 5),
    );

    final weaningMin = birthMin.add(
      const Duration(days: 30),
    );

    final weaningMax = birthMax.add(
      const Duration(days: 35),
    );

    final db = await DBHelper.db;

    await db.update(
      'ciclos',
      {
        'data_inicio_choco': choco.toIso8601String(),
        'nascimento_previsto':
            birthMin.toIso8601String(),
        'anilhamento_previsto':
            banding.toIso8601String(),
        'desmame_previsto':
            weaningMin.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [cycleId],
    );

    /*
      A sequência correta é:

      UNIÃO
        ↓
      PRIMEIRO OVO
        ↓
      INÍCIO DO CHOCO
        ↓
      + 6 dias
      OVOSCOPIA
        ↓
      + 13 a 15 dias
      NASCIMENTO
        ↓
      + 5 dias
      ANILHAMENTO
        ↓
      + 30 a 35 dias
      DESMAME
    */

    await _loadCycles();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Cronograma calculado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dateLine(
                'Início do choco',
                choco,
              ),
              _dateLine(
                'Ovoscopia',
                ovoscopy,
              ),
              _dateLine(
                'Nascimento',
                birthMin,
                suffix: ' a ${_formatDate(birthMax)}',
              ),
              _dateLine(
                'Anilhamento',
                banding,
              ),
              _dateLine(
                'Desmame',
                weaningMin,
                suffix:
                    ' a ${_formatDate(weaningMax)}',
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _dateLine(
    String title,
    DateTime date, {
    String suffix = '',
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 20,
            color: widget.theme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$title: ${_formatDate(date)}$suffix',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addEgg(
    Map<String, dynamic> cycle,
  ) async {
    final cycleId = cycle['id'] as int;

    final db = await DBHelper.db;

    final result = await db.rawQuery(
      '''
      SELECT MAX(numero) AS maior
      FROM ovos
      WHERE ciclo_id = ?
      ''',
      [cycleId],
    );

    int nextNumber = 1;

    if (result.isNotEmpty &&
        result.first['maior'] != null) {
      nextNumber =
          ((result.first['maior'] as num).toInt()) + 1;
    }

    DateTime date = _onlyDate(DateTime.now());

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Registrar ovo $nextNumber'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ovo $nextNumber',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.calendar_month,
                      color: widget.theme.primary,
                    ),
                    title: const Text('Data da postura'),
                    subtitle: Text(
                      _formatDate(date),
                    ),
                    onTap: () async {
                      final selected =
                          await showDatePicker(
                        context: context,
                        initialDate: date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );

                      if (selected != null) {
                        setStateDialog(() {
                          date = _onlyDate(selected);
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      false,
                    );
                  },
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () async {
                    await db.insert(
                      'ovos',
                      {
                        'ciclo_id': cycleId,
                        'numero': nextNumber,
                        'data_postura':
                            date.toIso8601String(),
                        'mae_id': cycle['femea_id'],
                        'pai_id': cycle['macho_id'],
                        'resultado': 'Aguardando',
                      },
                    );

                    if (dialogContext.mounted) {
                      Navigator.pop(
                        dialogContext,
                        true,
                      );
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved == true) {
      await _loadCycles();
    }
  }

  Future<void> _ovoscopy(
    Map<String, dynamic> cycle,
  ) async {
    final cycleId = cycle['id'] as int;

    final db = await DBHelper.db;

    final eggs = await db.query(
      'ovos',
      where: 'ciclo_id = ?',
      whereArgs: [cycleId],
      orderBy: 'numero ASC',
    );

    if (!mounted) return;

    if (eggs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Registre pelo menos um ovo antes da ovoscopia.',
          ),
        ),
      );
      return;
    }

    final choco = _date(
      cycle['data_inicio_choco']?.toString(),
    );

    DateTime date = choco != null
        ? choco.add(const Duration(days: 6))
        : _onlyDate(DateTime.now());

    final results = <int, String>{};

    for (final egg in eggs) {
      results[egg['id'] as int] =
          (egg['resultado'] ?? 'Aguardando').toString();
    }

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Ovoscopia'),
              content: SizedBox(
                width: 430,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.calendar_month,
                          color: widget.theme.primary,
                        ),
                        title
