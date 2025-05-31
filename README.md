
# 📱 Documentação do Sistema - App Free

## 1. Introdução

**Nome do Aplicativo:** *App free*  
**Objetivo:** Auxiliar usuários em tarefas de bem-estar, desempenho, controle de medicamentos e motivação diária.  
**Público-alvo:** Usuários que desejam acompanhar dados de saúde e produtividade.  
**Tecnologias:** Flutter, Dart, SQLite (local), PDF, Modularização por camadas.

---

## 2. Instalação e Execução

### Pré-requisitos
- Flutter SDK instalado
- Android Studio ou VS Code com extensão Flutter
- Dispositivo emulador ou smartphone Android

### Comandos

```bash
flutter pub get
flutter run
```

> **Nota:** Certifique-se de que o dispositivo esteja conectado ou o emulador esteja aberto.

---

## 3. Estrutura do Projeto

```
lib/
├── main.dart                # Ponto de entrada
├── models/                 # Modelos de dados (exercicio, user, etc.)
├── screens/                # Telas da aplicação
├── database/               # Conexão e lógica SQLite
├── helpers/                # Utilitários (PDF, motivação, desempenho)
```

---

## 4. Funcionalidades

- ✅ Cadastro de usuário e login local
- 📈 Registro e visualização de dados de desempenho
- 🧠 Mensagens motivacionais diárias
- 💊 Controle de medicamentos e nutrição
- 📄 Geração de relatórios em PDF

---

## 5. Banco de Dados

### Utilização do SQLite
- Implementado em: `lib/database/database_helper.dart`
- Métodos: `insert`, `update`, `delete`, `getAll`

### Tabelas principais:
- `usuarios`
- `exercicios`
- `medicamentos`
- `nutricao`
- `desempenho`

---

## 6. Fluxo de Navegação

```plaintext
Splash/Login
   ↓
Dashboard
   ↓
[Telas de funcionalidades: Desempenho, Relatório, Cadastro, etc.]
```

---

## 7. Considerações Finais

- Sistema preparado para integração futura com Firebase (auth + Firestore)
- Modularização clara por tipo de funcionalidade
- Excelente base para expansão (sincronização em nuvem, notificações, etc.)

📌 **Documentações Relacionadas:**  
- [Documentação Técnica](DOCUMENTACAO_TECNICA_FLUTTER.md)

