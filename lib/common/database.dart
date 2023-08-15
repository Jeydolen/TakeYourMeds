import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:take_your_meds/common/med_event.dart';
import 'package:take_your_meds/common/utils.dart';

class DatabaseHandler {
  static final DatabaseHandler _instance = DatabaseHandler._internal();
  static const int version = 1;
  static bool isDBAvailable = false;
  late Database _database;
  static final List<String> tables = ["meds", "events", "reminders", "moods"];

  factory DatabaseHandler() {
    return _instance;
  }

  DatabaseHandler._internal() {
    _init();
  }

  Future<void> _init() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'take_your_meds.db'),
      version: version,
      onCreate: _onCreate,
      onConfigure: (db) async {
        // await _dropAllTables(db);

        if (await needImport(db)) {
          await _onCreate(db, version);
          //await importDataFromFiles(db: db);
        }
      },
    );

    isDBAvailable = _database.isOpen;
  }

  Future<bool> needImport(Database db) async {
    List res = await db.query("sqlite_master", columns: ["name"]);

    for (String table in tables) {
      if (res.indexWhere((el) => el["name"] == table) == -1) {
        return true;
      }
    }
    return false;
  }

  Future<void> _dropAllTables(Database db) async {
    for (String table in tables) {
      await db.execute("DROP TABLE IF EXISTS $table;");
    }
  }

  Future<void> _onCreate(Database db, version) async {
    String medTableQuery = '''
        CREATE TABLE IF NOT EXISTS meds(
          id INTEGER PRIMARY KEY AUTOINCREMENT, 
          uid TEXT, 
          name TEXT, 
          dose INTEGER, 
          unit TEXT, 
          notes TEXT, 
          color INTEGER,
          favorite INTEGER DEFAULT 0 NOT NULL CHECK (favorite IN (0, 1)),
          /* When deleting med, only disable it to keep it in history */
          active INTEGER DEFAULT 1 NOT NULL CHECK (active IN (0, 1)),
          /* Order of med in med list (don't forget to insert ROWID by default) */
          order_int INTEGER NOT NULL DEFERRABLE INITIALLY DEFERRED
        );
      ''';

    String eventTableQuery = '''
        CREATE TABLE IF NOT EXISTS events(
          id INTEGER PRIMARY KEY AUTOINCREMENT, 
          date TEXT, 
          quantity INTEGER, 
          reason TEXT, 
          med_uid TEXT,
          FOREIGN KEY (med_uid) REFERENCES meds(uid)
        );
      ''';

    String moodTableQuery = '''
        CREATE TABLE IF NOT EXISTS moods(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          mood_int INTEGER,
          mood TEXT,
          date TEXT
        );
      ''';

    String reminderTable = '''
        CREATE TABLE IF NOT EXISTS reminders(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          enabled INTEGER DEFAULT 0 NOT NULL CHECK (enabled IN (0, 1)), 
          recurrent INTEGER DEFAULT 0 NOT NULL CHECK (enabled IN (0, 1)), 
          time TEXT,
          days TEXT,
          med_uid TEXT, 
          FOREIGN KEY (med_uid) REFERENCES meds(uid)
        );
      ''';

    await db.execute(medTableQuery);
    await db.execute(eventTableQuery);
    await db.execute(moodTableQuery);
    await db.execute(reminderTable);
  }

  Future<int> insert(String table, Map<String, dynamic> data) {
    return _database.insert(table, data);
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List? whereArgs,
  }) async {
    return _database.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(String table, String? where, List? whereArgs) async {
    return _database.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, Object?>>> selectAll(String table,
      {String? orderBy, String? where, List<Object?>? whereArgs}) {
    return _database.query(table,
        orderBy: orderBy, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, Object?>>> rawQuery(String sql,
      [List<Object?>? arguments]) {
    return _database.rawQuery(sql, arguments);
  }

  Batch batch() {
    return _database.batch();
  }

  void importData(List data, String table, {Database? db}) {
    db = db ?? _database;

    switch (table) {
      case "meds":
        {
          for (Map<String, dynamic> map in data) {
            if (map["dose"] is String) {
              map["dose"] = int.tryParse(map["dose"]) ?? 1;
            }

            Map<String, dynamic> filter = {
              "name": map["name"],
              "dose": map["dose"],
              "unit": map["unit"],
              "uid": map["uid"],
              "notes": map["notes"] ?? "/",
            };

            db.insert(table, filter);
          }
          break;
        }
      case "moods":
        {
          for (Map<String, dynamic> map in data) {
            Map<String, dynamic> filter = {
              "mood_integer": map["mood"],
              "time": map["iso8601_date"],
            };

            db.insert("moods", filter);
          }

          break;
        }
      case "reminders":
        {
          for (Map<String, dynamic> map in data) {
            Map<String, dynamic> filter = {
              "enabled": map["enabled"] ? 1 : 0,
              "recurrent": map["recurrent"] ? 1 : 0,
              "time": map["time"],
              "days": map["days"] == null ? null : jsonEncode(map["days"]),
              "med_uid": "med_uid",
            };

            db.insert("reminders", filter);
          }
          break;
        }
      default:
        break;
    }
  }

  void importEvents(List<dynamic> meds, {Database? db}) async {
    db = db ?? _database;

    List<MedEvent> events = Utils.createEvents(meds);

    for (MedEvent event in events) {
      Map<String, dynamic> filter = {
        "date": event.datetime.toIso8601String(),
        "quantity": event.quantity,
        "reason": event.reason,
        "med_uid": event.uid,
      };

      await db.insert("events", filter);
    }
  }

  Future<void> importDataFromFiles({Database? db}) async {
    db = db ?? _database;

    List meds = await Utils.fetchMeds();
    List moods = await Utils.fetchMoods();
    List reminders = await Utils.fetchReminders();

    importData(meds, "meds", db: db);
    importData(moods, "moods", db: db);
    importData(reminders, "reminders", db: db);

    // /*  error type 'int' is not a subtype of type 'String'
    importEvents(meds, db: db);
    // */
  }
}
