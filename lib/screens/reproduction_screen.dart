import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

import '../core/theme_controller.dart';
import '../database/db_helper.dart';
import '../services/notification_service.dart';

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
  List<Map<String, Object?>> cycles = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _prepareDatabase();
  }

  Future<void> _prepareDatabase() async {
    try {
      final db = await DBHelper.db;

      await _addColumnIfMissing(
        db,
        'ciclos',
        'data_primeiro_ovo',
      );

      await _addColumnIfMissing(
        db,
        'ciclos',
        'data_inicio_choco',
      );

      await _addColumnIfMissing(
        db,
        'ciclos',
        'nascimento_previsto',
      );

      await _addColumnIfMissing(
        db,
        'ciclos',
        'anilhamento_previsto',
      );

      await _addColumnIfMissing(
        db,
        'ciclos',
        'desmame_previsto',
      );

      await load();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao preparar reprodução: $e',
          ),
        ),
      );
    }
  }

  Future<void> _addColumnIfMissing(
    Database db,
    String table,
    String column,
  ) async {
    try {
      await db.execute(
        'ALTER TABLE $table ADD COLUMN $column TEXT',
      );
    } catch (_) {
      // A coluna já existe.
    }
  }

  Future<void> load() async {
    try {
      final db = await DBHelper.db;

      final result = await db.rawQuery(
        '''
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
        ''',
      );

      if (!mounted) return;

      setState(() {
        cycles = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao carregar reprodução: $e',
          ),
        ),
      );
    }
  }

  String _date(Object? value) {
    if (value == null) {
      return 'Não informado';
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return 'Não informado';
    }

    final date = DateTime.tryParse(text);

    if (date == null) {
      return 'Não informado';
    }

    return DateFormat('dd/MM/yyyy').format(date);
  }

  DateTime? _parseDate(Object? value) {
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return null;
    }

    return DateTime.tryParse(text);
  }

  Future<DateTime?> _pickDate(DateTime initial) {
    return showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: initial,
    );
  }

  String _birdName(Map<String, Object?> bird) {
    final ring = (bird['anilha'] ?? '').toString().trim();
    final name = (bird['nome'] ?? '').toString().trim();

    if (ring.isEmpty && name.isEmpty) {
      return 'Ave sem identificação';
    }

    if (ring.isEmpty) {
      return name;
    }

    if (name.isEmpty) {
      return ring;
    }

    return '$ring — $name';
  }

  Future<void> _newCycle() async {
    final db = await DBHelper.db;

    final birds = await db.query(
      'aves',
      where: 'status = ?',
      whereArgs: ['ATIVA'],
      orderBy: 'anilha ASC',
    );

    final males = birds
        .where(
          (bird) =>
              bird['sexo'].toString().toLowerCase() == 'macho',
        )
        .toList();

    final females = birds
        .where(
          (bird) =>
              bird['sexo'].toString().toLowerCase() == 'fêmea' ||
              bird['sexo'].toString().toLowerCase() == 'femea',
        )
        .toList();

    if (males.isEmpty || females.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cadastre pelo menos um macho e uma fêmea ativa.',
          ),
        ),
      );

      return;
    }

    int? maleId = males.first['id'] as int?;
    int? femaleId = females.first['id'] as int?;

    String system = 'Monogamia';
    String cage = '';

    DateTime unionDate = DateTime.now();

    final cageController = TextEditingController();

    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            dialogContext,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Text(
                'Novo ciclo reprodutivo',
              ),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: system,
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
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        initialValue: maleId,
                        decoration: const InputDecoration(
                          labelText: 'Macho',
                          border: OutlineInputBorder(),
                        ),
                        items: males.map(
                          (bird) {
                            final id = bird['id'] as int;

                            return DropdownMenuItem<int>(
                              value: id,
                              child: Text(
                                _birdName(bird),
                              ),
                            );
                          },
                        ).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            maleId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        initialValue: femaleId,
                        decoration: const InputDecoration(
                          labelText: 'Fêmea',
                          border: OutlineInputBorder(),
                        ),
                        items: females.map(
                          (bird) {
                            final id = bird['id'] as int;

                            return DropdownMenuItem<int>(
                              value: id,
                              child: Text(
                                _birdName(bird),
                              ),
                            );
                          },
                        ).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            femaleId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: cageController,
                        decoration: const InputDecoration(
                          labelText: 'Gaiola da fêmea',
                          hintText: 'Ex.: 12',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Data de união',
                        ),
                        subtitle: Text(
                          DateFormat('dd/MM/yyyy').format(
                            unionDate,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.calendar_month,
                        ),
                        onTap: () async {
                          final selected =
                              await _pickDate(unionDate);

                          if (selected == null) return;

                          setDialogState(() {
                            unionDate = selected;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'A data de união serve para registrar '
                        'quando o casal foi formado. Ela não será '
                        'usada para calcular a ovoscopia ou o nascimento.',
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      false,
                    );
                  },
                  child: const Text(
                    'Cancelar',
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    cage = cageController.text.trim();

                    Navigator.pop(
                      dialogContext,
                      true,
                    );
                  },
                  child: const Text(
                    'Criar ciclo',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    cageController.dispose();

    if (created != true) {
      return;
    }

    if (maleId == null || femaleId == null) {
      return;
    }

    final cycleId = await db.insert(
      'ciclos',
      {
        'gaiola': cage,
        'sistema': system,
        'macho_id': maleId,
        'femea_id': femaleId,
        'data_uniao': unionDate.toIso8601String(),
        'status': 'ATIVO',
      },
    );

    await load();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Ciclo $cycleId criado com sucesso.',
        ),
      ),
    );
  }

  Future<void> _registerEgg(
    Map<String, Object?> cycle,
  ) async {
    final numberController = TextEditingController();

    DateTime firstEgg = DateTime.now();
    DateTime chocoStart = firstEgg;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            dialogContext,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Text(
                'Registrar postura',
              ),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: numberController,
                        keyboardType:
                            TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Número do ovo',
                          hintText: 'Ex.: 1',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Primeiro ovo',
                        ),
                        subtitle: Text(
                          DateFormat('dd/MM/yyyy').format(
                            firstEgg,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.egg_outlined,
                        ),
                        onTap: () async {
                          final selected =
                              await _pickDate(firstEgg);

                          if (selected == null) return;

                          setDialogState(() {
                            firstEgg = selected;

                            if (chocoStart.isBefore(
                              selected,
                            )) {
                              chocoStart = selected;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 4),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Início do choco',
                        ),
                        subtitle: Text(
                          DateFormat('dd/MM/yyyy').format(
                            chocoStart,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.nest_cam_wired_stand,
                        ),
                        onTap: () async {
                          final selected =
                              await _pickDate(chocoStart);

                          if (selected == null) return;

                          setDialogState(() {
                            chocoStart = selected;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'O início do choco é a referência '
                        'principal para os cálculos. '
                        'A ovoscopia será marcada para +6 dias. '
                        'O nascimento será estimado entre +13 e +15 dias.',
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      false,
                    );
                  },
                  child: const Text(
                    'Cancelar',
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      true,
                    );
                  },
                  child: const Text(
                    'Salvar postura',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    numberController.dispose();

    if (saved != true) {
      return;
    }

    if (chocoStart.isBefore(firstEgg)) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'O início do choco não pode ser anterior ao primeiro ovo.',
          ),
        ),
      );

      return;
    }

    final db = await DBHelper.db;

    final eggCount = Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM ovos WHERE ciclo_id = ?',
            [cycle['id']],
          ),
        ) ??
        0;

    final typedNumber =
        int.tryParse(numberController.text.trim());

    final eggNumber =
        typedNumber ?? eggCount + 1;

    final ovoscopyDate = chocoStart.add(
      const Duration(days: 6),
    );

    final birthMin = chocoStart.add(
      const Duration(days: 13),
    );

    final birthReference = chocoStart.add(
      const Duration(days: 14),
    );

    final birthMax = chocoStart.add(
      const Duration(days: 15),
    );

    final banding = birthReference.add(
      const Duration(days: 5),
    );

    final weaning = birthReference.add(
      const Duration(days: 32),
    );

    await db.insert(
      'ovos',
      {
        'ciclo_id': cycle['id'],
        'numero': eggNumber,
        'data_postura':
            firstEgg.toIso8601String(),
        'mae_id': cycle['femea_id'],
        'pai_id': cycle['macho_id'],
        'ovoscopia_data':
            ovoscopyDate.toIso8601String(),
      },
    );

    await db.update(
      'ciclos',
      {
        'data_primeiro_ovo':
            firstEgg.toIso8601String(),
        'data_inicio_choco':
            chocoStart.toIso8601String(),
        'nascimento_previsto':
            birthReference.toIso8601String(),
        'anilhamento_previsto':
            banding.toIso8601String(),
        'desmame_previsto':
            weaning.toIso8601String(),
        'status': 'CHOCO',
      },
      where: 'id = ?',
      whereArgs: [cycle['id']],
    );

    await _createReminders(
      cycle['id'] as int,
      ovoscopyDate,
      birthReference,
      banding,
      weaning,
    );

    await load();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Postura registrada.\n'
          'Ovoscopia: ${_date(ovoscopyDate.toIso8601String())}\n'
          'Nascimento: ${_date(birthMin.toIso8601String())} '
          'a ${_date(birthMax.toIso8601String())}',
        ),
      ),
    );
  }

  Future<void> _createReminders(
    int cycleId,
    DateTime ovoscopy,
    DateTime birth,
    DateTime banding,
    DateTime weaning,
  ) async {
    final db = await DBHelper.db;

    final reminders = [
      {
        'title': 'Ovoscopia',
        'type': 'OVOSCOPIA',
        'date': ovoscopy,
      },
      {
        'title': 'Nascimento previsto',
        'type': 'NASCIMENTO',
        'date': birth,
      },
      {
        'title': 'Anilhamento',
        'type': 'ANILHAMENTO',
        'date': banding,
      },
      {
        'title': 'Desmame',
        'type': 'DESMAME',
        'date': weaning,
      },
    ];

    for (final reminder in reminders) {
      final date =
          reminder['date'] as DateTime;

      final title =
          reminder['title'] as String;

      final type =
          reminder['type'] as String;

      final id = await db.insert(
        'lembretes',
        {
          'ciclo_id': cycleId,
          'titulo': title,
          'data': date.toIso860
