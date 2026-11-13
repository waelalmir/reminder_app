import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../data/models/task_model.dart';

class DatabaseService extends GetxService {
  late final Database _db;

  Future<DatabaseService> init() async {
    final path = join(await getDatabasesPath(), 'reminder_app.db');
    _db = await openDatabase(
      path,
      version: 2,
      onCreate: (d, v) async {
        await _createTasks(d);
        await _createSettings(d);
      },
      onUpgrade: (d, oldV, newV) async {
        if (oldV < 2) await _createSettings(d);
      },
    );
    return this;
  }

  Future<void> _createTasks(Database d) => d.execute('''
    CREATE TABLE IF NOT EXISTS tasks(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      note TEXT NOT NULL DEFAULT '',
      category INTEGER NOT NULL DEFAULT 0,
      dueAt INTEGER,
      remindBefore INTEGER NOT NULL DEFAULT 0,
      done INTEGER NOT NULL DEFAULT 0,
      createdAt INTEGER NOT NULL
    )''');

  Future<void> _createSettings(Database d) => d.execute(
      'CREATE TABLE IF NOT EXISTS settings(key TEXT PRIMARY KEY, value TEXT NOT NULL)');

  // ───── المهام ─────
  Future<List<Task>> getTasks() async {
    final rows = await _db.query('tasks',
        orderBy:
            'done ASC, CASE WHEN dueAt IS NULL THEN 1 ELSE 0 END, dueAt ASC, createdAt DESC');
    return rows.map(Task.fromMap).toList();
  }

  /// إذا كان id موجودًا (حالة التراجع عن الحذف) يُحفظ كما هو.
  Future<int> insertTask(Task t) => _db.insert('tasks', t.toMap());

  Future<void> updateTask(Task t) =>
      _db.update('tasks', t.toMap(), where: 'id = ?', whereArgs: [t.id]);

  Future<void> deleteTask(int id) =>
      _db.delete('tasks', where: 'id = ?', whereArgs: [id]);

  // ───── الإعدادات ─────
  Future<String?> getSetting(String key) async {
    final r = await _db.query('settings', where: 'key = ?', whereArgs: [key]);
    return r.isEmpty ? null : r.first['value'] as String;
  }

  Future<void> setSetting(String key, String value) => _db.insert(
      'settings', {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace);
}
