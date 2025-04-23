import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'medicamentos_screen.dart';
import 'detalhes_medicamento_screen.dart';
import 'exercicios_screen.dart';
import 'exercicios_dashboard_screen.dart';
import '../database/database_helper.dart';
import '../models/medicamento_model.dart';
import '../models/exercicio_model.dart';

// Tela principal do aplicativo, exibindo um resumo das atividades
class DashboardScreen extends StatefulWidget {
  final String nomeUsuario; // Nome do usuário para saudação
  final int usuarioId; // ID do usuário para buscar dados no banco

  const DashboardScreen({
    super.key,
    required this.nomeUsuario,
    required this.usuarioId,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Medicamento> _medicamentos = []; // Lista de medicamentos carregados
  List<Exercicio> _exercicios = []; // Lista de exercícios carregados

  @override
  void initState() {
    super.initState();
    _carregarAtividades(); // Carrega atividades ao inicializar
  }

  // Carrega medicamentos e exercícios do banco
  void _carregarAtividades() async {
    final meds = await DatabaseHelper().getMedicamentos(widget.usuarioId);
    final exs = await DatabaseHelper().getExercicios(widget.usuarioId);

    // Ordena os medicamentos pelos horários
    meds.sort((a, b) => a.horarioInicial.compareTo(b.horarioInicial));

    // Atualiza o estado com as listas carregadas
    setState(() {
      _medicamentos = meds;
      _exercicios = exs;
    });
  }

  // Abre a tela de medicamentos
  void _abrirTelaMedicamentos() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MedicamentosScreen(usuarioId: widget.usuarioId),
      ),
    );
    _carregarAtividades(); // Recarrega atividades ao retornar
  }

  // Abre a tela de exercícios
  void _abrirTelaExercicios() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciciosScreen(usuarioId: widget.usuarioId),
      ),
    );
    _carregarAtividades(); // Recarrega atividades ao retornar
  }

  // Abre o dashboard de desempenho de exercícios
  void _abrirDashboardExercicios() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciciosDashboardScreen(usuarioId: widget.usuarioId),
      ),
    );
  }

  // Converte horários do banco para TimeOfDay
  TimeOfDay parseHorario(String horario) {
    try {
      final format = DateFormat.jm(); // Formato "hh:mm AM/PM"
      final dt = format.parse(horario);
      return TimeOfDay.fromDateTime(dt);
    } catch (e) {
      final partes = horario.split(':'); // Divide o horário manualmente
      return TimeOfDay(
        hour: int.tryParse(partes[0]) ?? 0,
        minute: int.tryParse(partes[1]) ?? 0,
      );
    }
  }

  // Organiza e retorna todas as atividades do dia
  List<Map<String, dynamic>> _atividadesDoDia() {
    final hoje = DateFormat(
      'EEEE',
      'pt_BR',
    ).format(DateTime.now()); // Dia atual em português
    final agora = TimeOfDay.fromDateTime(DateTime.now()); // Hora atual

    List<Map<String, dynamic>> lista = [];

    // Adiciona medicamentos à lista de atividades
    for (var m in _medicamentos) {
      final hora = parseHorario(m.horariosGerados.first);
      lista.add({
        'tipo': 'medicamento',
        'nome': 'Tomar ${m.nome}',
        'hora': hora,
        'objeto': m,
      });
    }

    // Adiciona exercícios à lista de atividades
    for (var e in _exercicios) {
      if (e.diasSemana.contains('Todos') || e.diasSemana.contains(hoje)) {
        final hora = parseHorario(e.horario);
        lista.add({
          'tipo': 'exercicio',
          'nome': e.nome,
          'hora': hora,
          'objeto': e,
        });
      }
    }

    // Ordena as atividades por horário
    lista.sort((a, b) {
      final aHora = a['hora'] as TimeOfDay;
      final bHora = b['hora'] as TimeOfDay;
      return aHora.hour != bHora.hour
          ? aHora.hour.compareTo(bHora.hour)
          : aHora.minute.compareTo(bHora.minute);
    });

    return lista;
  }

  @override
  Widget build(BuildContext context) {
    final atividades = _atividadesDoDia(); // Recupera atividades organizadas

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
              'Olá, ' + widget.nomeUsuario + '!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5A468E),
              ),
            ),
            SizedBox(height: 8),
            Text('Veja seu resumo de hoje:', style: TextStyle(fontSize: 16)),
            SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildCard(
                  context,
                  'Medicamentos',
                  Icons.medication,
                  _abrirTelaMedicamentos,
                ),
                _buildCard(
                  context,
                  'Exercícios',
                  Icons.fitness_center,
                  _abrirTelaExercicios,
                ),
                _buildCard(
                  context,
                  'Desempenho',
                  Icons.show_chart,
                  _abrirDashboardExercicios,
                ),
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
              child:
                  atividades.isEmpty
                      ? Text('Nenhuma atividade cadastrada.')
                      : ListView.builder(
                        itemCount: atividades.length,
                        itemBuilder: (context, index) {
                          final item = atividades[index];
                          final hora = item['hora'] as TimeOfDay;
                          final nome = item['nome'];
                          final tipo = item['tipo'];

                          return Container(
                            margin: EdgeInsets.only(bottom: 12),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  tipo == 'medicamento'
                                      ? Icons.medication
                                      : Icons.fitness_center,
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
            ),
          ],
        ),
      ),
    );
  }

  // Cria os botões do painel principal
  Widget _buildCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
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
            ),
          ],
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
