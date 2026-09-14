import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

import '../core/theme_controller.dart';
import '../database/db_helper.dart';
import '../services/notification_service.dart';

class ReproductionScreen extends StatefulWidget {
  final AppThemeController theme;

  const ReproductionScreen({super.key, required this.theme});

  @override
  State<ReproductionScreen> createState() => _ReproductionScreenState();
}

class _ReproductionScreenState extends State<ReproductionScreen> {
  List<Map<String, Object?>> cycles = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = await DBHelper.db;

    await _ensureCycleDateColumns(db);

    cycles = await db.rawQuery('''
      SELECT c.*,
             m.anilha AS macho_anilha,
             m.nome AS macho_nome,
             f.anilha AS femea_anilha,
             f.nome AS femea_nome
      FROM ciclos c
      LEFT JOIN aves m ON m.id = c.macho_id
      LEFT JOIN aves f ON f.id = c.femea_id
      ORDER BY c.id DESC
    ''');

    if (mounted) {
      setState(() {});
    }
  }

  Future<DateTime?> _pickDate(DateTime initial) {
    return showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: initial,
    );
  }

  String _date(Object? value) {
    if (value == null || value.toString().isEmpty) {
      return 'Não informado';
    }

    final date = DateTime.tryParse(value.toString());

    if (date == null) {
      return 'Não informado';
    }

    return DateFormat('dd/MM/yyyy').format(date);
  }

  Future<void> _newCycle() async {
    final db = await DBHelper.db;

    final birds = await db.query(
      'aves',
      where: 'status = ?',
      whereArgs: ['ATIVA'],
    );

    final males = birds.where((bird) {
      return bird['sexo']?.toString().toLowerCase() == 'macho';
    }).toList();

    final females = birds.where((bird) {
      return bird['sexo']?.toString().toLowerCase() == 'fêmea';
    }).toList();

    if (males.isEmpty || females.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Cadastre pelo menos um macho e uma fêmea ativa.',
            ),
          ),
        );
      }
      return;
    }

    int? maleId = males.first['id'] as int;
    int? femaleId = females.first['id'] as int;

    String system = 'Monogamia';
    String cage = '';

    DateTime unionDate = DateTime.now();

    final cageController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Novo ciclo reprodutivo'),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: system,
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
                          if (value != null) {
                            setDialogState(() {
                              system = value;
                            });
                          }
                        },
                        decoration: const InputDecoration(
                          labelText: 'Sistema reprodutivo',
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<int>(
                        value: maleId,
                        items: males.map((bird) {
                          final id = bird['id'] as int;
                          final ring =
                              bird['anilha']?.toString() ?? '-';
                          final name =
                              bird['nome']?.toString() ?? '';

                          return DropdownMenuItem<int>(
                            value: id,
                            child: Text('$ring $name'.trim()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            maleId = value;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Macho',
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<int>(
                        value: femaleId,
                        items: females.map((bird) {
                          final id = bird['id'] as int;
                          final ring =
                              bird['anilha']?.toString() ?? '-';
                          final name =
                              bird['nome']?.toString() ?? '';

                          return DropdownMenuItem<int>(
                            value: id,
                            child: Text('$ring $name'.trim()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            femaleId = value;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Fêmea',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: cageController,
                        decoration: const InputDecoration(
                          labelText: 'Gaiola',
                        ),
                        onChanged: (value) {
                          cage = value;
                        },
                      ),
                      const SizedBox(height: 4),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Data de união'),
                        subtitle: Text(
                          _date(unionDate.toIso8601String()),
                        ),
                        trailing: const Icon(
                          Icons.calendar_month,
                        ),
                        onTap: () async {
                          final selected =
                              await _pickDate(unionDate);

                          if (selected != null) {
                            setDialogState(() {
                              unionDate = selected;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'A ovoscopia não será calculada pela data '
                        'de união. Ela será calculada 6 dias após '
                        'o início do choco.',
                      ),
                    ],
                  ),
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
                  onPressed: () {
                    Navigator.pop(dialogContext, true);
                  },
                  child: const Text('Criar ciclo'),
                ),
              ],
            );
          },
        );
      },
    );

    cageController.dispose();

    if (confirmed != true ||
        maleId == null ||
        femaleId == null) {
      return;
    }

    final cycleId = await db.insert(
      'ciclos',
      {
        'gaiola': cage.trim(),
        'sistema': system,
        'macho_id': maleId,
        'femea_id': femaleId,
        'data_uniao': unionDate.toIso8601String(),
        'status': 'ATIVO',
      },
    );

    await NotificationService.instance.schedule(
      cycleId,
      'Ciclo iniciado',
      'Acompanhe a postura e registre o início do choco.',
      unionDate,
    );

    await _load();
  }

  Future<void> _registerChoco(
    Map<String, Object?> cycle,
  ) async {
    DateTime firstEgg = DateTime.now();
    DateTime chocoStart = firstEgg;

    final numberController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Registrar primeiro ovo e início do choco',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: numberController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Número do primeiro ovo',
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Primeiro ovo'),
                      subtitle: Text(
                        _date(firstEgg.toIso8601String()),
                      ),
                      trailing: const Icon(Icons.egg_outlined),
                      onTap: () async {
                        final selected =
                            await _pickDate(firstEgg);

                        if (selected != null) {
                          setDialogState(() {
                            firstEgg = selected;

                            if (chocoStart.isBefore(firstEgg)) {
                              chocoStart = firstEgg;
                            }
                          });
                        }
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Início do choco'),
                      subtitle: Text(
                        _date(chocoStart.toIso8601String()),
                      ),
                      trailing: const Icon(
                        Icons.nest_cam_wired_stand,
                      ),
                      onTap: () async {
                        final selected =
                            await _pickDate(chocoStart);

                        if (selected != null) {
                          setDialogState(() {
                            chocoStart = selected;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Regra do sistema: início do choco + 6 dias '
                      '= ovoscopia; início do choco + 13 a 15 dias '
                      '= nascimento previsto.',
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
                  onPressed: () {
                    Navigator.pop(dialogContext, true);
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true) {
      numberController.dispose();
      return;
    }

    final typedNumber =
        int.tryParse(numberController.text.trim());

    numberController.dispose();

    if (chocoStart.isBefore(firstEgg)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'O início do choco não pode ser anterior '
              'ao primeiro ovo.',
            ),
          ),
        );
      }
      return;
    }

    final db = await DBHelper.db;

    final ovos = await db.query(
      'ovos',
      where: 'ciclo_id = ?',
      whereArgs: [cycle['id']],
    );

    final number = typedNumber ?? ovos.length + 1;

    final ovoscopy =
        chocoStart.add(const Duration(days: 6));

    final birthReference =
        chocoStart.add(const Duration(days: 14));

    final banding =
        birthReference.add(const Duration(days: 5));

    final weaning =
        birthReference.add(const Duration(days: 32));

    await db.insert(
      'ovos',
      {
        'ciclo_id': cycle['id'],
        'numero': number,
        'data_postura': firstEgg.toIso8601String(),
        'mae_id': cycle['femea_id'],
        'pai_id': cycle['macho_id'],
        'ovoscopia_data': ovoscopy.toIso8601String(),
      },
    );

    await _ensureCycleDateColumns(db);

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

    await _scheduleFromChoco(
      cycle['id'] as int,
      chocoStart,
    );

    await _load();
  }

  Future<void> _ensureCycleDateColumns(
    Database db,
  ) async {
    final columns =
        await db.rawQuery('PRAGMA table_info(ciclos)');

    final names = columns
        .map((row) => row['name']?.toString())
        .whereType<String>()
        .toSet();

    const required = {
      'data_primeiro_ovo',
      'data_inicio_choco',
      'nascimento_previsto',
      'anilhamento_previsto',
      'desmame_previsto',
    };

    for (final column in required) {
      if (!names.contains(column)) {
        await db.execute(
          'ALTER TABLE ciclos ADD COLUMN $column TEXT',
        );
      }
    }
  }
