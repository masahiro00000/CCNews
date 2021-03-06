import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:string_validator/string_validator.dart';

class DatabaseHelper {

  static final _databaseName = "CCNewsDatabase.db"; // DB名
  static final _databaseVersion = 1; // 1で固定？

  static final categorySettingTable = 'categorySetting'; // テーブル名
  static final articleHistoryTable = 'articleHistory'; // テーブル名

  static final csColumnId = '_id'; // 列1
  static final csColumnOrder = '_order'; // 列2
  static final csColumnIsVisible = 'isVisible'; // 列3

  static final ahColumnNewsId = 'newsId'; // 列1
  static final ahColumnIsRead = 'isRead'; // 列2

  // DatabaseHelperクラスをシングルトンにするためのコンストラクタ
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // DBにアクセスするためのメソッド
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    // 初の場合はDBを作成する
    _database = await _initDatabase();
    return _database;
  }

  // データベースを開く。データベースがない場合は作る関数
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory(); // アプリケーション専用のファイルを配置するディレクトリへのパスを返す
    String path = join(documentsDirectory.path, _databaseName); // joinはセパレーターでつなぐ関数
    // pathのDBを開く。なければonCreateの処理がよばれる。onCreateでは_onCreateメソッドを呼び出している
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // DBを作成するメソッド
  Future _onCreate(Database db, int version) async {
    // ダブルクォートもしくはシングルクォート3つ重ねることで改行で文字列を作成できる。$変数名は、クラス内の変数のこと（文字列の中で使える）
    await db.execute('''
          CREATE TABLE $categorySettingTable (
            $csColumnId TEXT PRIMARY KEY,
            $csColumnOrder INTEGER,
            $csColumnIsVisible TEXT NOT NULL
          )
          ''');
    await db.execute('''
          CREATE TABLE $articleHistoryTable (
            $ahColumnNewsId TEXT PRIMARY KEY,
            $ahColumnIsRead TEXT
          )
          ''');
    print('created');
  }

  // Helper methods

  // 挿入
  Future<int> insert(String table, Map<String, dynamic> row) async {
    print('insert');
    Database db = await instance.database; //DBにアクセスする
    return await db.insert(table, row); //テーブルにマップ型のものを挿入。追加時のrowIDを返り値にする
  }

  // 全件取得
  Future<List<Map<String, dynamic>>> queryAllRows(String table) async {
    print('queryAllRows');
    Database db = await instance.database; //DBにアクセスする
    return await db.query(table); //全件取得
  }

  // データ件数取得
  Future<int> queryRowCount(String table) async {
    print('queryRowsCount');
    Database db = await instance.database; //DBにアクセスする
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  // 更新
  Future<int> update(String table, String keyName, Map<String, dynamic> row) async {
    Database db = await instance.database; //DBにアクセスする
    String key = row[keyName]; //引数のマップ型のcolumnIDを取得
    print('update');
    print([key]);
    return await db.update(table, row, where: '$keyName = ?', whereArgs: [key]);
  }

  // 削除
  Future<int> delete(String table, String keyName, String key) async {
    print('delete');
    Database db = await instance.database;
    return await db.delete(table, where: '$keyName = ?', whereArgs: [key]);
  }
}