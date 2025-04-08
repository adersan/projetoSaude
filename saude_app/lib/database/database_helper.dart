import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/medicamento_model.dart';

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
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
    );
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
        observacoes TEXT
      )
    ''');
  }

  // USUÁRIO
  Future<int> insertUser(User user) async {
    try {
      final db = await database;
      return await db.insert('usuarios', user.toMap());
    } catch (e) {
      print('Erro ao inserir usuário: \$e');
      rethrow;
    }
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

  // MEDICAMENTO
  Future<int> insertMedicamento(Medicamento medicamento) async {
    final db = await database;
    return await db.insert('medicamentos', medicamento.toMap());
  }

  Future<List<Medicamento>> getMedicamentos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('medicamentos');
    return List.generate(maps.length, (i) => Medicamento.fromMap(maps[i]));
  }

  Future<int> deleteMedicamento(int id) async {
    final db = await database;
    return await db.delete('medicamentos', where: 'id = ?', whereArgs: [id]);
  }
}