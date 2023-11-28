import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:todo/login_format.dart';

class UserDatabase {
  static final UserDatabase instance = UserDatabase._init();

  static Database? _database;

  UserDatabase._init();

  Future<Database> get database async {
    debugPrint(await getDatabasesPath());
    if (_database != null) return _database!;

    _database = await _initDB('users.db');
    return _database!;
  }

  Future<Database> _initDB(String filepath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filepath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT NOT NULL';
    final emailType = 'TEXT UNIQUE NOT NULL';

    await db.execute('''CREATE TABLE $userTable (
        ${UserFields.id} $idType,
        ${UserFields.fname} $textType,
        ${UserFields.lname} $textType,
        ${UserFields.email} $emailType,
        ${UserFields.password} $textType
      )
  ''');
  }

  Future<(User?, bool)> create(User user) async {
    final db = await instance.database;

    bool exists = await checkUserExists(user.email);
    if (exists) {
      return (null, false);
    }
    await db.insert(userTable, user.toJson());
    user = await readUser(user.email);
    return (user, true);
  }

  Future<User> readUser(String email) async {
    final db = await instance.database;

    final maps = await db.query(
      userTable,
      columns: UserFields.values,
      where: '${UserFields.email} = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    } else {
      throw Exception('ID $email not found');
    }
  }

  Future<bool> checkUserExists(String email) async {
    final db = await instance.database;

    final maps = await db.query(userTable,
        columns: [UserFields.email],
        where: '${UserFields.email} = ?',
        whereArgs: [email]);

    if (maps.isNotEmpty) {
      return true;
    }
    return false;
  }

  Future<(User?, bool)> validateUser(String email, String password) async {
    final db = await instance.database;

    final maps = await db.rawQuery(
        'SELECT * FROM $userTable WHERE email = ? and password = ?',
        [email, password]);

    if (maps.isNotEmpty) {
      return (await readUser(email), true);
    }
    return (null, false);
  }

  Future<int> update(User user) async {
    final db = await instance.database;

    int id = await db.update(userTable, user.toJson(),
        where: '${UserFields.id} = ?', whereArgs: [user.id]);

    return id;
  }

  Future<int> conditionalUpdate(User user) async {
    //this function is used if email is changed, to check if the new email already exists
    final db = await instance.database;
    
    bool exists = await checkUserExists(user.email);
    if (exists) {
      return -1;
    }

    int id = await db.update(userTable, user.toJson(),
        where: '${UserFields.id} = ?', whereArgs: [user.id]);

    return id;
  }

  Future<void> deleteUser(int id) async {
    final db = await instance.database;
    db.delete(userTable, where: '${UserFields.id} = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
