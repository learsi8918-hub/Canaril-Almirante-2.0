import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  // ---------------------------------------------------------------------------
  // CARREGAR PLANTEL
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // AUXILIARES
  // ---------------------------------------------------------------------------

  String _stringValue(
    Map<String, Object?> row,
    String key,
  ) {
    return row[key]?.toString() ?? '';
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

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
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

  // ---------------------------------------------------------------------------
  // SELEÇÃO DE FOTO
  // ---------------------------------------------------------------------------

  Future<String?> _pickPhoto() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
    );

    return image?.path;
  }

  // ---------------------------------------------------------------------------
  // FORMULÁRIO DA AVE
  // ---------------------------------------------------------------------------

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

    String sexo =
        _stringValue(old ?? {}, 'sexo').isEmpty
            ? 'Macho'
            : _stringValue(old ?? {}, 'sexo');

    String segmento =
        _stringValue(old ?? {}, 'segmento').isEmpty
            ? 'Cor'
            : _stringValue(old ?? {}, 'segmento');

    String origem =
        _stringValue(old ?? {}, 'origem').isEmpty
            ? 'Nascido no canaril'
            : _stringValue(old ?? {}, 'origem');

    bool topete =
        (old?['topete'] as int? ?? 0) == 1;

    String? dataNascimento =
        _stringValue(old ?? {}, 'data_nascimento');

    String? fotoPath =
        _stringValue(old ?? {}, 'foto_path');

    String? selectedFob;

    final db = await DBHelper.db;

    // Carrega opções FOB para permitir seleção,
    // mantendo a possibilidade de cadastrar detalhes adicionais.
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
      final racaAtual =
          _stringValue(old, 'raca');

      if (racaAtual.isNotEmpty) {
        selectedFob = racaAtual;
      }
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                      // -------------------------------------------------------
                      // FOTO
                      // -------------------------------------------------------

                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: widget.theme.primary
                                    .withValues(alpha: 0.10),
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
                                      color: widget.theme.primary,
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

                      // -------------------------------------------------------
                      // IDENTIFICAÇÃO
                      // -------------------------------------------------------

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
                        decoration: const InputDecoration(
                          labelText: 'Anilha *',
                          prefixIcon:
                              Icon(Icons.confirmation_number_outlined),
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller: nomeController,
                        decoration: const InputDecoration(
                          labelText: 'Nome',
                          hintText: 'Opcional',
                          prefixIcon:
                              Icon(Icons.badge_outlined),
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller: gaiolaController,
                        decoration: const InputDecoration(
                          labelText: 'Gaiola',
                          prefixIcon:
                              Icon(Icons.grid_view_outlined),
                        ),
                      ),

                      const SizedBox(height: 10),

                      DropdownButtonFormField<String>(
                        value: sexo,
                        decoration: const InputDecoration(
                          labelText: 'Sexo',
                          prefixIcon:
                              Icon(Icons.wc_outlined),
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
                            child: Text('Indeterminado'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;

                          setDialogState(() {
                            sexo = value;
                          });
                        },
                      ),

                      const SizedBox(height: 10),

                      // -------------------------------------------------------
                      // NASCIMENTO
                      // -------------------------------------------------------

                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.cake_outlined,
                          color: widget.theme.primary,
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
                              initial: dataNascimento,
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

                      // -------------------------------------------------------
                      // CLASSIFICAÇÃO FOB
                      // -------------------------------------------------------

                      const SizedBox(height: 8),

                      Text(
                        'Classificação FOB',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),

                      const SizedBox(height: 10),

                      DropdownButtonFormField<String>(
                        value: selectedFob != null &&
                                fobRows.any(
                                  (r) =>
                                      r['raca']?.toString() ==
                                      selectedFob,
                                )
                            ? selectedFob
                            : null,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: fobRows.isEmpty
                              ? 'Raça / variedade FOB'
                              : 'Raça / classificação FOB',
                          prefixIcon: const Icon(
                            Icons.menu_book_outlined,
                          ),
                        ),
                        items: fobRows.isEmpty
                            ? const []
                            : _uniqueFobItems(
                                fobRows,
                              ),
                        onChanged: fobRows.isEmpty
                            ? null
                            : (value) {
                                setDialogState(() {
                                  selectedFob = value;
                                });
                              },
                      ),

                      if (fobRows.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 6,
                          ),
                          child: Text(
                            'Catálogo FOB ainda não carregado.',
                            style: TextStyle(
                              color: Colors.orange.shade800,
                              fontSize: 12,
                            ),
                          ),
                        ),

                      const SizedBox(height: 10),

                      TextField(
                        controller: familiaController,
                        decoration: const InputDecoration(
                          labelText: 'Família / linha',
                          hintText:
                              'Ex.: Arlequim Português',
                          prefixIcon:
                              Icon(Icons.category_outlined),
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller: variedadeController,
                        decoration: const InputDecoration(
                          labelText: 'Variedade',
                          hintText:
                              'Ex.: variegado, lipocrômico...',
                          prefixIcon:
                              Icon(Icons.palette_outlined),
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller: mutacaoController,
                        decoration: const InputDecoration(
                          labelText: 'Mutação',
                          hintText:
                              'Ex.: canela, ágata, opalino...',
                          prefixIcon:
                              Icon(Icons.biotech_outlined),
                        ),
                      ),

                      const SizedBox(height: 10),

                      DropdownButtonFormField<String>(
                        value: segmento,
                        decoration: const InputDecoration(
                          labelText: 'Segmento',
                          prefixIcon:
                              Icon(Icons.tune_outlined),
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
                          if (value == null) return;

                          setDialogState(() {
                            segmento = value;
                          });
                        },
                      ),

                      const SizedBox(height: 10),

                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
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

                      // -------------------------------------------------------
                      // ORIGEM
                      // ------
