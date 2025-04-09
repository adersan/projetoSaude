
class Exercicio {
  final int? id;
  final String nome;
  final String tipo;
  final int duracao; // em minutos
  final String data;
  final String horario;
  final List<String> diasSemana;
  final String observacoes;
  final int usuarioId;

  Exercicio({
    this.id,
    required this.nome,
    required this.tipo,
    required this.duracao,
    required this.data,
    required this.horario,
    required this.diasSemana,
    required this.observacoes,
    required this.usuarioId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'tipo': tipo,
      'duracao': duracao,
      'data': data,
      'horario': horario,
      'diasSemana': diasSemana.join(','),
      'observacoes': observacoes,
      'usuarioId': usuarioId,
    };
  }

  factory Exercicio.fromMap(Map<String, dynamic> map) {
    return Exercicio(
      id: map['id'],
      nome: map['nome'],
      tipo: map['tipo'],
      duracao: map['duracao'],
      data: map['data'],
      horario: map['horario'],
      diasSemana: (map['diasSemana'] as String).split(','),
      observacoes: map['observacoes'],
      usuarioId: map['usuarioId'],
    );
  }
}
