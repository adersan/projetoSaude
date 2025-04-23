
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';

Future<Uint8List> gerarRelatorioPDF({
  required String nomeUsuario,
  required String periodo,
  required int totalMed,
  required int totalExe,
  required int totalNut,
  required String mensagemMotivacional,
  required Map<String, Map<String, int>> dadosPorDia,
}) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Relatório de Desempenho', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Text('Usuário: \$nomeUsuario'),
            pw.Text('Período: \$periodo'),
            pw.SizedBox(height: 16),
            pw.Text('Resumo:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Bullet(text: 'Medicamentos: \$totalMed'),
            pw.Bullet(text: 'Exercícios: \$totalExe'),
            pw.Bullet(text: 'Refeições: \$totalNut'),
            pw.SizedBox(height: 16),
            pw.Text('Mensagem:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(mensagemMotivacional),
            pw.SizedBox(height: 16),
            pw.Text('Atividades por dia:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Table.fromTextArray(
              headers: ['Data', 'Medic.', 'Exerc.', 'Nutri.'],
              data: dadosPorDia.entries.map((e) {
                final data = e.key;
                final v = e.value;
                return [
                  data,
                  (v['med'] ?? 0).toString(),
                  (v['exe'] ?? 0).toString(),
                  (v['nut'] ?? 0).toString()
                ];
              }).toList(),
            ),
          ],
        );
      },
    ),
  );

  return pdf.save();
}
