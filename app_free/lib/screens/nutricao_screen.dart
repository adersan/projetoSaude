
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/nutricao_model.dart';
import '../database/database_helper.dart';
import 'editar_nutricao_screen.dart';

class NutricaoScreen extends StatefulWidget {
  final int usuarioId;
  const NutricaoScreen({super.key, required this.usuarioId});

  @override
  State<NutricaoScreen> createState() => _NutricaoScreenState();
}

class _NutricaoScreenState extends State<NutricaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _observacoesController = TextEditingController();
  String _tipoSelecionado = 'Café da manhã';
  TimeOfDay _horarioSelecionado = TimeOfDay.now();
  List<String> _diasSelecionados = [];
  final List<String> _diasSemana = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo', 'Todos'];

  List<Nutricao> _refeicoes = [];

  @override
  void initState() {
    super.initState();
    _carregarRefeicoes();
  }

  void _carregarRefeicoes() async {
    final lista = await DatabaseHelper().getNutricao(widget.usuarioId);
    setState(() {
      _refeicoes = lista;
    });
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

  void _salvarRefeicao() async {
    if (_formKey.currentState!.validate()) {
      if (_diasSelecionados.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Selecione ao menos um dia.')));
        return;
      }

      final nutricao = Nutricao(
        tipo: _tipoSelecionado,
        descricao: _descricaoController.text,
        horario: _horarioSelecionado.format(context),
        diasSemana: _diasSelecionados,
        observacoes: _observacoesController.text,
        usuarioId: widget.usuarioId,
      );
      print('Salvando refeição com usuarioId: ${widget.usuarioId}');
      await DatabaseHelper().insertNutricao(nutricao);
      _descricaoController.clear();
      _observacoesController.clear();
      _tipoSelecionado = 'Café da manhã';
      _diasSelecionados = [];
      _horarioSelecionado = TimeOfDay.now();

      _carregarRefeicoes();
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
        title: Text('Nutrição'),
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: DropdownButtonFormField<String>(
                      value: _tipoSelecionado,
                      items: ['Café da manhã', 'Almoço', 'Jantar', 'Lanche', 'Suplemento']
                          .map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)))
                          .toList(),
                      onChanged: (value) => setState(() => _tipoSelecionado = value!),
                      decoration: InputDecoration(
                        labelText: 'Tipo de refeição',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  _buildInput('Descrição', _descricaoController),
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
                  onPressed: () async {
                    _salvarRefeicao();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Refeição salva com sucesso!')),
                    );
                  },
                    
                    child: Text('Salvar'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Expanded(
              child: _refeicoes.isEmpty
                  ? Text('Nenhuma refeição registrada.')
                  : ListView.builder(
                      itemCount: _refeicoes.length,
                      itemBuilder: (context, index) {
                        final r = _refeicoes[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text('${r.tipo}: ${r.descricao}'),
                            subtitle: Text('${r.horario} - ${r.diasSemana.join(', ')}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () async {
                                    final atualizado = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EditarNutricaoScreen(nutricao: r),
                                      ),
                                    );
                                    if (atualizado == true) _carregarRefeicoes();
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    await DatabaseHelper().deleteNutricao(r.id!);
                                    _carregarRefeicoes();
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
