
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/medicamento_model.dart';
import '../models/exercicio_model.dart';
import '../models/nutricao_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('saude_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final path = join(await getDatabasesPath(), filePath);
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT,
        email TEXT UNIQUE,
        senha TEXT,
        idade INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE medicamentos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT,
        quantidade REAL,
        unidade TEXT,
        vezesPorDia INTEGER,
        horarioInicial TEXT,
        horariosGerados TEXT,
        observacoes TEXT,
        usuarioId INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE exercicios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT,
        tipo TEXT,
        duracao INTEGER,
        data TEXT,
        horario TEXT,
        diasSemana TEXT,
        observacoes TEXT,
        usuarioId INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE nutricao (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipo TEXT,
        descricao TEXT,
        horario TEXT,
        diasSemana TEXT,
        observacoes TEXT,
        usuarioId INTEGER
      )
    ''');
  }

  // ========== USUÁRIOS ==========
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('usuarios', user.toMap());
  }

  Future<User?> getUser(String email, String senha) async {
    final db = await database;
    final result = await db.query(
      'usuarios',
      where: 'email = ? AND senha = ?',
      whereArgs: [email, senha],
    );
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  // ========== MEDICAMENTOS ==========
  Future<int> insertMedicamento(Medicamento medicamento) async {
    final db = await database;
    return await db.insert('medicamentos', medicamento.toMap());
  }

  Future<List<Medicamento>> getMedicamentos(int usuarioId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'medicamentos',
      where: 'usuarioId = ?',
      whereArgs: [usuarioId],
    );
    return List.generate(maps.length, (i) => Medicamento.fromMap(maps[i]));
  }

  Future<int> updateMedicamento(Medicamento medicamento) async {
    final db = await database;
    return await db.update(
      'medicamentos',
      medicamento.toMap(),
      where: 'id = ?',
      whereArgs: [medicamento.id],
    );
  }

  Future<int> deleteMedicamento(int id) async {
    final db = await database;
    return await db.delete('medicamentos', where: 'id = ?', whereArgs: [id]);
  }

  // ========== EXERCÍCIOS ==========
  Future<int> insertExercicio(Exercicio exercicio) async {
    final db = await database;
    return await db.insert('exercicios', exercicio.toMap());
  }

  Future<List<Exercicio>> getExercicios(int usuarioId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'exercicios',
      where: 'usuarioId = ?',
      whereArgs: [usuarioId],
    );
    return List.generate(maps.length, (i) => Exercicio.fromMap(maps[i]));
  }

  Future<int> updateExercicio(Exercicio exercicio) async {
    final db = await database;
    return await db.update(
      'exercicios',
      exercicio.toMap(),
      where: 'id = ?',
      whereArgs: [exercicio.id],
    );
  }

  Future<int> deleteExercicio(int id) async {
    final db = await database;
    return await db.delete(
      'exercicios',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== NUTRIÇÃO ==========
  Future<int> insertNutricao(Nutricao nutricao) async {
    final db = await database;
    return await db.insert('nutricao', nutricao.toMap());
  }

  Future<List<Nutricao>> getNutricao(int usuarioId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'nutricao',
      where: 'usuarioId = ?',
      whereArgs: [usuarioId],
    );
    return List.generate(maps.length, (i) => Nutricao.fromMap(maps[i]));
  }

  Future<int> updateNutricao(Nutricao nutricao) async {
    final db = await database;
    return await db.update(
      'nutricao',
      nutricao.toMap(),
      where: 'id = ?',
      whereArgs: [nutricao.id],
    );
  }

  Future<int> deleteNutricao(int id) async {
    final db = await database;
    return await db.delete(
      'nutricao',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
