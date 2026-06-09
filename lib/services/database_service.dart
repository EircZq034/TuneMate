import 'dart:convert';
import 'dart:io' show Platform;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/tuning_scheme.dart';
import '../models/string_tuning.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  DatabaseService._init();

  Database? _database;

  Database get _requireDatabase {
    assert(_database != null, 'DatabaseService.init() must be called first');
    return _database!;
  }

  Future<void> init() async {
    if (_database != null) return;

    String dbPath;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      final appDir = await getApplicationDocumentsDirectory();
      dbPath = p.join(appDir.path, 'tunemate.db');
    } else {
      dbPath = p.join(await getDatabasesPath(), 'tunemate.db');
    }

    _database = await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _createDB,
      ),
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE custom_tunings (
        id TEXT PRIMARY KEY,
        nameZh TEXT NOT NULL,
        nameEn TEXT NOT NULL,
        descriptionZh TEXT DEFAULT '',
        descriptionEn TEXT DEFAULT '',
        stringsJson TEXT NOT NULL
      )
    ''');
  }

  // 保存自定义特调
  Future<void> saveCustomTuning(TuningScheme tuning) async {
    await _requireDatabase.insert(
      'custom_tunings',
      {
        'id': tuning.id,
        'nameZh': tuning.nameZh,
        'nameEn': tuning.nameEn,
        'descriptionZh': tuning.descriptionZh,
        'descriptionEn': tuning.descriptionEn,
        'stringsJson': jsonEncode(tuning.strings.map((s) => s.toMap()).toList()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 获取所有自定义特调
  Future<List<TuningScheme>> getCustomTunings() async {
    final rows = await _requireDatabase.query('custom_tunings');
    final List<TuningScheme> result = [];
    for (final row in rows) {
      try {
        final stringsList = jsonDecode(row['stringsJson'] as String) as List;
        result.add(TuningScheme(
          id: row['id'] as String,
          nameZh: row['nameZh'] as String,
          nameEn: row['nameEn'] as String,
          descriptionZh: (row['descriptionZh'] as String?) ?? '',
          descriptionEn: (row['descriptionEn'] as String?) ?? '',
          isBuiltIn: false,
          isFavorite: false,
          strings: stringsList
              .map((s) => StringTuning.fromMap(s as Map<String, dynamic>))
              .toList(),
        ));
      } catch (e) {
        // 跳过损坏记录
        continue;
      }
    }
    return result;
  }

  // 删除自定义特调
  Future<void> deleteCustomTuning(String id) async {
    await _requireDatabase.delete('custom_tunings', where: 'id = ?', whereArgs: [id]);
  }
}
