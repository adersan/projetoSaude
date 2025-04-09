
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/exercicio_model.dart';

class EditarExercicioScreen extends StatefulWidget {
  final Exercicio exercicio;

  const EditarExercicioScreen({super.key, required this.exercicio});

  @override
  State<EditarExercicioScreen> createState() => _EditarExercicioScreenState();
}

class _EditarExercicioScreenState extends State<EditarExercicioScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _duracaoController;
  late TextEditingController _observacoesController;
  late String _tipoSelecionado;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.exercicio.nome);
    _duracaoController = TextEditingController(text: widget.exercicio.duracao.toString());
    _observacoesController = TextEditingController(text: widget.exercicio.observacoes);
    _tipoSelecionado = widget.exercicio.tipo;
  }

  void _atualizarExercicio() async {
    if (_formKey.currentState!.validate()) {
      final exercicioAtualizado = Exercicio(
        id: widget.exercicio.id,
        nome: _nomeController.text,
        tipo: _tipoSelecionado,
        duracao: int.tryParse(_duracaoController.text) ?? 0,
        data: widget.exercicio.data,
        observacoes: _observacoesController.text,
        usuarioId: widget.exercicio.usuarioId,
      );

      await DatabaseHelper().updateExercicio(exercicioAtualizado);
      Navigator.pop(context, true);
    }
  }

  Widget _buildInput(String label, TextEditingController controller, {TextInputType tipo = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: tipo,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Exercício'),
        backgroundColor: Color(0xFFE0CFFF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildInput('Nome do exercício', _nomeController),
              _buildInput('Duração (minutos)', _duracaoController, tipo: TextInputType.number),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DropdownButtonFormField<String>(
                  value: _tipoSelecionado,
                  items: ['Cardio', 'Força', 'Flexibilidade', 'Outro']
                      .map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)))
                      .toList(),
                  onChanged: (value) => setState(() => _tipoSelecionado = value!),
                  decoration: InputDecoration(
                    labelText: 'Tipo de exercício',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              _buildInput('Observações', _observacoesController),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: _atualizarExercicio,
                child: Text('Atualizar'),
              ),
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
