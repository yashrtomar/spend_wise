import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('spendwise.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const textNullable = 'TEXT';
    const realType = 'REAL NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE expenses (
  id $idType,
  name $textType,
  amount $realType,
  category $textType,
  note $textNullable,
  user_id $textNullable,
  created_at $textNullable,
  updated_at $textNullable,
  sync_status $integerType
)
''');

    await db.execute('''
CREATE TABLE categories (
  id $idType,
  name $textType,
  user_id $textNullable,
  created_at $textNullable,
  updated_at $textNullable,
  sync_status $integerType
)
''');

    await db.execute('''
CREATE TABLE user_profiles (
  id $idType,
  name $textType,
  monthly_budget $realType,
  preferences $textNullable,
  created_at $textNullable,
  updated_at $textNullable,
  sync_status $integerType
)
''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const textNullable = 'TEXT';
    const realType = 'REAL NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    if (oldVersion < 2) {
      await db.execute('''
CREATE TABLE user_profiles (
  id $idType,
  name $textType,
  monthly_budget $realType,
  preferences $textNullable,
  created_at $textNullable,
  updated_at $textNullable,
  sync_status $integerType
)
''');
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

// Sync Status constants
class SyncStatus {
  static const int synced = 0;
  static const int pendingInsert = 1;
  static const int pendingUpdate = 2;
  static const int pendingDelete = 3;
}
