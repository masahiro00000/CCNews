import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/database_helper.dart';
import 'package:string_validator/string_validator.dart';

// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter ReorderableListView',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: CategorySettingPage(title: 'ReorderableListView Sample'),
//     );
//   }
// }

class CategorySettingPage extends StatefulWidget {
  CategorySettingPage({Key key}) : super(key: key);

  final String title = 'カテゴリの設定';

  @override
  _CategorySettingState createState() => _CategorySettingState();
}

class _CategorySettingState extends State<CategorySettingPage> {
  List<Model> modelList;
  final dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    modelList = [];
    var _tabs = ["BTC", "ETH", "BNB","XRP","USDT"];
    // List<String> titleList = ["Title A", "Title B", "Title C"];
    // List<String> subTitleList = ["SubTitle A", "SubTitle B", "SubTitle C"];
    // for (int i = 0; i < 3; i++) {
    //   Model model = Model(
    //     id: titleList[i],
    //     subTitle: subTitleList[i],
    //     key: i.toString(),
    //   );
    //   modelList.add(model);
    // }

    // _tabs.asMap().forEach((int i, String element) {
    //   modelList.add(Model(key: i.toString(), id: element, order: i, isVisible: true));
    // });


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: FutureBuilder(
          future: _getCategories(),
          builder: (BuildContext context, AsyncSnapshot<List<Model>> snapshot) {
            // 通信中はスピナーを表示
            if (snapshot.connectionState != ConnectionState.done) {
              return  Center(
                child: CircularProgressIndicator(),
              );
            }

            // エラー発生時はエラーメッセージを表示
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }

            modelList = snapshot.data;
            return ReorderableListView(
              padding: EdgeInsets.all(10.0),
              header: Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.grey,
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    "ドラッグ&ドロップで順序を設定",
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              ),
              onReorder: (oldIndex, newIndex) {
                if (oldIndex < newIndex) {
                  // removing the item at oldIndex will shorten the list by 1.
                  newIndex -= 1;
                }
                final Model model = modelList.removeAt(oldIndex);

                setState(() {
                  modelList.insert(newIndex, model);
                  for (int i = 0; i < modelList.length; i++) {
                    modelList[i].order = i;
                  }
                });
                modelList.forEach((element) {
                  _update(element);
                });
              },
              children: modelList.map(
                (Model model) {
                  debugPrint('model.id: ${model.id}');
                  return Card(
                    elevation: 2.0,
                    key: Key(model.key),
                    child: ListTile(
                      // leading: const Icon(Icons.),
                      title: Text(model.id),
                      subtitle: Text(model.order.toString()/*+', '+model.isVisible.toString()*/),
                      trailing: const Icon(Icons.reorder),
                    ),
                  );
                },
              ).toList(),
            );
          }
        )
      )
    );
  }

  Future<List<Model>> _getCategories() async {
    List<Model> result = [];
    var rows = await _query();
    print('runtimeType: ' + rows.runtimeType.toString());

    result = []..length = rows.length;
    rows.asMap().forEach((int i, element) {
      debugPrint('columnId: ' + element[DatabaseHelper.csColumnId]);
      debugPrint('columnOrder: ' + element[DatabaseHelper.csColumnOrder].toString());
      result[element[DatabaseHelper.csColumnOrder]] = Model(
          key: i.toString(),
          id: element[DatabaseHelper.csColumnId],
          order: element[DatabaseHelper.csColumnOrder],
          isVisible: toBoolean(element[DatabaseHelper.csColumnIsVisible].toLowerCase())
      );
    });
    print('modelList length ' + result.length.toString());
    debugPrint('end of _getCategories');

    return result;
  }


  // ボタンが押されたときのメソッド類

  // insertが押されたときのメソッド
  void _insert(Model model) async {
    // TODO:idがかぶっていないことのチェック
    // TODO:orderにかぶりがなく、連番になっていること、連番の最後の番号が降られることのチェック
    final allRows = await dbHelper.queryAllRows(DatabaseHelper.categorySettingTable);

    Map<String, dynamic> row = {
      DatabaseHelper.csColumnId : model.id,
      DatabaseHelper.csColumnOrder  : model.order,
      DatabaseHelper.csColumnIsVisible : 'true'
    };
    final id = await dbHelper.insert(DatabaseHelper.categorySettingTable ,row);
    print('inserted row id: $id');
  }

  // queryが押されたときのメソッド
  Future<List<Map<String, dynamic>>> _query() async {
    final allRows = await dbHelper.queryAllRows(DatabaseHelper.categorySettingTable);
    print('query all rows:');
    allRows.forEach((row) => print(row));
    return allRows;
  }

  // updateが押された時のメソッド
  void _update(Model model) async {
    Map<String, dynamic> row = {
      DatabaseHelper.csColumnId : model.id,
      DatabaseHelper.csColumnOrder  : model.order,
      DatabaseHelper.csColumnIsVisible : model.isVisible.toString()
    };
    final rowsAffected = await dbHelper.update(DatabaseHelper.categorySettingTable, DatabaseHelper.csColumnId, row);
    print('updated $rowsAffected row(s)');
  }
  //
  // // deleteが押された時のメソッド
  // void _delete() async {
  //   final id = await dbHelper.queryRowCount();
  //   final rowsDeleted = await dbHelper.delete(id);
  //   print('deleted $rowsDeleted row(s): row $id');
  // }


}

class Model {
  final String key;
  final String id;
  int order;
  bool isVisible;

  Model({
    @required this.key,
    @required this.id,
    @required this.order,
    @required this.isVisible,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order': order,
      'isVisble': isVisible.toString(),
    };
  }
}