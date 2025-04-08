class Medicamento {
  final int? id;
  final String nome;
  final double quantidade;
  final String unidade;
  final int vezesPorDia;
  final String horarioInicial;
  final List<String> horariosGerados;
  final String observacoes;

  Medicamento({
    this.id,
    required this.nome,
    required this.quantidade,
    required this.unidade,
    required this.vezesPorDia,
    required this.horarioInicial,
    required this.horariosGerados,
    required this.observacoes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'quantidade': quantidade,
      'unidade': unidade,
      'vezesPorDia': vezesPorDia,
      'horarioInicial': horarioInicial,
      'horariosGerados': horariosGerados.join(','),  // <-- serialização
      'observacoes': observacoes,
    };
  }

  factory Medicamento.fromMap(Map<String, dynamic> map) {
    return Medicamento(
      id: map['id'],
      nome: map['nome'],
      quantidade: map['quantidade'],
      unidade: map['unidade'],
      vezesPorDia: map['vezesPorDia'],
      horarioInicial: map['horarioInicial'],
      horariosGerados: (map['horariosGerados'] as String).split(','),  // <-- desserialização
      observacoes: map['observacoes'],
    );
  }
}