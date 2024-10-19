import 'package:local_app_database/models/task.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseServices {
  static Database? _db;
  static final DatabaseServices instance = DatabaseServices._contructor();

  final String _tasksTableName = "tasks";
  final String _tasksIdColunmName = "id";
  final String _tasksContentColunmName = "content"; // Fixed typo
  final String _tasksStatusColunmName = "status";

  DatabaseServices._contructor();

  Future<Database> get database async {
    if (_db != null) return _db!;

    // Initialize the database
    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "master_db.db");

    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
            CREATE TABLE $_tasksTableName (
            $_tasksIdColunmName INTEGER PRIMARY KEY,
            $_tasksContentColunmName TEXT NOT NULL,
            $_tasksStatusColunmName INTEGER NOT NULL)
          '''); // Fixed table creation
      },
    );
    return database;
  }

  void addTask(String content) async {
    final db = await database;
    await db.insert(
      _tasksTableName,
      {
        _tasksContentColunmName: content,
        _tasksStatusColunmName: 0,
      },
    );
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final data = await db.query(_tasksTableName);

    List<Task> tasks = data
        .map(
          (e) => Task(
            id: e['id'] as int,
            content: e['content'] as String,
            status: e['status'] as int,
          ),
        )
        .toList();

    return tasks;
  }

  void updateTaskStatus(int id, int status) async {
    final db = await database;
    await db.update(
      _tasksTableName,
      {
        _tasksStatusColunmName: status,
      },
      where: "id = ?",
      whereArgs: [
        id,
      ],
    );
  }

  void deleteTask(int id) async {
    final db = await database;
    await db.delete(
      _tasksTableName,
      where: "id = ?",
      whereArgs: [
        id,
      ],
    );
  }

  void updateTaskContent(int id, String content) async {
    final db = await database;
    await db.update(
        _tasksTableName,
        {
          _tasksContentColunmName: content,
        },
        where: "id = ?",
        whereArgs: [id]);
  }
}
