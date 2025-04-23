import 'package:flutter/material.dart';
import '../models/medicamento_model.dart';

// Tela que exibe os detalhes de um medicamento específico
class DetalhesMedicamentoScreen extends StatelessWidget {
  // Instância do modelo Medicamento passada como parâmetro
  final Medicamento medicamento;

  const DetalhesMedicamentoScreen({super.key, required this.medicamento});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFFAF5FF,
      ), // Definição da cor de fundo da tela em tom suave
      appBar: AppBar(
        title: const Text(
          'Detalhes do Medicamento',
        ), // Título exibido na AppBar
        backgroundColor: const Color(
          0xFFE0CFFF,
        ), // Cor de fundo da AppBar em tom pastel
      ),
      body: Padding(
        padding: const EdgeInsets.all(
          24,
        ), // Margem ao redor do conteúdo principal
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Alinhamento do conteúdo à esquerda
          children: [
            // Exibe o nome do medicamento com destaque
            Text(
              medicamento.nome,
              style: const TextStyle(
                fontSize: 24, // Tamanho grande para dar ênfase
                fontWeight: FontWeight.bold, // Negrito para destacar
                color: Color(0xFF5A468E), // Cor personalizada para diferenciar
              ),
            ),
            const SizedBox(height: 16), // Espaçamento entre elementos
            // Exibe a quantidade e a unidade do medicamento
            Text(
              'Quantidade: ${medicamento.quantidade} ${medicamento.unidade}',
              style: TextStyle(
                fontSize: 16,
              ), // Tamanho regular para texto informativo
            ),
            const SizedBox(height: 8),

            // Exibe o número de vezes ao dia que o medicamento deve ser administrado
            Text(
              'Vezes ao dia: ${medicamento.vezesPorDia}',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),

            // Título para a seção de horários
            Text(
              'Horários:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600, // Levemente destacado
              ),
            ),
            const SizedBox(height: 4),

            // Exibe os horários em forma de Chips organizados
            Wrap(
              spacing: 8, // Espaço horizontal entre os chips
              runSpacing: 8, // Espaço vertical quando os chips quebram linha
              children:
                  medicamento.horariosGerados.map((h) {
                    // Para cada horário, cria um Chip
                    return Chip(label: Text(h));
                  }).toList(),
            ),
            const SizedBox(height: 16),

            // Título para a seção de observações
            Text(
              'Observações:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600, // Levemente destacado
              ),
            ),
            const SizedBox(height: 4),

            // Exibe as observações, ou informa se nenhuma foi fornecida
            Text(
              medicamento.observacoes.isEmpty
                  ? 'Nenhuma observação.' // Exibe texto padrão se não houver observações
                  : medicamento.observacoes,
            ),
            const Spacer(), // Cria um espaço flexível para empurrar o botão "Voltar" para o final
            // Botão centralizado para retornar à tela anterior
            Center(
              child: ElevatedButton(
                onPressed:
                    () =>
                        Navigator.pop(context), // Retorna para a tela anterior
                child: const Text('Voltar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
