import 'package:sqflite/sqflite.dart';
import 'package:todo_firebase/app/model/task.dart';

class DBHelper {
  static Database? _db;
  static final int _version = 1;
  static final String _tableName = "tasks";

  static Future<void> initDb() async {
    if (_db != null) {
      print('Already created!');
      return;
    }
    try {
      String _path = await getDatabasesPath() + 'tasks.db';
      _db = await openDatabase(
        _path,
        version: _version,
        onCreate: (db, ver) {
          print('Creating a new one');
          return db.execute(
            "CREATE TABLE $_tableName("
            "id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "title STRING,note TEXT, date STRING, "
            "startTime STRING, endTime STRING, "
            "remiind INTEGER,repeat STRING, color INREGER,"
            "isCompleted INTEGER)",
          );
        },
      );
    } catch (e) {
      print(e);
    }
  }

  static Future<int> insert(Task? task) async {
    print('insert function called');
    return await _db!.insert(_tableName, task!.toJson());
  }

  static Future<List<Map<String, dynamic>>> query() async {
    print('query fun called');
    return await _db!.query(_tableName);
  }

  static delete(Task _) async {
    return await _db?.delete(_tableName, where: 'id=?', whereArgs: [_.id]);
  }

  static update(int id) async {
    return await _db!.rawUpdate('''
        UPDATE  $_tableName SET isCompleted = ?
        WHERE id = ?
        ''', [1, id]);
  }

  static notUpdate(int id) async {
    return await _db!.rawUpdate('''
        UPDATE  $_tableName SET isCompleted = ?
        WHERE id = ?
        ''', [0, id]);
  }
}
