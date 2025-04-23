
import 'package:intl/intl.dart';
import '../database/database_helper.dart';

Future<Map<String, Map<String, int>>> carregarDadosDesempenho(int usuarioId, int dias) async {
  final db = await DatabaseHelper().database;
  final DateTime hoje = DateTime.now();
  final DateTime inicio = hoje.subtract(Duration(days: dias - 1));

  Map<String, Map<String, int>> mapa = {};

  final meds = await db.query('medicamentos', where: 'usuarioId = ?', whereArgs: [usuarioId]);
  for (var m in meds) {
    final gerados = (m['horariosGerados'] as String).split(',');
    final data = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (!mapa.containsKey(data)) mapa[data] = {};
    mapa[data]!['med'] = (mapa[data]!['med'] ?? 0) + gerados.length;
  }

  final exs = await db.query('exercicios', where: 'usuarioId = ?', whereArgs: [usuarioId]);
  for (var e in exs) {
    final diasSemana = (e['diasSemana'] as String).split(',');
    for (int i = 0; i < dias; i++) {
      final dia = inicio.add(Duration(days: i));
      final nomeDia = DateFormat('EEEE', 'pt_BR').format(dia);
      if (diasSemana.contains('Todos') || diasSemana.contains(nomeDia)) {
        final d = DateFormat('yyyy-MM-dd').format(dia);
        mapa[d] ??= {};
        mapa[d]!['exe'] = (mapa[d]!['exe'] ?? 0) + 1;
      }
    }
  }

  final nuts = await db.query('nutricao', where: 'usuarioId = ?', whereArgs: [usuarioId]);
  for (var r in nuts) {
    final diasSemana = (r['diasSemana'] as String).split(',');
    for (int i = 0; i < dias; i++) {
      final dia = inicio.add(Duration(days: i));
      final nomeDia = DateFormat('EEEE', 'pt_BR').format(dia);
      if (diasSemana.contains('Todos') || diasSemana.contains(nomeDia)) {
        final d = DateFormat('yyyy-MM-dd').format(dia);
        mapa[d] ??= {};
        mapa[d]!['nut'] = (mapa[d]!['nut'] ?? 0) + 1;
      }
    }
  }

  return mapa;
}
