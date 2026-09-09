import 'package:flutter/material.dart';
import 'navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _senhaOculta = true;
  bool _carregando = false;

  void _realizarLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _carregando = true;
      });

      // Simula a validação segura da chave do criador
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _carregando = false;
        });

        // Navegação limpa substituindo a rota para impedir o criador de voltar ao login usando o botão "voltar" do celular
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NavigationScreen()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logotipo / Ícone Identificador do Sistema
                const Icon(
                  Icons.shield_outlined,
                  size: 80,
                  color: Color(0xFFFFD700), // Amarelo Canário Canônico
                ),
                const SizedBox(height: 16),
                const Text(
                  "CanaryControl Pro",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const Text(
                  "Acesso Seguro ao Canaril",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // Campo de E-mail do Criador
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-mail do Criador',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Por favor, insira seu e-mail';
                    if (!val.contains('@') || !val.contains('.')) return 'Insira um e-mail válido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo de Senha com Controle de Visibilidade
                TextFormField(
                  controller: _senhaController,
                  obscureText: _senhaOculta,
                  decoration: InputDecoration(
                    labelText: 'Senha de Segurança',
                    border: OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(_senhaOculta ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _senhaOculta = !_senhaOculta),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Por favor, insira sua senha';
                    if (val.length < 6) return 'A senha deve conter pelo menos 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Botão de Acionamento com Feedback de Carregamento
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _carregando ? null : _realizarLogin,
                    child: _carregando
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            'Autenticar no Sistema',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
