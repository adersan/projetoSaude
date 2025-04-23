
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/medicamento_model.dart';
import '../database/database_helper.dart';

class EditarMedicamentoScreen extends StatefulWidget {
  final Medicamento medicamento;

  const EditarMedicamentoScreen({Key? key, required this.medicamento})
      : super(key: key);

  @override
  State<EditarMedicamentoScreen> createState() => _EditarMedicamentoScreenState();
}

class _EditarMedicamentoScreenState extends State<EditarMedicamentoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _quantidadeController;
  late TextEditingController _observacoesController;

  String _unidadeSelecionada = 'mg';
  int _vezesPorDia = 1;
  late TimeOfDay _horarioInicial;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.medicamento.nome);
    _quantidadeController = TextEditingController(text: widget.medicamento.quantidade.toString());
    _observacoesController = TextEditingController(text: widget.medicamento.observacoes);
    _unidadeSelecionada = widget.medicamento.unidade;
    _vezesPorDia = widget.medicamento.vezesPorDia;

    try {
      final parsedDate = DateFormat.jm().parse(widget.medicamento.horarioInicial);
      _horarioInicial = TimeOfDay.fromDateTime(parsedDate);
    } catch (e) {
      _horarioInicial = TimeOfDay.now(); // fallback
    }
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

  void _atualizarMedicamento() async {
    if (_formKey.currentState!.validate()) {
      final horariosGerados = _gerarHorarios(_horarioInicial, _vezesPorDia);
      final medicamentoAtualizado = Medicamento(
        id: widget.medicamento.id,
        nome: _nomeController.text,
        quantidade: double.parse(_quantidadeController.text),
        unidade: _unidadeSelecionada,
        vezesPorDia: _vezesPorDia,
        horarioInicial: _horarioInicial.format(context),
        horariosGerados: horariosGerados,
        observacoes: _observacoesController.text,
        usuarioId: widget.medicamento.usuarioId,
      );

      await DatabaseHelper().updateMedicamento(medicamentoAtualizado);
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
    final horarioLabel = _horarioInicial.format(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Medicamento'),
        backgroundColor: Color(0xFFE0CFFF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildInput('Nome', _nomeController),
              _buildInput('Quantidade', _quantidadeController, tipo: TextInputType.number),
              Row(children: [
                Text('Unidade:'),
                SizedBox(width: 12),
                DropdownButton<String>(value: _unidadeSelecionada, items: ['mg', 'ml', 'un'].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(), onChanged: (value) => setState(() => _unidadeSelecionada = value!)),
                Spacer(),
                Text('Vezes/dia:'),
                SizedBox(width: 12),
                DropdownButton<int>(value: _vezesPorDia, items: List.generate(6, (i) => i + 1).map((v) => DropdownMenuItem(value: v, child: Text('$v'))).toList(), onChanged: (value) => setState(() => _vezesPorDia = value!)),
              ]),
              SizedBox(height: 12),
              Align(alignment: Alignment.centerLeft, child: Text('Horário inicial: $horarioLabel')),
              TextButton.icon(onPressed: _selecionarHorarioInicial, icon: Icon(Icons.access_time), label: Text('Selecionar horário')),
              _buildInput('Observações', _observacoesController),
              ElevatedButton(onPressed: _atualizarMedicamento, child: Text('Atualizar')),
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancelar')),
            ],
          ),
        ),
      ),
    );
  }
}
