import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Youtube App',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //DatabaseProviderクラスは、SQLiteデータベースを操作するためのクラス
  final _favoriteBloc = FavoriteBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Youtube App'),
      ),
      body: WebView(
        initialUrl: 'https://www.youtube.com/',
        javascriptMode: JavascriptMode.unrestricted,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // お気に入りを追加する処理
          final url = 'https://www.youtube.com';
          await _favoriteBloc.addFavorite(url);
        },
        child: Icon(Icons.favorite),
      ),
    );
  }
}

class FavoriteDao {
  static const tableName = 'favorites';
  static const columnId = '_id';
  static const columnUrl = 'url';

  final dbProvider = DatabaseProvider();

  Future<int?> create(String url) async {
    final db = await dbProvider.database;
    final result = await db?.insert(
      tableName,
      {
        columnUrl: url,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return result;
  }
}

/// データを保存するためのクラス
class FavoriteBloc {
  final _favoriteDao = FavoriteDao();

  Future<int?> addFavorite(String url) async {
    return await _favoriteDao.create(url);
  }
}

class DatabaseProvider {
  static final DatabaseProvider _instance = DatabaseProvider._internal();

  factory DatabaseProvider() => _instance;

  DatabaseProvider._internal();

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'favorites.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  void _onCreate(Database db, int version) async {
    await db.execute('CREATE TABLE favorites (id INTEGER PRIMARY KEY, url TEXT)');
  }
}
