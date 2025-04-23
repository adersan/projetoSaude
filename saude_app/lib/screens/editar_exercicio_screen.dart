import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Biblioteca para manipulação de datas
import '../database/database_helper.dart'; // Acesso ao banco de dados
import '../models/exercicio_model.dart'; // Modelo de dados para exercícios

// Tela para editar as informações de um exercício específico
class EditarExercicioScreen extends StatefulWidget {
  // Exercicio a ser editado, passado como parâmetro
  final Exercicio exercicio;

  const EditarExercicioScreen({super.key, required this.exercicio});

  @override
  State<EditarExercicioScreen> createState() => _EditarExercicioScreenState();
}

class _EditarExercicioScreenState extends State<EditarExercicioScreen> {
  final _formKey = GlobalKey<FormState>(); // Chave para controlar o formulário

  // Controladores para capturar os valores dos campos de entrada
  late TextEditingController _nomeController;
  late TextEditingController _duracaoController;
  late TextEditingController _observacoesController;
  late String
  _tipoSelecionado; // Variável para armazenar o tipo de exercício selecionado

  @override
  void initState() {
    super.initState();
    // Inicializa os controladores com os valores atuais do exercício
    _nomeController = TextEditingController(text: widget.exercicio.nome);
    _duracaoController = TextEditingController(
      text: widget.exercicio.duracao.toString(),
    );
    _observacoesController = TextEditingController(
      text: widget.exercicio.observacoes,
    );
    _tipoSelecionado = widget.exercicio.tipo;
  }

  // Função para salvar as alterações no exercício
  void _atualizarExercicio() async {
    // Valida os campos do formulário antes de prosseguir
    if (_formKey.currentState!.validate()) {
      final exercicioAtualizado = Exercicio(
        id: widget.exercicio.id,
        nome: _nomeController.text,
        tipo: _tipoSelecionado,
        duracao:
            int.tryParse(_duracaoController.text) ??
            0, // Trata valor inválido como 0
        data: widget.exercicio.data, // Mantém a data original
        observacoes: _observacoesController.text,
        usuarioId: widget.exercicio.usuarioId, // Relaciona ao mesmo usuário
      );

      // Atualiza o exercício no banco de dados
      await DatabaseHelper().updateExercicio(exercicioAtualizado);

      // Retorna à tela anterior, indicando sucesso (true)
      Navigator.pop(context, true);
    }
  }

  // Função reutilizável para construir campos de entrada (TextFormField)
  Widget _buildInput(
    String label,
    TextEditingController controller, {
    TextInputType tipo = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ), // Margem inferior entre os campos
      child: TextFormField(
        controller: controller,
        keyboardType: tipo, // Define o tipo de entrada (texto, número, etc.)
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white, // Fundo branco para os campos
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ), // Borda arredondada
        ),
        validator:
            (value) =>
                value == null || value.isEmpty
                    ? 'Campo obrigatório'
                    : null, // Validação do campo
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Exercício'),
        backgroundColor: Color(0xFFE0CFFF), // Cor da AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(24), // Margem ao redor do conteúdo
        child: Form(
          key: _formKey, // Associa o formulário à sua chave de controle
          child: ListView(
            children: [
              // Campos de entrada
              _buildInput('Nome do exercício', _nomeController),
              _buildInput(
                'Duração (minutos)',
                _duracaoController,
                tipo: TextInputType.number,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DropdownButtonFormField<String>(
                  value: _tipoSelecionado, // Valor inicial do dropdown
                  items:
                      ['Cardio', 'Força', 'Flexibilidade', 'Outro']
                          .map(
                            (tipo) => DropdownMenuItem(
                              value: tipo,
                              child: Text(tipo),
                            ),
                          ) // Opções do dropdown
                          .toList(),
                  onChanged:
                      (value) => setState(
                        () => _tipoSelecionado = value!,
                      ), // Atualiza o estado ao alterar o valor
                  decoration: InputDecoration(
                    labelText: 'Tipo de exercício',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ), // Borda arredondada
                    filled: true,
                    fillColor: Colors.white, // Fundo branco para o dropdown
                  ),
                ),
              ),
              _buildInput('Observações', _observacoesController),
              SizedBox(height: 8), // Espaço entre os campos e os botões
              // Botão para atualizar o exercício
              ElevatedButton(
                onPressed: _atualizarExercicio,
                child: Text('Atualizar'),
              ),

              // Botão para cancelar e voltar à tela anterior
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
