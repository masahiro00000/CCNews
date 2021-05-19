// import 'package:flutter/material.dart';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';
// import 'dart:async';
//
// class CategorySetting {
//   final String id;
//   final int order;
//   final bool isVisible;
//
//   CategorySetting({this.id, this.order, this.isVisible});
//
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'order': order,
//       'isVisble': isVisible.toString(),
//     };
//   }
// }
//
// class ArticleData {
//   final String newsId;
//   final bool isRead;
//
//   ArticleData({this.newsId, this.isRead});
//
//   Map<String, dynamic> toMap() {
//     return {
//       'newsId': newsId,
//       'isRead': isRead.toString(),
//     };
//   }
// }
//
// class DBManager {
//   final Future<Database> database = getDatabasesPath().then((String path) {
//     return openDatabase(
//       join(path, 'ccnews_database.db'),
//       onCreate: (db, version) {
//         return db.execute(
//           "CREATE TABLE categorySetting(id TEXT PRIMARY KEY, order INTEGER, isVisible TEXT)",
//           "CREATE TABLE articleData(newsId TEXT PRIMARY KEY, isRead TEXT)",
//         );
//       },
//       version: 1,
//     );
//   });
//
//   Future<void> insertCategorySetting(CategorySetting categorySetting) async {
//     final Database db = await database;
//     await db.insert(
//       'categorySetting',
//       categorySetting.toMap(),
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }
// }