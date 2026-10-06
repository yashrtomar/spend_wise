import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static Future<Database>? _opening;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    try {
      _database = await (_opening ??= _initDB('spendwise.db'));
      return _database!;
    } catch (_) {
      _opening = null;
      rethrow;
    }
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
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
    await _createSyncSchema(db);
  }

  Future<void> _createSyncSchema(Database db) async {
    for (final table in ['expenses', 'categories', 'user_profiles']) {
      await db.execute(
        'ALTER TABLE $table ADD COLUMN revision INTEGER NOT NULL DEFAULT 0',
      );
    }
    await db.execute('ALTER TABLE categories ADD COLUMN delete_mode TEXT');
    await db.execute('ALTER TABLE categories ADD COLUMN replacement_id TEXT');
    await db.execute(
      'CREATE TABLE sync_metadata (user_id TEXT PRIMARY KEY, last_synced_at TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE INDEX expenses_account_status ON expenses(user_id, sync_status, created_at, id)',
    );
    await db.execute(
      'CREATE INDEX categories_account_status ON categories(user_id, sync_status)',
    );
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
    if (oldVersion < 3) await _createSyncSchema(db);
  }

  Future close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
    _opening = null;
  }
}

// Sync Status constants
class SyncStatus {
  static const int synced = 0;
  static const int pendingInsert = 1;
  static const int pendingUpdate = 2;
  static const int pendingDelete = 3;
}
