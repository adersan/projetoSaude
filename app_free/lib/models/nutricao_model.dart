
class Nutricao {
  final int? id;
  final String tipo; // ex: Almoço, Lanche
  final String descricao;
  final String horario;
  final List<String> diasSemana;
  final String observacoes;
  final int usuarioId;

  Nutricao({
    this.id,
    required this.tipo,
    required this.descricao,
    required this.horario,
    required this.diasSemana,
    required this.observacoes,
    required this.usuarioId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipo': tipo,
      'descricao': descricao,
      'horario': horario,
      'diasSemana': diasSemana.join(','),
      'observacoes': observacoes,
      'usuarioId': usuarioId,
    };
  }

  factory Nutricao.fromMap(Map<String, dynamic> map) {
    return Nutricao(
      id: map['id'],
      tipo: map['tipo'],
      descricao: map['descricao'],
      horario: map['horario'],
      diasSemana: (map['diasSemana'] as String).split(','),
      observacoes: map['observacoes'],
      usuarioId: map['usuarioId'],
    );
  }
}
