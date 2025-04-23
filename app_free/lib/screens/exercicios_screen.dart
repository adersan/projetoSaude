
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/exercicio_model.dart';
import '../database/database_helper.dart';
import 'editar_exercicio_screen.dart';

class ExerciciosScreen extends StatefulWidget {
  final int usuarioId;
  const ExerciciosScreen({super.key, required this.usuarioId});

  @override
  State<ExerciciosScreen> createState() => _ExerciciosScreenState();
}

class _ExerciciosScreenState extends State<ExerciciosScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _duracaoController = TextEditingController();
  final _observacoesController = TextEditingController();
  TimeOfDay _horarioSelecionado = TimeOfDay.now();
  String _tipoSelecionado = 'Cardio';
  List<String> _diasSelecionados = [];

  List<Exercicio> _exercicios = [];

  final List<String> _diasSemana = [
    'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo', 'Todos'
  ];

  @override
  void initState() {
    super.initState();
    _carregarExercicios();
  }

  void _carregarExercicios() async {
    final lista = await DatabaseHelper().getExercicios(widget.usuarioId);
    setState(() {
      _exercicios = lista;
    });
  }

  void _salvarExercicio() async {
    if (_formKey.currentState!.validate()) {
      if (_diasSelecionados.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Selecione pelo menos um dia.')));
        return;
      }

      final exercicio = Exercicio(
        nome: _nomeController.text,
        tipo: _tipoSelecionado,
        duracao: int.tryParse(_duracaoController.text) ?? 0,
        data: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        horario: _horarioSelecionado.format(context),
        diasSemana: _diasSelecionados,
        observacoes: _observacoesController.text,
        usuarioId: widget.usuarioId,
      );

      await DatabaseHelper().insertExercicio(exercicio);

      _resetarFormulario();
      _carregarExercicios();
    }
  }

  void _resetarFormulario() {
    _formKey.currentState?.reset();
    _nomeController.clear();
    _duracaoController.clear();
    _observacoesController.clear();
    _tipoSelecionado = 'Cardio';
    _diasSelecionados = [];
    _horarioSelecionado = TimeOfDay.now();
    setState(() {});
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
        title: Text('Exercícios'),
        backgroundColor: Color(0xFFE0CFFF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Dias da semana:'),
                  ),
                  _buildDiasSemanaSelector(),
                  _buildInput('Observações', _observacoesController),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _salvarExercicio,
                    child: Text('Salvar'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Expanded(
              child: _exercicios.isEmpty
                  ? Text('Nenhum exercício registrado.')
                  : ListView.builder(
                      itemCount: _exercicios.length,
                      itemBuilder: (context, index) {
                        final ex = _exercicios[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text('${ex.nome} - ${ex.duracao} min'),
                            subtitle: Text('${ex.tipo} | ${ex.horario}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () async {
                                    final atualizado = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EditarExercicioScreen(exercicio: ex),
                                      ),
                                    );
                                    if (atualizado == true) _carregarExercicios();
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    await DatabaseHelper().deleteExercicio(ex.id!);
                                    _carregarExercicios();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}
