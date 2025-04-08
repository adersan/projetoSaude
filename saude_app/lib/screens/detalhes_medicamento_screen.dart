import 'package:flutter/material.dart';
import '../models/medicamento_model.dart';

class DetalhesMedicamentoScreen extends StatelessWidget {
  final Medicamento medicamento;

  const DetalhesMedicamentoScreen({super.key, required this.medicamento});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF5FF),
      appBar: AppBar(
        title: const Text('Detalhes do Medicamento'),
        backgroundColor: const Color(0xFFE0CFFF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              medicamento.nome,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5A468E),
              ),
            ),
            const SizedBox(height: 16),
            Text('Quantidade: ${medicamento.quantidade} ${medicamento.unidade}',
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Vezes ao dia: ${medicamento.vezesPorDia}',
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Horários:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: medicamento.horariosGerados.map((h) {
                return Chip(label: Text(h));
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text('Observações:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(medicamento.observacoes.isEmpty
                ? 'Nenhuma observação.'
                : medicamento.observacoes),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Voltar'),
              ),
            )
          ],
        ),
      ),
    );
  }
}