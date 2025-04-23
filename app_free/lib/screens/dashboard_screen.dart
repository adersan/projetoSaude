
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/medicamento_model.dart';
import '../models/exercicio_model.dart';
import '../models/nutricao_model.dart';
import 'medicamentos_screen.dart';
import 'exercicios_screen.dart';
import 'nutricao_screen.dart';
import 'desempenho_relatorio_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String nomeUsuario;
  final int usuarioId;

  const DashboardScreen({super.key, required this.nomeUsuario, required this.usuarioId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Medicamento> _medicamentos = [];
  List<Exercicio> _exercicios = [];
  List<Nutricao> _refeicoes = [];

  @override
  void initState() {
    super.initState();
    _carregarAtividades();
  }

  void _carregarAtividades() async {
    final meds = await DatabaseHelper().getMedicamentos(widget.usuarioId);
    final exs = await DatabaseHelper().getExercicios(widget.usuarioId);
    final nutr = await DatabaseHelper().getNutricao(widget.usuarioId);

    setState(() {
      _medicamentos = meds;
      _exercicios = exs;
      _refeicoes = nutr;
    });
  }

  void _abrirTelaMedicamentos() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MedicamentosScreen(usuarioId: widget.usuarioId),
      ),
    );
    _carregarAtividades();
  }

  void _abrirTelaExercicios() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciciosScreen(usuarioId: widget.usuarioId),
      ),
    );
    _carregarAtividades();
  }

  void _abrirTelaNutricao() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NutricaoScreen(usuarioId: widget.usuarioId),
      ),
    );
    _carregarAtividades();
  }

  void _abrirTelaRelatorio() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DesempenhoRelatorioScreen(usuarioId: widget.usuarioId),
      ),
    );
  }

  TimeOfDay parseHorario(String horario) {
    final partes = horario.split(':');
    return TimeOfDay(
      hour: int.tryParse(partes[0]) ?? 0,
      minute: int.tryParse(partes[1]) ?? 0,
    );
  }

  List<Map<String, dynamic>> _atividadesDoDia() {
    final hoje = DateFormat('EEEE', 'pt_BR').format(DateTime.now());
    final List<Map<String, dynamic>> lista = [];

    for (var m in _medicamentos) {
      final hora = parseHorario(m.horariosGerados.first);
      lista.add({'hora': hora, 'nome': 'Tomar ${m.nome}', 'tipo': 'medicamento'});
    }

    for (var e in _exercicios) {
      if (e.diasSemana.contains('Todos') || e.diasSemana.contains(hoje)) {
        final hora = parseHorario(e.horario);
        lista.add({'hora': hora, 'nome': e.nome, 'tipo': 'exercicio'});
      }
    }

    for (var r in _refeicoes) {
      if (r.diasSemana.contains('Todos') || r.diasSemana.contains(hoje)) {
        final hora = parseHorario(r.horario);
        lista.add({'hora': hora, 'nome': '${r.tipo}: ${r.descricao}', 'tipo': 'nutricao'});
      }
    }

    lista.sort((a, b) {
      final hA = a['hora'] as TimeOfDay;
      final hB = b['hora'] as TimeOfDay;
      return hA.hour != hB.hour ? hA.hour.compareTo(hB.hour) : hA.minute.compareTo(hB.minute);
    });

    return lista;
  }

  @override
  Widget build(BuildContext context) {
    final atividades = _atividadesDoDia();

    return Scaffold(
      appBar: AppBar(
        title: Text('Início'),
        backgroundColor: Color(0xFFE0CFFF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Olá, ${widget.nomeUsuario}!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF5A468E)),
            ),
            SizedBox(height: 8),
            Text('Resumo do seu dia:'),
            SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildCard(context, 'Medicamentos', Icons.medication, _abrirTelaMedicamentos),
                _buildCard(context, 'Exercícios', Icons.fitness_center, _abrirTelaExercicios),
                _buildCard(context, 'Desempenho/Relatório', Icons.show_chart, _abrirTelaRelatorio),
                _buildCard(context, 'Nutrição', Icons.restaurant_menu, _abrirTelaNutricao),
              ],
            ),
            SizedBox(height: 24),
            Text(
              'Próximas atividades:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Expanded(
              child: atividades.isEmpty
                  ? Center(child: Text('Nenhuma atividade cadastrada para hoje.'))
                  : ListView.builder(
                      itemCount: atividades.length,
                      itemBuilder: (context, index) {
                        final a = atividades[index];
                        final hora = a['hora'] as TimeOfDay;
                        final nome = a['nome'];
                        final tipo = a['tipo'];

                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                tipo == 'medicamento'
                                    ? Icons.medication
                                    : tipo == 'exercicio'
                                        ? Icons.fitness_center
                                        : Icons.restaurant,
                                color: Color(0xFF6C4F9E),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '${hora.format(context)} - $nome',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
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

  Widget _buildCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (MediaQuery.of(context).size.width - 72) / 2,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: Color(0xFF6C4F9E)),
            SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF5A468E),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
