import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:todo/task_format.dart';

class TaskDatabase {
  Database? _database;
  String userid;

  TaskDatabase(this.userid);

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB(join('users', userid, 'tasks.db'));
    return _database!;
  }

  Future<Database> _initDB(String filepath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filepath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    final indexType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final statusType = 'BOOLEAN NOT NULL';
    final taskType = 'TEXT NOT NULL';

    await db.execute('''CREATE TABLE $taskTable (
        ${TaskFields.index} $indexType,
        ${TaskFields.status} $statusType,
        ${TaskFields.task} $taskType
      )
  ''');
  }

  Future<Task> create(Task task) async {
    final db = await database;
    final index = await db.insert(taskTable, task.toJson());

    return task.copy(index: index);
  }

  Future<Task> readTask(int index) async {
    final db = await database;

    final maps = await db.query(
      taskTable,
      columns: TaskFields.values,
      where: '${TaskFields.index} = ?',
      whereArgs: [index],
    );

    if (maps.isNotEmpty) {
      return Task.fromJson(maps.first);
    } else {
      throw Exception('ID $index not found');
    }
  }

  Future<List<Task>> readAllTasks() async {
    final db = await database;

    final orderBy = '${TaskFields.index} ASC';
    final result = await db.query(taskTable, orderBy: orderBy);

    return result.map((json) => Task.fromJson(json)).toList();
  }

  Future<int> update(Task task) async {
    final db = await database;

    return db.update(
      taskTable,
      task.toJson(),
      where: '${TaskFields.index} = ?',
      whereArgs: [task.index],
    );
  }

  Future<int> getRecordCount() async {
    final db = await database;
    int? count = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM $taskTable WHERE ${TaskFields.status} = 0'));

    if (count != null) {
      return count;
    } else {
      return 0;
    }
  }

  Future<void> deleteAllCompleted() async {
    final db = await database;
    db.delete(taskTable, where: '${TaskFields.status} = TRUE');
  }

  Future<void> deleteAllTasks() async {
    final db = await database;
    await databaseFactory.deleteDatabase(db.path);
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
