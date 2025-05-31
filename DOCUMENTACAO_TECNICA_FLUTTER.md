
# 🛠️ Documentação Técnica - App Free

## 1. Visão Geral

Este documento fornece uma descrição técnica detalhada da arquitetura, módulos, banco de dados e integrações do sistema Flutter `App Free`. A aplicação foi construída utilizando **Flutter + Dart** com banco local **SQLite**, organizada de forma modular e escalável.

---

## 2. Arquitetura do Projeto

### Camadas da Aplicação

- **Presentation Layer (UI)**: `lib/screens/`
- **Data Layer (Modelos)**: `lib/models/`
- **Database Layer**: `lib/database/database_helper.dart`
- **Business Logic / Helpers**: `lib/helpers/`

---

## 3. Estrutura de Diretórios

```
lib/
├── main.dart                      # Ponto de entrada do app
├── database/
│   └── database_helper.dart       # Funções SQLite para CRUD
├── helpers/
│   ├── dados_desempenho_flutter.dart
│   ├── mensagem_motivacional_flutter.dart
│   └── relatorio_pdf_helper.dart
├── models/
│   ├── user_model.dart
│   ├── exercicio_model.dart
│   ├── medicamento_model.dart
│   └── nutricao_model.dart
├── screens/
│   ├── cadastro_screen.dart
│   ├── dashboard_screen.dart
│   └── desempenho_relatorio_screen.dart
```

---

## 4. Banco de Dados (SQLite)

Arquivo principal: `lib/database/database_helper.dart`

### Principais funções:
- `initDB()`: inicializa o banco
- `insert(table, data)`: insere dados
- `getAll(table)`: retorna todos os dados de uma tabela
- `update(table, data, id)`: atualiza registro
- `delete(table, id)`: remove registro por ID

### Tabelas utilizadas (exemplos):
- `usuarios (id, nome, email, senha)`
- `exercicios (id, nome, duracao, data)`
- `nutricao (id, alimento, calorias, data)`
- `medicamentos (id, nome, dosagem, horario)`

---

## 5. Models (Dart)

### Exemplo: `user_model.dart`

```dart
class User {
  int? id;
  String nome;
  String email;
  String senha;

  User({this.id, required this.nome, required this.email, required this.senha});

  Map<String, dynamic> toMap() => {
    'id': id,
    'nome': nome,
    'email': email,
    'senha': senha,
  };

  factory User.fromMap(Map<String, dynamic> map) => User(
    id: map['id'],
    nome: map['nome'],
    email: map['email'],
    senha: map['senha'],
  );
}
```

---

## 6. Geração de Relatórios

Arquivo: `relatorio_pdf_helper.dart`  
Utiliza a biblioteca `pdf` do Flutter para gerar relatórios em PDF com dados de desempenho.

---

## 7. Telas e Navegação

- `main.dart` define o `MaterialApp`
- Rotas são gerenciadas diretamente nos arquivos das telas.
- Navegação direta por `Navigator.push(...)`.

---

## 8. Possíveis Integrações Futuras

- 🔐 Firebase Authentication
- ☁️ Firestore ou Realtime Database
- 📲 Notificações Push com Firebase Messaging
- ☁️ Backup em nuvem

---

## 9. Considerações Técnicas

- Código limpo e modular
- Uso de `setState()` nas telas, com possibilidade de migração para `Provider` ou `Riverpod`
- O app está preparado para suportar integração com APIs externas

---
📌 **Documentações Relacionadas:**  
- [Documentação](readme.md)

*Última atualização técnica: 2025*
