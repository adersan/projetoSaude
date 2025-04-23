import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../database/database_helper.dart';

// Tela de Cadastro de Usuário
class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  // Chave global para manipular e validar o formulário
  final _formKey = GlobalKey<FormState>();

  // Controladores para capturar os valores dos campos de entrada
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _idadeController = TextEditingController();

  // Variável para controlar a visibilidade da senha
  bool _senhaVisivel = false;

  // Função para cadastrar usuário
  void _cadastrarUsuario() async {
    // Valida se todos os campos estão corretamente preenchidos
    if (_formKey.currentState!.validate()) {
      // Cria um objeto User com os dados fornecidos pelo usuário
      final user = User(
        nome: _nomeController.text,
        email: _emailController.text,
        senha: _senhaController.text,
        idade: int.parse(_idadeController.text),
      );

      try {
        // Insere usuário no banco de dados e captura o ID gerado
        final id = await DatabaseHelper().insertUser(user);

        // Mostra uma mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuário cadastrado com sucesso!')),
        );

        // Retorna para a tela anterior (provavelmente login)
        Navigator.pop(context);
      } catch (e) {
        // Tratamento de erro caso o e-mail já esteja cadastrado
        if (e.toString().contains('UNIQUE constraint failed')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Este e-mail já está cadastrado.')),
          );
        } else {
          // Mensagem genérica para outros erros
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erro ao cadastrar: $e')));
        }
      }
    }
  }

  // Função reutilizável para criar campos de entrada
  Widget _buildInput(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
    TextInputType tipo = TextInputType.text,
  }) {
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
          // Ícone para alternar visibilidade da senha
          suffixIcon:
              isPassword
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
        // Validações dos campos
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
      backgroundColor: const Color(0xFFFAF5FF), // Fundo da tela em um tom suave
      appBar: AppBar(
        title: const Text('Cadastro'),
        backgroundColor: const Color(
          0xFFE0CFFF,
        ), // Cor da AppBar combinando com a UI
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Campos de entrada usando a função _buildInput
              _buildInput('Nome', _nomeController),
              _buildInput(
                'Email',
                _emailController,
                tipo: TextInputType.emailAddress,
              ),
              _buildInput('Senha', _senhaController, isPassword: true),
              _buildInput(
                'Idade',
                _idadeController,
                tipo: TextInputType.number,
              ),
              const SizedBox(height: 20), // Espaçamento entre os inputs e botão
              // Botão para cadastrar usuário
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
