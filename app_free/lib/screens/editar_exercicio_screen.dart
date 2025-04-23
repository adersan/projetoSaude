
import 'package:flutter/material.dart';
import '../models/exercicio_model.dart';
import '../database/database_helper.dart';

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
  late TimeOfDay _horarioSelecionado;
  late String _tipoSelecionado;
  List<String> _diasSelecionados = [];

  final List<String> _diasSemana = [
    'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo', 'Todos'
  ];

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.exercicio.nome);
    _duracaoController = TextEditingController(text: widget.exercicio.duracao.toString());
    _observacoesController = TextEditingController(text: widget.exercicio.observacoes);
    _tipoSelecionado = widget.exercicio.tipo;
    _horarioSelecionado = _parseHorario(widget.exercicio.horario);
    _diasSelecionados = widget.exercicio.diasSemana;
  }

  TimeOfDay _parseHorario(String h) {
    final partes = h.split(':');
    return TimeOfDay(
      hour: int.tryParse(partes[0]) ?? 0,
      minute: int.tryParse(partes[1]) ?? 0,
    );
  }

  void _selecionarHorario() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _horarioSelecionado,
    );
    if (picked != null) {
      setState(() {
        _horarioSelecionado = picked;
      });
    }
  }

  void _toggleDia(String dia) {
    setState(() {
      if (dia == 'Todos') {
        _diasSelecionados = ['Todos'];
      } else {
        _diasSelecionados.remove('Todos');
        if (_diasSelecionados.contains(dia)) {
          _diasSelecionados.remove(dia);
        } else {
          _diasSelecionados.add(dia);
        }
      }
    });
  }

  void _atualizarExercicio() async {
    if (_formKey.currentState!.validate()) {
      final exercicioAtualizado = Exercicio(
        id: widget.exercicio.id,
        nome: _nomeController.text,
        tipo: _tipoSelecionado,
        duracao: int.tryParse(_duracaoController.text) ?? 0,
        data: widget.exercicio.data,
        horario: _horarioSelecionado.format(context),
        diasSemana: _diasSelecionados,
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

  Widget _buildDiasSemanaSelector() {
    return Wrap(
      spacing: 8,
      children: _diasSemana.map((dia) {
        final selecionado = _diasSelecionados.contains(dia);
        return FilterChip(
          label: Text(dia),
          selected: selecionado,
          onSelected: (_) => _toggleDia(dia),
          selectedColor: Color(0xFF6C4F9E).withOpacity(0.2),
          checkmarkColor: Color(0xFF6C4F9E),
        );
      }).toList(),
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
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Horário: ${_horarioSelecionado.format(context)}'),
              ),
              TextButton.icon(
                onPressed: _selecionarHorario,
                icon: Icon(Icons.access_time),
                label: Text('Selecionar horário'),
              ),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Dias da semana:'),
              ),
              _buildDiasSemanaSelector(),
              _buildInput('Observações', _observacoesController),
              SizedBox(height: 12),
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
