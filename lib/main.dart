import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
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
  final _favoriteBloc = FavoriteBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Youtube App'),
      ),
      body: WebView(
        initialUrl: 'https://www.youtube.com/',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // お気に入りを追加する処理
          final url = 'https://www.youtube.com/watch?v=XXXXXXXXXXX';
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

  Future<int> create(String url) async {
    final db = await dbProvider.database;
    final result = await db.insert(
      tableName,
      {
        columnUrl: url,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

/// データを保存するためのクラス
class FavoriteBloc {
  final _favoriteDao = FavoriteDao();

  Future<int> addFavorite(String url) async {
    return await _favoriteDao.create(url);
  }
}
