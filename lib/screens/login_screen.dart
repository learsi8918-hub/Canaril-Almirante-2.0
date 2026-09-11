import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../database/db_helper.dart';
import '../models/criador_model.dart';
import 'navigation_screen.dart';

String _hash(String s) => sha256.convert(utf8.encode(s)).toString();

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Criador? c;

  final senha = TextEditingController();
  final nome = TextEditingController();
  final sigla = TextEditingController();
  final cidade = TextEditingController();
  final estado = TextEditingController();
  final novaSenha = TextEditingController();
  final confirma = TextEditingController();

  String? logo;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    c = await DbHelper.instance.criador();
    setState(() => loading = false);
  }

  Future<void> _logo() async {
    final x = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (x != null) {
      setState(() => logo = x.path);
    }
  }

  Future<void> _create() async {
    if (nome.text.trim().isEmpty ||
        novaSenha.text.length < 4 ||
        novaSenha.text != confirma.text) {
      _msg(
        'Preencha o nome e uma senha de pelo menos 4 caracteres.',
      );
      return;
    }

    final n = Criador(
      nome: nome.text.trim(),
      siglaClube: sigla.text.trim().toUpperCase(),
      cidade: cidade.text.trim(),
      estado: estado.text.trim(),
      logoPath: logo,
      senhaHash: _hash(novaSenha.text),
    );

    await DbHelper.instance.salvarCriador(n);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const NavigationScreen(),
        ),
      );
    }
  }

  Future<void> _enter() async {
    if (c == null) return;

    if (_hash(senha.text) != c!.senhaHash) {
      _msg('Senha incorreta.');
      return;
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const NavigationScreen(),
        ),
      );
    }
  }

  void _msg(String s) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s),
      ),
    );
  }

  InputDecoration _dec(String l) {
    return InputDecoration(
      labelText: l,
      border: const OutlineInputBorder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final first = c == null;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 520,
              ),
              child: Column(
                children: [
                  if (!first &&
                      c!.logoPath != null &&
                      File(c!.logoPath!).existsSync())
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.file(
                        File(c!.logoPath!),
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    const Icon(
                      Icons.flutter_dash,
                      size: 80,
                    ),

                  const SizedBox(height: 12),

                  Text(
                    first ? 'CANARY CONTROL PRO' : c!.nome,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),

                  const SizedBox(height: 24),

                  if (first) ...[
                    TextField(
                      controller: nome,
                      decoration: _dec('Nome do Canaril'),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: sigla,
                      decoration: _dec(
                        'Sigla do Clube FOB (opcional)',
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: cidade,
                      decoration: _dec('Cidade'),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: estado,
                      decoration: _dec('Estado'),
                    ),

                    const SizedBox(height: 12),

                    OutlinedButton.icon(
                      onPressed: _logo,
                      icon: const Icon(Icons.image),
                      label: Text(
                        logo == null
                            ? 'Adicionar logo'
                            : 'Trocar logo',
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: novaSenha,
                      obscureText: true,
                      decoration: _dec('Criar senha'),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: confirma,
                      obscureText: true,
                      decoration: _dec('Confirmar senha'),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _create,
                        child: const Text(
                          'CRIAR MEU CANARIL',
                        ),
                      ),
                    ),
                  ] else ...[
                    TextField(
                      controller: senha,
                      obscureText: true,
                      decoration: _dec('Senha'),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _enter,
                        child: const Text('ENTRAR'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
