
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../database/database_helper.dart';
import '../models/exercicio_model.dart';

class ExerciciosDashboardScreen extends StatefulWidget {
  final int usuarioId;

  const ExerciciosDashboardScreen({super.key, required this.usuarioId});

  @override
  State<ExerciciosDashboardScreen> createState() => _ExerciciosDashboardScreenState();
}

class _ExerciciosDashboardScreenState extends State<ExerciciosDashboardScreen> {
  List<Exercicio> _exercicios = [];
  Map<String, int> _duracaoPorDia = {};
  int _totalHoje = 0;
  int _metaDiaria = 30;
  int _passosEstimados = 0;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  void _carregarDados() async {
    final lista = await DatabaseHelper().getExercicios(widget.usuarioId);
    final hoje = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final agora = DateTime.now();
    Map<String, int> tempDuracoes = {};
    int totalHoje = 0;

    for (var e in lista) {
      tempDuracoes[e.data] = (tempDuracoes[e.data] ?? 0) + e.duracao;
      if (e.data == hoje) totalHoje += e.duracao;
    }

    setState(() {
      _exercicios = lista;
      _duracaoPorDia = tempDuracoes;
      _totalHoje = totalHoje;
      _passosEstimados = totalHoje * 100; // estimativa: 100 passos por minuto
    });
  }

  List<BarChartGroupData> _gerarBarras() {
    final dias = List.generate(7, (i) {
      final dia = DateTime.now().subtract(Duration(days: 6 - i));
      return DateFormat('yyyy-MM-dd').format(dia);
    });

    return dias.map((data) {
      final duracao = _duracaoPorDia[data] ?? 0;
      return BarChartGroupData(x: dias.indexOf(data), barRods: [
        BarChartRodData(toY: duracao.toDouble(), width: 16, color: Color(0xFF6C4F9E)),
      ]);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Desempenho de Exercícios'),
        backgroundColor: Color(0xFFE0CFFF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumo de hoje:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                _buildResumoCard('Minutos hoje', '$_totalHoje min'),
                _buildResumoCard('Meta diária', '$_metaDiaria min',
                    atingida: _totalHoje >= _metaDiaria),
                _buildResumoCard('Passos estimados', '$_passosEstimados'),
              ],
            ),
            SizedBox(height: 32),
            Text(
              'Gráfico dos últimos 7 dias:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 1.5,
              child: BarChart(
                BarChartData(
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final dias = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(dias[value.toInt() % 7]),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _gerarBarras(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumoCard(String titulo, String valor, {bool atingida = true}) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(right: 12),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: atingida ? Colors.green.shade100 : Colors.red.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(valor, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(titulo, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
