import 'package:flutter/material.dart';
import 'medicamentos_screen.dart';
import 'detalhes_medicamento_screen.dart';
import '../database/database_helper.dart';
import '../models/medicamento_model.dart';

class DashboardScreen extends StatefulWidget {
  final String nomeUsuario;

  const DashboardScreen({super.key, required this.nomeUsuario});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Medicamento> _medicamentos = [];

  @override
  void initState() {
    super.initState();
    _carregarMedicamentos();
  }

  void _carregarMedicamentos() async {
    final lista = await DatabaseHelper().getMedicamentos();
    lista.sort((a, b) => a.horarioInicial.compareTo(b.horarioInicial));
    setState(() {
      _medicamentos = lista;
    });
  }

  void _abrirTelaMedicamentos() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MedicamentosScreen()),
    );
    _carregarMedicamentos();
  }

  @override
  Widget build(BuildContext context) {
    final horaAtual = TimeOfDay.fromDateTime(DateTime.now());
    final medicamentosOrdenados = [..._medicamentos];
    medicamentosOrdenados.sort((a, b) {
      final aHora = TimeOfDay(
          hour: int.parse(a.horariosGerados.first.split(":")[0]),
          minute: int.parse(a.horariosGerados.first.split(":")[1]));
      final bHora = TimeOfDay(
          hour: int.parse(b.horariosGerados.first.split(":")[0]),
          minute: int.parse(b.horariosGerados.first.split(":")[1]));
      final aPassado = aHora.hour < horaAtual.hour ||
          (aHora.hour == horaAtual.hour && aHora.minute <= horaAtual.minute);
      final bPassado = bHora.hour < horaAtual.hour ||
          (bHora.hour == horaAtual.hour && bHora.minute <= horaAtual.minute);
      if (aPassado && !bPassado) return 1;
      if (!aPassado && bPassado) return -1;
      return aHora.hour.compareTo(bHora.hour);
    });

    return Scaffold(
      backgroundColor: Color(0xFFFAF5FF),
      appBar: AppBar(
        title: Text('Início', style: TextStyle(color: Colors.black87)),
        backgroundColor: Color(0xFFE0CFFF),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Olá, ${widget.nomeUsuario}!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5A468E),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Veja seu resumo de hoje:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildCard(context, 'Medicamentos', Icons.medication,
                    _abrirTelaMedicamentos),
                _buildCard(context, 'Exercícios', Icons.fitness_center, () {}),
                _buildCard(context, 'Nutrição', Icons.restaurant, () {}),
                _buildCard(context, 'Relatórios', Icons.bar_chart, () {}),
              ],
            ),
            SizedBox(height: 32),
            Text(
              'Próximas atividades:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Expanded(
              child: medicamentosOrdenados.isEmpty
                  ? Text('Nenhum medicamento cadastrado.')
                  : ListView.builder(
                      itemCount: medicamentosOrdenados.length,
                      itemBuilder: (context, index) {
                        final m = medicamentosOrdenados[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetalhesMedicamentoScreen(medicamento: m),
                              ),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 12),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.alarm, color: Color(0xFF6C4F9E)),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Tomar ${m.nome} às ${m.horariosGerados.first}',
                                    style: TextStyle(fontSize: 16),
                                  ),
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

  Widget _buildCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (MediaQuery.of(context).size.width - 72) / 2,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: Color(0xFF6C4F9E)),
            SizedBox(height: 8),
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5A468E),
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}