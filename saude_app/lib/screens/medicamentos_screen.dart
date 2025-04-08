import 'package:flutter/material.dart';
import '../models/medicamento_model.dart';
import '../database/database_helper.dart';

class MedicamentosScreen extends StatefulWidget {
  final int usuarioId;
  const MedicamentosScreen({super.key, required this.usuarioId});

  @override
  State<MedicamentosScreen> createState() => _MedicamentosScreenState();
}

class _MedicamentosScreenState extends State<MedicamentosScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _observacoesController = TextEditingController();

  String _unidadeSelecionada = 'mg';
  int _vezesPorDia = 1;
  TimeOfDay _horarioInicial = TimeOfDay.now();

  List<Medicamento> _medicamentos = [];
  int? _editandoId;

  @override
  void initState() {
    super.initState();
    _carregarMedicamentos();
  }

  void _carregarMedicamentos() async {
    final lista = await DatabaseHelper().getMedicamentos(widget.usuarioId);
    setState(() {
      _medicamentos = lista;
    });
  }

  void _selecionarHorarioInicial() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _horarioInicial,
    );
    if (picked != null) {
      setState(() {
        _horarioInicial = picked;
      });
    }
  }

  List<String> _gerarHorarios(TimeOfDay base, int vezes) {
    List<String> horarios = [];
    int intervalo = (24 / vezes).round();
    for (int i = 0; i < vezes; i++) {
      final hora = (base.hour + (i * intervalo)) % 24;
      final minuto = base.minute;
      final time = TimeOfDay(hour: hora, minute: minuto);
      horarios.add(time.format(context));
    }
    return horarios;
  }

  void _salvarMedicamento() async {
    if (_formKey.currentState!.validate()) {
      final horariosGerados = _gerarHorarios(_horarioInicial, _vezesPorDia);
      final medicamento = Medicamento(
        id: _editandoId,
        nome: _nomeController.text,
        quantidade: double.parse(_quantidadeController.text),
        unidade: _unidadeSelecionada,
        vezesPorDia: _vezesPorDia,
        horarioInicial: _horarioInicial.format(context),
        horariosGerados: horariosGerados,
        observacoes: _observacoesController.text,
        usuarioId: widget.usuarioId,
      );

      if (_editandoId == null) {
        await DatabaseHelper().insertMedicamento(medicamento);
      } else {
        await DatabaseHelper().deleteMedicamento(_editandoId!);
        await DatabaseHelper().insertMedicamento(medicamento);
      }

      _resetarFormulario();
      _carregarMedicamentos();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Medicamento salvo com sucesso')),
      );
    }
  }

  void _resetarFormulario() {
    _formKey.currentState?.reset();
    _nomeController.clear();
    _quantidadeController.clear();
    _observacoesController.clear();
    _vezesPorDia = 1;
    _unidadeSelecionada = 'mg';
    _horarioInicial = TimeOfDay.now();
    _editandoId = null;
    setState(() {});
  }

  void _preencherFormularioParaEdicao(Medicamento m) {
    _nomeController.text = m.nome;
    _quantidadeController.text = m.quantidade.toString();
    _unidadeSelecionada = m.unidade;
    _vezesPorDia = m.vezesPorDia;
    _observacoesController.text = m.observacoes;
    _horarioInicial = TimeOfDay(
      hour: int.parse(m.horarioInicial.split(':')[0]),
      minute: int.parse(m.horarioInicial.split(':')[1]),
    );
    _editandoId = m.id;
    setState(() {});
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
    final horarioLabel = _horarioInicial.format(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Medicamentos'),
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
                  _buildInput('Nome', _nomeController),
                  _buildInput('Quantidade', _quantidadeController, tipo: TextInputType.number),
                  Row(
                    children: [
                      Text('Unidade:'),
                      SizedBox(width: 12),
                      DropdownButton<String>(
                        value: _unidadeSelecionada,
                        items: ['mg', 'ml', 'un'].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                        onChanged: (value) {
                          setState(() {
                            _unidadeSelecionada = value!;
                          });
                        },
                      ),
                      Spacer(),
                      Text('Vezes/dia:'),
                      SizedBox(width: 12),
                      DropdownButton<int>(
                        value: _vezesPorDia,
                        items: List.generate(6, (i) => i + 1).map((v) => DropdownMenuItem(value: v, child: Text('$v'))).toList(),
                        onChanged: (value) {
                          setState(() {
                            _vezesPorDia = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Horário inicial: $horarioLabel'),
                  ),
                  TextButton.icon(
                    onPressed: _selecionarHorarioInicial,
                    icon: Icon(Icons.access_time),
                    label: Text('Selecionar horário'),
                  ),
                  _buildInput('Observações', _observacoesController),
                  ElevatedButton(
                    onPressed: _salvarMedicamento,
                    child: Text(_editandoId == null ? 'Salvar' : 'Atualizar'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: _medicamentos.isEmpty
                  ? Center(child: Text('Nenhum medicamento cadastrado.'))
                  : ListView.builder(
                      itemCount: _medicamentos.length,
                      itemBuilder: (context, index) {
                        final m = _medicamentos[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            title: Text('${m.nome} - ${m.quantidade}${m.unidade}'),
                            subtitle: Text('Horários: ${m.horariosGerados.join(', ')}'),
                            onTap: () => _preencherFormularioParaEdicao(m),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await DatabaseHelper().deleteMedicamento(m.id!);
                                _carregarMedicamentos();
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}