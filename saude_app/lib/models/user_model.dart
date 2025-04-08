class User {
  int? id;
  String nome;
  String email;
  String senha;
  int idade;

  User({
    this.id,
    required this.nome,
    required this.email,
    required this.senha,
    required this.idade,
  });

  // Convertendo objeto para Map (para o SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'senha': senha,
      'idade': idade,
    };
  }

  // Criando objeto a partir do Map (quando lemos do banco)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      nome: map['nome'],
      email: map['email'],
      senha: map['senha'],
      idade: map['idade'],
    );
  }
}
