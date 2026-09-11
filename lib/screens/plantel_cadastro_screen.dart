import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../models/ave_model.dart';

class PlantelCadastroScreen extends StatefulWidget {
  const PlantelCadastroScreen({super.key});

  @override
  State<PlantelCadastroScreen> createState() =>
      _PlantelCadastroScreenState();
}

class _PlantelCadastroScreenState
    extends State<PlantelCadastroScreen> {
  final form = GlobalKey<FormState>();

  final clube = TextEditingController(text: 'GO');
  final anilha = TextEditingController();
  final ano = TextEditingController();
  final nome = TextEditingController();
  final gaiola = TextEditingController();

  String sexo = 'M';
  String raca = '';

  Future<void> save() async {
    if (!form.currentState!.validate()) {
      return;
    }

    final ave = Ave(
      clubeSigla: clube.text.trim().toUpperCase(),
      anilha: anilha.text.trim(),
      anoNascimento: ano.text.trim(),
      sexo: sexo,
      nome: nome.text.trim().isEmpty
          ? null
          : nome.text.trim(),
      raca: raca.isEmpty ? null : raca,
      numeroGaiola: gaiola.text.trim(),
    );

    await DbHelper.instance.upsertAve(ave);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar ave'),
      ),
      body: Form(
        key: form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: clube,
              decoration: const InputDecoration(
                labelText: 'Sigla do clube FOB',
              ),
              validator: (v) {
                if (v == null || v.trim().length != 2) {
                  return 'Use 2 letras';
                }
                return null;
              },
            ),

            TextFormField(
              controller: anilha,
              decoration: const InputDecoration(
                labelText: 'Número da anilha',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Informe a anilha';
                }
                return null;
              },
            ),

            TextFormField(
              controller: ano,
              decoration: const InputDecoration(
                labelText: 'Ano de nascimento',
              ),
            ),

            DropdownButtonFormField<String>(
              value: sexo,
              decoration: const InputDecoration(
                labelText: 'Sexo',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'M',
                  child: Text('Macho'),
                ),
                DropdownMenuItem(
                  value: 'F',
                  child: Text('Fêmea'),
                ),
              ],
              onChanged: (v) {
                if (v != null) {
                  setState(() => sexo = v);
                }
              },
            ),

            TextFormField(
              controller: nome,
              decoration: const InputDecoration(
                labelText: 'Nome (opcional)',
              ),
            ),

            TextFormField(
              controller: gaiola,
              decoration: const InputDecoration(
                labelText: 'Número da gaiola',
              ),
            ),

            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Raça / selecione do catálogo FOB',
              ),
              onChanged: (v) {
                raca = v;
              },
            ),

            const SizedBox(height: 20),

            FilledButton(
              onPressed: save,
              child: const Text('Salvar ave'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    clube.dispose();
    anilha.dispose();
    ano.dispose();
    nome.dispose();
    gaiola.dispose();
    super.dispose();
  }
}
