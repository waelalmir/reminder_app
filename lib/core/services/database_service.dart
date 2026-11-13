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
      version: 3,
      onCreate: (d, _) async {
        await _createTasks(d);
        await _createSettings(d);
      },
      onUpgrade: (d, oldV, newV) async {
        if (oldV < 2) {
          await _createSettings(d);
        }
        if (oldV < 3) {
          await _migrateTasksToV3(d);
        }
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
      createdAt INTEGER NOT NULL,
      priority INTEGER NOT NULL DEFAULT 1,
      repeatType INTEGER NOT NULL DEFAULT 0,
      isPinned INTEGER NOT NULL DEFAULT 0,
      subtasks TEXT NOT NULL DEFAULT '[]'
    )
  ''');

  Future<void> _migrateTasksToV3(Database d) async {
    final cols = await d.rawQuery('PRAGMA table_info(tasks)');
    final names = cols.map((c) => c['name'] as String).toSet();

    if (!names.contains('priority')) {
      await d.execute(
          'ALTER TABLE tasks ADD COLUMN priority INTEGER NOT NULL DEFAULT 1');
    }
    if (!names.contains('repeatType')) {
      await d.execute(
          'ALTER TABLE tasks ADD COLUMN repeatType INTEGER NOT NULL DEFAULT 0');
    }
    if (!names.contains('isPinned')) {
      await d.execute(
          'ALTER TABLE tasks ADD COLUMN isPinned INTEGER NOT NULL DEFAULT 0');
    }
    if (!names.contains('subtasks')) {
      await d.execute(
          "ALTER TABLE tasks ADD COLUMN subtasks TEXT NOT NULL DEFAULT '[]'");
    }
  }

  Future<void> _createSettings(Database d) => d.execute('''
    CREATE TABLE IF NOT EXISTS settings(
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL
    )
  ''');

  Future<List<Task>> getTasks() async {
    final rows = await _db.query(
      'tasks',
      orderBy: '''
        done ASC,
        isPinned DESC,
        CASE WHEN dueAt IS NULL THEN 1 ELSE 0 END,
        dueAt ASC,
        priority DESC,
        createdAt DESC
      ''',
    );
    return rows.map(Task.fromMap).toList();
  }

  Future<Task?> getTaskById(int id) async {
    final rows = await _db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Task.fromMap(rows.first);
  }

  Future<int> insertTask(Task t) => _db.insert('tasks', t.toMap());

  Future<int> updateTask(Task t) =>
      _db.update('tasks', t.toMap(), where: 'id = ?', whereArgs: [t.id]);

  Future<int> deleteTask(int id) =>
      _db.delete('tasks', where: 'id = ?', whereArgs: [id]);

  Future<int> deleteCompletedTasks() =>
      _db.delete('tasks', where: 'done = 1');

  Future<String?> getSetting(String key) async {
    final rows =
        await _db.query('settings', where: 'key = ?', whereArgs: [key]);
    return rows.isEmpty ? null : rows.first['value'] as String;
  }

  Future<void> setSetting(String key, String value) => _db.insert(
        'settings',
        {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
}
