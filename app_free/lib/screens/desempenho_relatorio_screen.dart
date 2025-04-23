
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import '../helpers/dados_desempenho_flutter.dart';
import '../helpers/mensagem_motivacional_flutter.dart';
import '../helpers/relatorio_pdf_helper.dart';

class DesempenhoRelatorioScreen extends StatefulWidget {
  final int usuarioId;
  const DesempenhoRelatorioScreen({super.key, required this.usuarioId});
  @override
  State<DesempenhoRelatorioScreen> createState() => _DesempenhoRelatorioScreenState();
}

class _DesempenhoRelatorioScreenState extends State<DesempenhoRelatorioScreen> {
  String _filtroSelecionado = '7 dias';
  Map<String, Map<String, int>> _dados = {};
  final GlobalKey _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final dias = _getDiasFiltro();
    final dados = await carregarDadosDesempenho(widget.usuarioId, dias);
    setState(() {
      _dados = dados;
    });
  }

  int _getDiasFiltro() {
    return _filtroSelecionado == '15 dias' ? 15 : _filtroSelecionado == '30 dias' ? 30 : 7;
  }

  @override
  Widget build(BuildContext context) {
    final diasKeys = _dados.keys.toList()..sort();
    final totalMed = _dados.values.fold(0, (sum, d) => sum + (d['med'] ?? 0));
    final totalExe = _dados.values.fold(0, (sum, d) => sum + (d['exe'] ?? 0));
    final totalNut = _dados.values.fold(0, (sum, d) => sum + (d['nut'] ?? 0));
    final total = totalMed + totalExe + totalNut;
    final dias = _getDiasFiltro();

    return Scaffold(
      appBar: AppBar(
        title: Text('Desempenho / Relatório'),
        backgroundColor: Color(0xFFE0CFFF),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _exportarRelatorio,
        child: Icon(Icons.picture_as_pdf),
        backgroundColor: Color(0xFF6C4F9E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: RepaintBoundary(
          key: _globalKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(gerarMensagemMotivacional(total, dias),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              SizedBox(height: 16),
              Text('Período:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: _filtroSelecionado,
                items: ['7 dias', '15 dias', '30 dias']
                    .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _filtroSelecionado = value);
                    _carregarDados();
                  }
                },
              ),
              SizedBox(height: 16),
              Text('Atividades por dia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              AspectRatio(
                aspectRatio: 1.6,
                child: BarChart(
                  BarChartData(
                    barTouchData: BarTouchData(enabled: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= diasKeys.length) return Text('');
                            final dia = DateFormat('dd/MM').format(DateTime.parse(diasKeys[index]));
                            return Text(dia, style: TextStyle(fontSize: 10));
                          },
                        ),
                      ),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(diasKeys.length, (i) {
                      final dia = diasKeys[i];
                      final total = (_dados[dia]?['med'] ?? 0) +
                          (_dados[dia]?['exe'] ?? 0) +
                          (_dados[dia]?['nut'] ?? 0);
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(toY: total.toDouble(), width: 16),
                        ],
                      );
                    }),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text('Resumo:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildResumoBox('Medicamentos', totalMed.toString()),
                  _buildResumoBox('Exercícios', totalExe.toString()),
                  _buildResumoBox('Refeições', totalNut.toString()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResumoBox(String label, String valor) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFFFAF5FF),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Text(valor, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        SizedBox(height: 6),
        Text(label, style: TextStyle(color: Color(0xFF5A468E))),
      ],
    );
  }

  Future<void> _exportarRelatorio() async {
    try {
      final dias = _getDiasFiltro();
      final pdfBytes = await gerarRelatorioPDF(
        nomeUsuario: 'Usuário',
        periodo: _filtroSelecionado,
        totalMed: _dados.values.fold(0, (s, d) => s + (d['med'] ?? 0)),
        totalExe: _dados.values.fold(0, (s, d) => s + (d['exe'] ?? 0)),
        totalNut: _dados.values.fold(0, (s, d) => s + (d['nut'] ?? 0)),
        mensagemMotivacional: gerarMensagemMotivacional(
            _dados.values.fold(0, (s, d) => s + (d['med'] ?? 0) + (d['exe'] ?? 0) + (d['nut'] ?? 0)), dias),
        dadosPorDia: _dados,
      );

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/relatorio.pdf');
      await file.writeAsBytes(pdfBytes);
      await Share.shareXFiles([XFile(file.path)], text: 'Meu relatório de desempenho');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao exportar relatório: $e')));
    }
  }
}
