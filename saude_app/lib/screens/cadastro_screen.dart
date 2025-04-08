import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../database/database_helper.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _idadeController = TextEditingController();

  bool _senhaVisivel = false;

  void _cadastrarUsuario() async {
    if (_formKey.currentState!.validate()) {
      final user = User(
        nome: _nomeController.text,
        email: _emailController.text,
        senha: _senhaController.text,
        idade: int.parse(_idadeController.text),
      );

      try {
        final id = await DatabaseHelper().insertUser(user);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuário cadastrado com sucesso!')),
        );
        Navigator.pop(context); // Voltar para login
      } catch (e) {
        if (e.toString().contains('UNIQUE constraint failed')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Este e-mail já está cadastrado.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao cadastrar: \$e')),
          );
        }
      }
    }
  }

  Widget _buildInput(String label, TextEditingController controller,
      {bool isPassword = false, TextInputType tipo = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: tipo,
        obscureText: isPassword && !_senhaVisivel,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _senhaVisivel ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _senhaVisivel = !_senhaVisivel;
                    });
                  },
                )
              : null,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Campo obrigatório';
          if (label == 'Email' && !value.contains('@')) return 'Email inválido';
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF5FF),
      appBar: AppBar(
        title: const Text('Cadastro'),
        backgroundColor: const Color(0xFFE0CFFF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildInput('Nome', _nomeController),
              _buildInput('Email', _emailController, tipo: TextInputType.emailAddress),
              _buildInput('Senha', _senhaController, isPassword: true),
              _buildInput('Idade', _idadeController, tipo: TextInputType.number),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _cadastrarUsuario,
                child: const Text('Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}