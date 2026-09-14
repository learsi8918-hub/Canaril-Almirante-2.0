import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sqflite/sqflite.dart';

import '../core/theme_controller.dart';
import '../database/db_helper.dart';

class PlantelScreen extends StatefulWidget {
  final AppThemeController theme;

  const PlantelScreen({
    super.key,
    required this.theme,
  });

  @override
  State<PlantelScreen> createState() => _PlantelState();
}

class _PlantelState extends State<PlantelScreen> {
  List<Map<String, Object?>> rows = [];

  String query = '';
  String? selectedSex;
  String? selectedSegment;
  String? selectedOrigin;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  // ===========================================================================
  // CARREGAR PLANTEL
  // ===========================================================================

  Future<void> load() async {
    if (mounted) {
      setState(() {
        loading = true;
      });
    }

    try {
      final db = await DBHelper.db;

      final result = await db.query(
        'aves',
        where: 'status = ?',
        whereArgs: ['ATIVA'],
        orderBy: 'id DESC',
      );

      if (!mounted) return;

      setState(() {
        rows = result;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        rows = [];
        loading = false;
      });
    }
  }

  // ===========================================================================
  // AUXILIARES
  // ===========================================================================

  String _stringValue(
    Map<String, Object?> row,
    String key,
  ) {
    final value = row[key];

    if (value == null) {
      return '';
    }

    return value.toString();
  }

  String _dateBr(String value) {
    if (value.isEmpty) {
      return '';
    }

    final date = DateTime.tryParse(value);

    if (date == null) {
      return value;
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<String?> _selectDate(
    BuildContext context, {
    String? initial,
  }) async {
    DateTime initialDate = DateTime.now();

    if (initial != null && initial.isNotEmpty) {
      final parsed = DateTime.tryParse(initial);

      if (parsed != null) {
        initialDate = parsed;
      }
    }

    if (initialDate.isAfter(DateTime.now())) {
      initialDate = DateTime.now();
    }

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Data de nascimento',
      cancelText: 'Cancelar',
      confirmText: 'Selecionar',
    );

    if (selected == null) {
      return null;
    }

    return DateTime(
      selected.year,
      selected.month,
      selected.day,
    ).toIso8601String();
  }

  // ===========================================================================
  // FOTO
  // ===========================================================================

  Future<String?> _pickPhoto() async {
    try {
      final picker = ImagePicker();

      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1600,
      );

      return image?.path;
    } catch (_) {
      return null;
    }
  }

  // ===========================================================================
  // CATÁLOGO FOB
  // ===========================================================================

  List<DropdownMenuItem<String>> _uniqueFobItems(
    List<Map<String, Object?>> catalog,
  ) {
    final seen = <String>{};
    final items = <DropdownMenuItem<String>>[];

    for (final row in catalog) {
      final raca = row['raca']?.toString().trim() ?? '';

      if (raca.isEmpty) {
        continue;
      }

      if (!seen.add(raca)) {
        continue;
      }

      final familia = row['familia']?.toString().trim() ?? '';
      final mutacao = row['mutacao']?.toString().trim() ?? '';

      String label = raca;

      final extras = <String>[];

      if (familia.isNotEmpty) {
        extras.add(familia);
      }

      if (mutacao.isNotEmpty) {
        extras.add(mutacao);
      }

      if (extras.isNotEmpty) {
        label = '$raca — ${extras.join(' · ')}';
      }

      items.add(
        DropdownMenuItem<String>(
          value: raca,
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    items.sort(
      (a, b) {
        final aText = a.value ?? '';
        final bText = b.value ?? '';
        return aText.toLowerCase().compareTo(
              bText.toLowerCase(),
            );
      },
    );

    return items;
  }

  Map<String, Object?>? _findFob(
    List<Map<String, Object?>> catalog,
    String? raca,
  ) {
    if (raca == null || raca.isEmpty) {
      return null;
    }

    for (final row in catalog) {
      final value = row['raca']?.toString().trim() ?? '';

      if (value == raca) {
        return row;
      }
    }

    return null;
  }

  // ===========================================================================
  // EDITAR / CADASTRAR AVE
  // ===========================================================================

  Future<void> edit([
    Map<String, Object?>? old,
  ]) async {
    final anilhaController = TextEditingController(
      text: _stringValue(old ?? {}, 'anilha'),
    );

    final nomeController = TextEditingController(
      text: _stringValue(old ?? {}, 'nome'),
    );

    final gaiolaController = TextEditingController(
      text: _stringValue(old ?? {}, 'gaiola'),
    );

    final familiaController = TextEditingController(
      text: _stringValue(old ?? {}, 'familia'),
    );

    final variedadeController = TextEditingController(
      text: _stringValue(old ?? {}, 'variedade'),
    );

    final mutacaoController = TextEditingController(
      text: _stringValue(old ?? {}, 'mutacao'),
    );

    final origemDetalheController = TextEditingController(
      text: _stringValue(old ?? {}, 'origem_detalhe'),
    );

    final observacoesController = TextEditingController(
      text: _stringValue(old ?? {}, 'observacoes'),
    );

    String sexo = _stringValue(
      old ?? {},
      'sexo',
    );

    if (sexo.isEmpty) {
      sexo = 'Macho';
    }

    String segmento = _stringValue(
      old ?? {},
      'segmento',
    );

    if (segmento.isEmpty) {
      segmento = 'Cor';
    }

    String origem = _stringValue(
      old ?? {},
      'origem',
    );

    if (origem.isEmpty) {
      origem = 'Nascido no canaril';
    }

    bool topete =
        ((old?['topete'] as int?) ?? 0) == 1;

    String? dataNascimento = _stringValue(
      old ?? {},
      'data_nascimento',
    );

    String? fotoPath = _stringValue(
      old ?? {},
      'foto_path',
    );

    String? selectedFob;

    final db = await DBHelper.db;

    List<Map<String, Object?>> fobRows = [];

    try {
      fobRows = await db.query(
        'catalogo_fob',
        orderBy: 'segmento, familia, raca, mutacao, categoria',
      );
    } catch (_) {
      fobRows = [];
    }

    if (old != null) {
      final racaAtual = _stringValue(
        old,
        'raca',
      );

      if (racaAtual.isNotEmpty) {
        selectedFob = racaAtual;
      }
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            final selectedCatalog = _findFob(
              fobRows,
              selectedFob,
            );

            return AlertDialog(
              title: Text(
                old == null
                    ? 'Cadastrar ave'
                    : 'Editar ave',
              ),
              content: SizedBox(
                width: 560,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      // =======================================================
                      // FOTO
                      // =======================================================

                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: widget.theme.primary
                                    .withOpacity(0.10),
                                image: fotoPath != null &&
                                        fotoPath!.isNotEmpty &&
                                        File(fotoPath!).existsSync()
                                    ? DecorationImage(
                                        image: FileImage(
                                          File(fotoPath!),
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: fotoPath == null ||
                                      fotoPath!.isEmpty ||
                                      !File(fotoPath!).existsSync()
                                  ? Icon(
                                      Icons.flutter_dash,
                                      size: 48,
                                      color:
                                          widget.theme.primary,
                                    )
                                  : null,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: IconButton.filled(
                                onPressed: () async {
                                  final path =
                                      await _pickPhoto();

                                  if (path == null) {
                                    return;
                                  }

                                  setDialogState(() {
                                    fotoPath = path;
                                  });
                                },
                                icon: const Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // =======================================================
                      // IDENTIFICAÇÃO
                      // =======================================================

                      Text(
                        'Identificação',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller: anilhaController,
                        textCapitalization:
                            TextCapitalization.characters,
                        decoration:
                            const InputDecoration(
                          labelText: 'Anilha *',
                          prefixIcon: Icon(
                            Icons.confirmation_number_outlined,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller: nomeController,
                        decoration:
                            const InputDecoration(
                          labelText: 'Nome',
                          hintText: 'Opcional',
                          prefixIcon: Icon(
                            Icons.badge_outlined,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller: gaiolaController,
                        decoration:
                            const InputDecoration(
                          labelText: 'Gaiola',
                          prefixIcon: Icon(
                            Icons.grid_view_outlined,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      DropdownButtonFormField<String>(
                        value: sexo,
                        decoration:
                            const InputDecoration(
                          labelText: 'Sexo',
                          prefixIcon: Icon(
                            Icons.wc_outlined,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Macho',
                            child: Text('Macho'),
                          ),
                          DropdownMenuItem(
                            value: 'Fêmea',
                            child: Text('Fêmea'),
                          ),
                          DropdownMenuItem(
                            value: 'Indeterminado',
                            child: Text(
                              'Indeterminado',
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }

                          setDialogState(() {
                            sexo = value;
                          });
                        },
                      ),

                      const SizedBox(height: 10),

                      // =======================================================
                      // NASCIMENTO
                      // =======================================================

                      ListTile(
                        contentPadding:
                            EdgeInsets.zero,
                        leading: Icon(
                          Icons.cake_outlined,
                          color:
                              widget.theme.primary,
                        ),
                        title: const Text(
                          'Data de nascimento',
                        ),
                        subtitle: Text(
                          dataNascimento == null ||
                                  dataNascimento!.isEmpty
                              ? 'Não informada'
                              : _dateBr(
                                  dataNascimento!,
                                ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.calendar_month,
                          ),
                          onPressed: () async {
                            final date =
                                await _selectDate(
                              context,
                              initial:
                                  dataNascimento,
                            );

                            if (date == null) {
                              return;
                            }

                            setDialogState(() {
                              dataNascimento = date;
                            });
                          },
                        ),
                      ),

                      const Divider(),

                      // =======================================================
                      // CLASSIFICAÇÃO FOB
                      // =======================================================

                      const SizedBox(height: 8),

                      Text(
                        'Classificação FOB',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight:
                                  FontWeight.w800,
                            ),
                      ),

                      const SizedBox(height: 10),

                      DropdownButtonFormField<String>(
                        value: selectedFob != null &&
                                fobRows.any(
                                  (r) =>
                                      r['raca']
                                          ?.toString() ==
                                      selectedFob,
                                )
                            ? selectedFob
                            : null,
                        isExpanded: true,
                        decoration:
                            InputDecoration(
                          labelText: fobRows.isEmpty
                              ? 'Raça / variedade FOB'
                              : 'Raça / classificação FOB',
                          prefixIcon:
                              const Icon(
                            Icons.menu_book_outlined,
                          ),
                        ),
                        items: fobRows.isEmpty
                            ? const <
                                DropdownMenuItem<
                                    String>>[]
                            : _uniqueFobItems(
                                fobRows,
                              ),
                        onChanged: fobRows.isEmpty
                            ? null
                            : (value) {
                                setDialogState(() {
                                  selectedFob =
                                      value;

                                  final item =
                                      _findFob(
                                    fobRows,
                                    value,
                                  );

                                  if (item == null) {
                                    return;
                                  }

                                  final familia =
                                      item['familia']
                                              ?.toString()
                                              .trim() ??
                                          '';

                                  final mutacao =
                                      item['mutacao']
                                              ?.toString()
                                              .trim() ??
                                          '';

                                  if (familia
                                      .isNotEmpty) {
                                    familiaController
                                            .text =
                                        familia;
                                  }

                                  if (mutacao
                                      .isNotEmpty) {
                                    mutacaoController
                                            .text =
                                        mutacao;
                                  }
                                });
                              },
                      ),

                      if (fobRows.isEmpty)
                        Padding(
                          padding:
                              const EdgeInsets.only(
                            top: 6,
                          ),
                          child: Text(
                            'Catálogo FOB ainda não carregado.',
                            style: TextStyle(
                              color:
                                  Colors.orange.shade800,
                              fontSize: 12,
                            ),
                          ),
                        ),

                      if (selectedCatalog != null)
                        Padding(
                          padding:
                              const EdgeInsets.only(
                            top: 8,
                          ),
                          child: Container(
                            padding:
                                const EdgeInsets.all(
                              10,
                            ),
                            decoration:
                                BoxDecoration(
                              color: widget
                                  .theme
                                  .primary
                                  .withOpacity(
                                0.06,
                              ),
                              borderRadius:
                                  BorderRadius.circular(
                                10,
                              ),
                            ),
                            child: Text(
                              [
                                if ((selectedCatalog[
                                            'segmento']
                                        ?.toString()
                                        .trim() ??
                                    '')
                                    .isNotEmpty)
                                  'Segmento: ${selectedCatalog['segmento']}',
                                if ((selectedCatalog[
                                            'familia']
                                        ?.toString()
                                        .trim() ??
                                    '')
                                    .isNotEmpty)
                                  'Família: ${selectedCatalog['familia']}',
                                if ((selectedCatalog[
                                            'categoria']
                                        ?.toString()
                                        .trim() ??
                                    '')
                                    .isNotEmpty)
                                  'Categoria: ${selectedCatalog['categoria']}',
                                if ((selectedCatalog[
                                            'codigo']
                                        ?.toString()
                                        .trim() ??
                                    '')
                                    .isNotEmpty)
                                  'Código: ${selectedCatalog['codigo']}',
                              ].join('\n'),
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 10),

                      TextField(
                        controller:
                            familiaController,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Família / linha',
                          hintText:
                              'Ex.: Arlequim Português',
                          prefixIcon: Icon(
                            Icons.category_outlined,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller:
                            variedadeController,
                        decoration:
                            const InputDecoration(
                          labelText: 'Variedade',
                          hintText:
                              'Ex.: variegado, lipocrômico...',
                          prefixIcon: Icon(
                            Icons.palette_outlined,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller:
                            mutacaoController,
                        decoration:
                            const InputDecoration(
                          labelText: 'Mutação',
                          hintText:
                              'Ex.: canela, ágata, opalino...',
                          prefixIcon: Icon(
                            Icons.biotech_outlined,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      DropdownButtonFormField<String>(
                        value: segmento,
                        decoration:
                            const InputDecoration(
                          labelText: 'Segmento',
                          prefixIcon: Icon(
                            Icons.tune_outlined,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Cor',
                            child: Text('Cor'),
                          ),
                          DropdownMenuItem(
                            value: 'Porte',
                            child: Text('Porte'),
                          ),
                          DropdownMenuItem(
                            value: 'Canto',
                            child: Text('Canto'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }

                          setDialogState(() {
                            segmento = value;
                          });
                        },
                      ),

                      const SizedBox(height: 10),

                      SwitchListTile(
                        contentPadding:
                            EdgeInsets.zero,
                        title: const Text(
                          'Topete',
                        ),
                        subtitle: const Text(
                          'Marque se a ave possui topete.',
                        ),
                        value: topete,
                        onChanged: (value) {
                          setDialogState(() {
                            topete = value;
                          });
                        },
                      ),

                      const Divider(),

                      // =======================================================
                      // ORIGEM
                      // =======================================================

                      const SizedBox(height: 8),

                      Text(
                        'Origem',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight:
                                  FontWeight.w800,
                            ),
                      ),

                      const SizedBox(height: 10),

                      DropdownButtonFormField<String>(
                        value: origem,
                        isExpanded: true,
                        decoration:
                            const InputDecoration(
                          labelText: 'Origem',
                          prefixIcon: Icon(
                            Icons.source_outlined,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value:
                                'Nascido no canaril',
                            child: Text(
                              'Nascido no canaril',
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Adquirido',
                            child: Text(
                              'Adquirido',
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }

                          setDialogState(() {
                            origem = value;
                          });
                        },
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller:
                            origemDetalheController,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Detalhes da origem',
                          hintText:
                              'Criador, canaril, cidade, anilha de origem...',
                          prefixIcon: Icon(
                            Icons.info_outline,
                          ),
                        ),
                        maxLines: 2,
                      ),

                      const Divider(),

                      // =======================================================
                      // OBSERVAÇÕES
                      // =======================================================

                      const SizedBox(height: 8),

                      Text(
                        'Observações',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight:
                                  FontWeight.w800,
                            ),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller:
                            observacoesController,
                        maxLines: 4,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Observações da ave',
                          hintText:
                              'Características, comportamento, histórico...',
                          prefixIcon: Icon(
                            Icons.notes_outlined,
                          ),
                        ),
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
                FilledButton.icon(
                  onPressed: () {
                    if (anilhaController.text
                        .trim()
                        .isEmpty) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Informe a anilha da ave.',
                          ),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                      true,
                    );
                  },
                  icon: const Icon(
                    Icons.save_outlined,
                  ),
                  label: const Text(
                    'Salvar',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true) {
      anilhaController.dispose();
      nomeController.dispose();
      gaiolaController.dispose();
      familiaController.dispose();
      variedadeController.dispose();
      mutacaoController.dispose();
      origemDetalheController.dispose();
      observacoesController.dispose();
      return;
    }

    final anilha = anilhaController.text.trim();

    if (anilha.isEmpty) {
      anilhaController.dispose();
      nomeController.dispose();
      gaiolaController.dispose();
      familiaController.dispose();
      variedadeController.dispose();
      mutacaoController.dispose();
      origemDetalheController.dispose();
      observacoesController.dispose();
      return;
    }

    final data = <String, Object?>{
      'anilha': anilha,
      'nome': nomeController.text.trim(),
      'gaiola': gaiolaController.text.trim(),
      'sexo': sexo,
      'segmento': segmento,
      'familia': familiaController.text.trim(),
      'raca': selectedFob ?? '',
      'variedade': variedadeController.text.trim(),
      'mutacao': mutacaoController.text.trim(),
      'topete': topete ? 1 : 0,
      'origem': origem,
      'origem_detalhe':
          origemDetalheController.text.trim(),
      'data_nascimento': dataNascimento,
      'foto_path': fotoPath ?? '',
      'observacoes':
          observacoesController.text.trim(),
      'status': 'ATIVA',
      'criado_em': old == null
          ? DateTime.now().toIso8601String()
          : _stringValue(
              old,
              'criado_em',
            ),
    };

    try {
      if (old == null) {
        await db.insert(
          'aves',
          data,
          conflictAlgorithm:
              ConflictAlgorithm.abort,
        );
      } else {
        await db.update(
          'aves',
          data,
          where: 'id = ?',
          whereArgs: [
            old['id'],
          ],
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              old == null
                  ? 'Ave cadastrada com sucesso.'
                  : 'Ave atualizada com sucesso.',
            ),
          ),
        );
      }

      await load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Não foi possível salvar a ave: $e',
            ),
          ),
        );
      }
    }

    anilhaController.dispose();
    nomeController.dispose();
    gaiolaController.dispose();
    familiaController.dispose();
    variedadeController.dispose();
    mutacaoController.dispose();
    origemDetalheController.dispose();
    observacoesController.dispose();
  }

  // ===========================================================================
  // BAIXA DA AVE
  // ===========================================================================

  Future<void> discharge(
    Map<String, Object?> row,
  ) async {
    final motivoController =
        TextEditingController();

    final destinoController =
        TextEditingController();

    final observacoesController =
        TextEditingController();

    String tipo = 'Venda';

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Text(
                'Baixar ave',
              ),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Ave: ${_stringValue(row, 'anilha')}',
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: tipo,
                        decoration:
                            const InputDecoration(
                          labelText: 'Motivo',
                          prefixIcon: Icon(
                            Icons.remove_circle_outline,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Venda',
                            child: Text('Venda'),
                          ),
                          DropdownMenuItem(
                            value: 'Doação',
                            child: Text('Doação'),
                          ),
                          DropdownMenuItem(
                            value: 'Morte',
                            child: Text('Morte'),
                          ),
                          DropdownMenuItem(
                            value: 'Aposentadoria',
                            child: Text(
                              'Aposentadoria',
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Outro',
                            child: Text('Outro'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }

                          setDialogState(() {
                            tipo = value;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller:
                            destinoController,
                        decoration:
                            const InputDecoration(
                          labelText: 'Destino',
                          hintText:
                              'Nome do comprador, criador, local etc.',
                          prefixIcon: Icon(
                            Icons.place_outlined,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller:
                            observacoesController,
                        maxLines: 3,
                        decoration:
                            const InputDecoration(
                          labelText: 'Observações',
                          prefixIcon: Icon(
                            Icons.notes_outlined,
                          ),
                        ),
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
                    'Confirmar baixa',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true) {
      motivoController.dispose();
      destinoController.dispose();
      observacoesController.dispose();
      return;
    }

    try {
      final db = await DBHelper.db;

      await db.insert(
        'baixas',
        {
          'ave_id': row['id'],
          'data':
              DateTime.now().toIso8601String(),
          'motivo': tipo,
          'destino':
              destinoController.text.trim(),
          'observacoes':
              observacoesController.text.trim(),
        },
      );

      await db.update(
        'aves',
        {
          'status': 'INATIVA',
        },
        where: 'id = ?',
        whereArgs: [
          row['id'],
        ],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Ave baixada sem apagar seu histórico.',
            ),
          ),
        );
      }

      await load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao registrar baixa: $e',
            ),
          ),
        );
      }
    }

    motivoController.dispose();
    destinoController.dispose();
    observacoesController.dispose();
  }

  // ===========================================================================
  // FILTRO
  // ===========================================================================

  List<Map<String, Object?>> get filteredRows {
    return rows.where(
      (row) {
        final text = [
          _stringValue(row, 'anilha'),
          _stringValue(row, 'nome'),
          _stringValue(row, 'raca'),
          _stringValue(row, 'familia'),
          _stringValue(row, 'variedade'),
          _stringValue(row, 'mutacao'),
          _stringValue(row, 'gaiola'),
        ].join(' ').toLowerCase();

        final matchesQuery =
            query.trim().isEmpty ||
                text.contains(
                  query.trim().toLowerCase(),
                );

        final matchesSex =
            selectedSex == null ||
                _stringValue(row, 'sexo') ==
                    selectedSex;

        final matchesSegment =
            selectedSegment == null ||
                _stringValue(row, 'segmento') ==
                    selectedSegment;

        final matchesOrigin =
            selectedOrigin == null ||
                _stringValue(row, 'origem') ==
                    selectedOrigin;

        return matchesQuery &&
            matchesSex &&
            matchesSegment &&
            matchesOrigin;
      },
    ).toList();
  }

  void clearFilters() {
    setState(() {
      selectedSex = null;
      selectedSegment = null;
      selectedOrigin = null;
    });
  }

  // ===========================================================================
  // CARD DA AVE
  // ===========================================================================

  Widget _birdCard(
    Map<String, Object?> row,
  ) {
    final foto =
        _stringValue(row, 'foto_path');

    final hasPhoto = foto.isNotEmpty &&
        File(foto).existsSync();

    final sexo =
        _stringValue(row, 'sexo');

    final anilha =
        _stringValue(row, 'anilha');

    final nome =
        _stringValue(row, 'nome');

    final raca =
        _stringValue(row, 'raca');

    final gaiola =
        _stringValue(row, 'gaiola');

    final familia =
        _stringValue(row, 'familia');

    final topete =
        ((row['topete'] as int?) ?? 0) == 1;

    final subtitleParts = <String>[];

    if (sexo.isNotEmpty) {
      subtitleParts.add(sexo);
    }

    if (gaiola.isNotEmpty) {
      subtitleParts.add(
        'Gaiola $gaiola',
      );
    }

    if (raca.isNotEmpty) {
      subtitleParts.add(raca);
    }

    if (familia.isNotEmpty &&
        familia != raca) {
      subtitleParts.add(familia);
    }

    return Card(
      margin: const EdgeInsets.fromLTRB(
        12,
        0,
        12,
        8,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        leading: hasPhoto
            ? CircleAvatar(
                radius: 27,
                backgroundImage:
                    FileImage(
                  File(foto),
                ),
              )
            : CircleAvatar(
                radius: 27,
                backgroundColor:
                    widget.theme.primary
                        .withOpacity(0.12),
                child: Icon(
                  sexo == 'Macho'
                      ? Icons.male
                      : sexo == 'Fêmea'
                          ? Icons.female
                          : Icons.flutter_dash,
                  color:
                      widget.theme.primary,
                ),
              ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                nome.isEmpty
                    ? anilha
                    : '$anilha · $nome',
                style: const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
            if (topete)
              const Tooltip(
                message: 'Ave com topete',
                child: Icon(
                  Icons.auto_awesome,
                  size: 18,
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding:
              const EdgeInsets.only(
            top: 5,
          ),
          child: Text(
            subtitleParts.isEmpty
                ? 'Sem classificação'
                : subtitleParts.join(' · '),
          ),
        ),
        trailing:
            PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              edit(row);
            } else if (value == 'out') {
              discharge(row);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(
                  Icons.edit_outlined,
                ),
                title: Text('Editar'),
                contentPadding:
                    EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'out',
              child: ListTile(
                leading: Icon(
                  Icons.remove_circle_outline,
                ),
                title: Text(
                  'Baixar ave',
                ),
                contentPadding:
                    EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final filtered = filteredRows;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Plantel',
        ),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: load,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () => edit(),
        icon: const Icon(
          Icons.add,
        ),
        label: const Text(
          'Nova ave',
        ),
      ),
      body: Column(
        children: [
          // ================================================================
          // BUSCA
          // ================================================================

          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              12,
              12,
              12,
              8,
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  query = value;
                });
              },
              decoration:
                  InputDecoration(
                prefixIcon:
                    const Icon(
                  Icons.search,
                ),
                suffixIcon:
                    query.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                query = '';
                              });
                            },
                            icon: const Icon(
                              Icons.clear,
                            ),
                          )
                        : null,
                hintText:
                    'Buscar por anilha, nome, raça, gaiola...',
                border:
                    const OutlineInputBorder(),
              ),
            ),
          ),

          // ================================================================
          // FILTROS
          // ================================================================

          SingleChildScrollView(
            scrollDirection:
                Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            child: Row(
              children: [
                DropdownButton<String>(
                  hint: const Text(
                    'Sexo',
                  ),
                  value: selectedSex,
                  items: const [
                    DropdownMenuItem(
                      value: 'Macho',
                      child: Text(
                        'Macho',
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Fêmea',
                      child: Text(
                        'Fêmea',
                      ),
                    ),
                    DropdownMenuItem(
                      value:
                          'Indeterminado',
                      child: Text(
                        'Indeterminado',
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedSex = value;
                    });
                  },
                ),
                const SizedBox(
                  width: 16,
                ),
                DropdownButton<String>(
                  hint: const Text(
                    'Segmento',
                  ),
                  value: selectedSegment,
                  items: const [
                    DropdownMenuItem(
                      value: 'Cor',
                      child: Text(
                        'Cor',
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Porte',
                      child: Text(
                        'Porte',
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Canto',
                      child: Text(
                        'Canto',
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedSegment =
                          value;
                    });
                  },
                ),
                const SizedBox(
                  width: 16,
                ),
                DropdownButton<String>(
                  hint: const Text(
                    'Origem',
                  ),
                  value: selectedOrigin,
                  items: const [
                    DropdownMenuItem(
                      value:
                          'Nascido no canaril',
                      child: Text(
                        'Nascido no canaril',
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Adquirido',
                      child: Text(
                        'Adquirido',
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedOrigin =
                          value;
                    });
                  },
                ),
                if (selectedSex != null ||
                    selectedSegment !=
                        null ||
                    selectedOrigin !=
                        null)
                  Padding(
                    padding:
                        const EdgeInsets
                            .only(
                      left: 8,
                    ),
                    child: TextButton.icon(
                      onPressed:
                          clearFilters,
                      icon: const Icon(
                        Icons.clear_all,
                      ),
                      label: const Text(
                        'Limpar',
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ================================================================
          // CONTADOR
          // ================================================================

          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              16,
              4,
              16,
              8,
            ),
            child: Row(
              children: [
                Text(
                  '${filtered.length} ave${filtered.length == 1 ? '' : 's'}',
                  style: Theme.of(
                    context,
                  )
                      .textTheme
                      .titleSmall
                      ?.copyWith(
                        fontWeight:
                            FontWeight.w700,
                      ),
                ),
                const Spacer(),
                if (selectedSex != null ||
                    selectedSegment !=
                        null ||
                    selectedOrigin !=
                        null)
                  const Icon(
                    Icons.filter_alt,
                    size: 18,
                  ),
              ],
            ),
          ),

          // ================================================================
          // LISTA
          // ================================================================

          Expanded(
            child: loading
                ? const Center(
                    child:
                        CircularProgressIndicator(),
                  )
                : filtered.isEmpty
                    ? RefreshIndicator(
                        onRefresh: load,
                        child:
                            ListView(
                          physics:
                              const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(
                              height: 90,
                            ),
                            Center(
                              child: Icon(
                                Icons
                                    .sentiment_dissatisfied_outlined,
                                size: 50,
                              ),
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            Center(
                              child: Text(
                                'Nenhuma ave encontrada.',
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: load,
                        child:
                            ListView.builder(
                          padding:
                              const EdgeInsets
                                  .only(
                            bottom: 100,
                          ),
                          itemCount:
                              filtered.length,
                          itemBuilder:
                              (context, index) {
                            return _birdCard(
                              filtered[
                                  index],
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
