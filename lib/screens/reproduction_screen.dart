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
    _initialize();
  }

  Future<void> _initialize() async {
    final db = await DBHelper.db;

    await _addColumn(db, 'data_primeiro_ovo');
    await _addColumn(db, 'data_inicio_choco');
    await _addColumn(db, 'nascimento_previsto');
    await _addColumn(db, 'anilhamento_previsto');
    await _addColumn(db, 'desmame_previsto');

    await _load();
  }

  Future<void> _addColumn(dynamic db, String column) async {
    final info = await db.rawQuery('PRAGMA table_info(ciclos)');

    final exists = info.any(
      (row) => row['name'] == column,
    );

    if (!exists) {
      await db.execute(
        'ALTER TABLE ciclos ADD COLUMN $column TEXT',
      );
    }
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        loading = true;
      });
    }

    final db = await DBHelper.db;

    final data = await db.rawQuery('''
      SELECT
        c.*,
        m.anilha AS macho_anilha,
        m.nome AS macho_nome,
        f.anilha AS femea_anilha,
        f.nome AS femea_nome
      FROM ciclos c
      LEFT JOIN aves m ON m.id = c.macho_id
      LEFT JOIN aves f ON f.id = c.femea_id
      ORDER BY c.id DESC
    ''');

    if (!mounted) return;

    setState(() {
      cycles = data;
      loading = false;
    });
  }

  DateTime? _parse(dynamic value) {
    if (value == null) return null;
    if (value.toString().isEmpty) return null;
    return DateTime.tryParse(value.toString());
  }

  String _date(dynamic value) {
    final date = _parse(value);

    if (date == null) {
      return '--/--/----';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  DateTime _today() {
    final now = DateTime.now();

    return DateTime(
      now.year,
      now.month,
      now.day,
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
            'É necessário ter pelo menos um macho e uma fêmea ativos.',
          ),
        ),
      );
      return;
    }

    int? maleId = males.first['id'] as int?;
    int? femaleId = females.first['id'] as int?;

    String system = 'Monogamia';
    String cage = '';
    DateTime unionDate = _today();

    final result = await showDialog<bool>(
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
                        labelText: 'Sistema',
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
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Gaiola',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        cage = value.trim();
                      },
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.calendar_month,
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
                            unionDate = DateTime(
                              selected.year,
                              selected.month,
                              selected.day,
                            );
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

    if (result == true) {
      await _load();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _firstEgg(
    Map<String, dynamic> cycle,
  ) async {
    DateTime date =
        _parse(cycle['data_primeiro_ovo']) ??
            _today();

    final selected = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selected == null) return;

    date = DateTime(
      selected.year,
      selected.month,
      selected.day,
    );

    final db = await DBHelper.db;

    await db.update(
      'ciclos',
      {
        'data_primeiro_ovo':
            date.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [cycle['id']],
    );

    await _load();
  }

  Future<void> _startBrooding(
    Map<String, dynamic> cycle,
  ) async {
    DateTime date =
        _parse(cycle['data_inicio_choco']) ??
            _today();

    final selected = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selected == null) return;

    final choco = DateTime(
      selected.year,
      selected.month,
      selected.day,
    );

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

    final db = await DBHelper.db;

    await db.update(
      'ciclos',
      {
        'data_inicio_choco':
            choco.toIso8601String(),
        'nascimento_previsto':
            birthMin.toIso8601String(),
        'anilhamento_previsto':
            banding.toIso8601String(),
        'desmame_previsto':
            weaningMin.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [cycle['id']],
    );

    await _load();

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cronograma reprodutivo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _resultLine(
                'Início do choco',
                _formatDate(choco),
              ),
              _resultLine(
                'Ovoscopia',
                _formatDate(ovoscopy),
              ),
              _resultLine(
                'Nascimento previsto',
                '${_formatDate(birthMin)} a ${_formatDate(birthMax)}',
              ),
              _resultLine(
                'Anilhamento',
                _formatDate(banding),
              ),
              _resultLine(
                'Desmame',
                '${_formatDate(weaningMin)} a '
                    '${_formatDate(birthMax.add(const Duration(days: 35)))}',
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

  Widget _resultLine(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 19,
            color: widget.theme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$title: $value',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addEgg(
    Map<String, dynamic> cycle,
  ) async {
    final db = await DBHelper.db;

    final result = await db.rawQuery(
      '''
      SELECT MAX(numero) AS maior
      FROM ovos
      WHERE ciclo_id = ?
      ''',
      [cycle['id']],
    );

    int number = 1;

    if (result.isNotEmpty &&
        result.first['maior'] != null) {
      number =
          (result.first['maior'] as num).toInt() + 1;
    }

    DateTime date = _today();

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Ovo $number'),
              content: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.egg,
                  color: widget.theme.primary,
                ),
                title: const Text(
                  'Data da postura',
                ),
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
                    setDialogState(() {
                      date = DateTime(
                        selected.year,
                        selected.month,
                        selected.day,
                      );
                    });
                  }
                },
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
                        'ciclo_id': cycle['id'],
                        'numero': number,
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
      await _load();
    }
  }

  Future<void> _ovoscopy(
    Map<String, dynamic> cycle,
  ) async {
    final db = await DBHelper.db;

    final eggs = await db.query(
      'ovos',
      where: 'ciclo_id = ?',
      whereArgs: [cycle['id']],
      orderBy: 'numero ASC',
    );

    if (!mounted) return;

    if (eggs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nenhum ovo registrado neste ciclo.',
          ),
        ),
      );
      return;
    }

    DateTime date =
        _parse(cycle['data_inicio_choco']) ??
            _today();

    date = date.add(
      const Duration(days: 6),
    );

    final values = <int, String>{};

    for (final egg in eggs) {
      values[egg['id'] as int] =
          (egg['resultado'] ?? 'Aguardando').toString();
    }

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Ovoscopia'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.visibility,
                        color: widget.theme.primary,
                      ),
                      title: const Text(
                        'Data da ovoscopia',
                      ),
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
                          setDialogState(() {
                            date = DateTime(
                              selected.year,
                              selected.month,
                              selected.day,
                            );
                          });
                        }
                      },
                    ),
                    const Divider(),
                    ...eggs.map(
                      (egg) {
                        final id =
                            egg['id'] as int;

                        return Padding(
                          padding:
                              const EdgeInsets.only(
                            botto
