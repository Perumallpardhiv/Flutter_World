import 'package:sqflite/sqflite.dart';
import 'package:todo_firebase/app/model/alarm_info.dart';

final String tableAlarm = 'alarm';
final String columnId = 'id';
final String columnTitle = 'title';
final String columnBody = 'body';
final String columnDateTime = 'alarmDateTime';
final String columnPending = 'isPending';
final String columnRepeating = 'isRepeat';
final String columnSound = 'notifSound';
final String columnColorIndex = 'gradientColorIndex';

class AlarmHelper {
  static Database? _database;
  static AlarmHelper alarmHelper = AlarmHelper._init();

  AlarmHelper._init();

  AlarmHelper._createInstance();
  factory AlarmHelper() {
    if (alarmHelper == null) {
      alarmHelper = AlarmHelper._createInstance();
    }
    return alarmHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    var dir = await getDatabasesPath();
    var path = dir + "alarm.db";

    var database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          create table $tableAlarm ( 
          $columnId integer primary key autoincrement, 
          $columnTitle text not null,
          $columnBody text not null,
          $columnDateTime text not null,
          $columnPending integer,
          $columnRepeating integer,
          $columnSound text,
          $columnColorIndex integer)
        ''');
      },
    );
    return database;
  }

  Future<void> insertAlarm(AlarmInfo alarmInfo) async {
    var db = await this.database;
    var result = await db.insert(tableAlarm, alarmInfo.toMap());
    print('result : $result');
  }

  Future<int> getId() async {
    var db = await alarmHelper.database;
    var cursor = await db.query(tableAlarm);
    if (cursor.isEmpty) {
      return 0;
    }

    var result = cursor.last;
    return AlarmInfo.fromMap(result).id + 1;
  }

  Future<List<AlarmInfo>> getAlarms() async {
    List<AlarmInfo> _alarms = [];

    var db = await this.database;
    var result = await db.query(tableAlarm);
    result.forEach((element) {
      var alarmInfo = AlarmInfo.fromMap(element);
      _alarms.add(alarmInfo);
    });

    return _alarms;
  }

  Future<void> delete(int? id) async {
    var db = await this.database;
    var result =
        await db.delete(tableAlarm, where: '$columnId = ?', whereArgs: [id]);
    print("delete result : $result");
  }
}
