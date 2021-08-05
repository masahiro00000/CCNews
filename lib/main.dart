import 'package:flutter/material.dart';
import 'package:flutter_app/articleData.dart';
import 'package:flutter_app/web_view_screen.dart';
import 'package:flutter_app/category_settings.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_app/database_helper.dart';
import 'package:string_validator/string_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


final RouteObserver<PageRoute> _routeObserver = RouteObserver<PageRoute>(); // <= ここ！


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const locale = Locale("ja", "JP");
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.light(), // ライト用テーマ
      darkTheme: ThemeData.dark(), // ダーク用テーマ
      themeMode: ThemeMode.system, // モードをシステム設定にする
      locale: locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        locale,
      ],
      // theme: ThemeData(
      //   // This is the theme of your application.
      //   //
      //   // Try running your application with "flutter run". You'll see the
      //   // application has a blue toolbar. Then, without quitting the app, try
      //   // changing the primarySwatch below to Colors.green and then invoke
      //   // "hot reload" (press "r" in the console where you ran "flutter run",
      //   // or simply save your changes to "hot reload" in a Flutter IDE).
      //   // Notice that the counter didn't reset back to zero; the application
      //   // is not restarted.
      //   primarySwatch: Colors.blue,
      // ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
      navigatorObservers: <NavigatorObserver>[_routeObserver],
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with RouteAware {
  var _tabs = ["Latest"];
  final dbHelper = DatabaseHelper.instance;

  // var articles = <ArticleData>[];
  Map<String, List<ArticleData>> articles = new Map();

  @override
  void initState()  {
    super.initState();
    // _initTabs();

    // var models = _query();
    // models.then((value) {
    //   _tabs = []..length = value.length;
    //   value.forEach((element) {
    //     setState(() {
    //       _tabs[element[DatabaseHelper.csColumnOrder]] = element[DatabaseHelper.csColumnId];
    //     });
    //   });
    //   debugPrint('_tabs is filled');
    // });

    // debugPrint('_tabs length: ' + _tabs.length.toString());
    //
    // _tabs.forEach((element) {
    //   articles[element] = [];
    // });
    // this._fetchNewsData();
    // debugPrint('_tabs length in initState: ' + _tabs.length.toString());
    // debugPrint('initState done');
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    _routeObserver.unsubscribe(this);
    super.dispose();
  }

  // 上の画面がpopされて、この画面に戻ったときに呼ばれます
  void didPopNext() {
    debugPrint("didPopNext ${runtimeType}");
    var models = _query();
    models.then((value) {
      var currentTabs = []..length = value.length;
      value.forEach((element) {
        currentTabs[element[DatabaseHelper.csColumnOrder]] = element[DatabaseHelper.csColumnId];
      });
      if (!listEquals(currentTabs, _tabs)) {
        setState(() {
          _tabs = [...currentTabs];
          debugPrint('_tabs updated');
        });
      }
    });
  }

  // この画面がpushされたときに呼ばれます
  void didPush() {
    debugPrint("didPush ${runtimeType}");
  }

  // この画面がpopされたときに呼ばれます
  void didPop() {
    debugPrint("didPop ${runtimeType}");
  }

  // この画面から新しい画面をpushしたときに呼ばれます
  void didPushNext() {
    debugPrint("didPushNext ${runtimeType}");
  }


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    debugPrint('build is started');
    debugPrint('_tabs length in build: ' + _tabs.length.toString());

    return Material(
      child: Scaffold(
        body: FutureBuilder(
          future: _getTabs(),
          builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
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

            _tabs = snapshot.data;
            return DefaultTabController(
              length: _tabs.length, // This is the number of tabs.
              child: NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  // These are the slivers that show up in the "outer" scroll view.
                  return <Widget>[
                    SliverOverlapAbsorber(
                      // This widget takes the overlapping behavior of the SliverAppBar,
                      // and redirects it to the SliverOverlapInjector below. If it is
                      // missing, then it is possible for the nested "inner" scroll view
                      // below to end up under the SliverAppBar even when the inner
                      // scroll view thinks it has not been scrolled.
                      // This is not necessary if the "headerSliverBuilder" only builds
                      // widgets that do not overlap the next sliver.
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                          context),
                      sliver: SliverSafeArea(
                        top: false,
                        sliver: SliverAppBar(
                          title: const Text('CC News'),
                          actions: <Widget>[
                            PopupMenuButton<Choice>(
                              onSelected: (Choice choice) {
                                // Selected Action
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<WebViewScreen>(
                                    builder: (BuildContext _context) =>
                                        CategorySettingPage(),
                                  ),
                                );
                              },
                              itemBuilder: (BuildContext context) {
                                return choices.map((Choice choice) {
                                  return PopupMenuItem<Choice>(
                                    value: choice,
                                    child: Row(
                                      children: <Widget>[
                                        Icon(choice.icon),
                                        Text(choice.title),
                                      ],
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                            // IconButton(
                            //   icon: Icon(Icons.settings, color: Colors.white,),
                            // ),
                          ],
                          floating: true,
                          pinned: true,
                          snap: false,
                          primary: true,
                          forceElevated: innerBoxIsScrolled,
                          bottom: TabBar(
                            // タブのオプション
                            isScrollable: true,
                            // unselectedLabelColor: Colors.white.withOpacity(0.3),
                            // unselectedLabelStyle: TextStyle(fontSize: 12.0),
                            // labelColor: Colors.yellowAccent,
                            // labelStyle: TextStyle(fontSize: 16.0),
                            // indicatorColor: Colors.white,
                            // indicatorWeight: 2.0,
                            // These are the widgets to put in each tab in the tab bar.
                            tabs: _tabs.map((String name) {
                              return Container(
                                width: 60.0,
                                alignment: Alignment.center,
                                child: Tab(text: name),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ];
                },
                body: FutureBuilder (
                  future: _fetchNewsData(),
                  builder: (BuildContext context, AsyncSnapshot<Map<String, List<ArticleData>>> snapshot) {
                    // 通信中はスピナーを表示
                    if (snapshot.connectionState != ConnectionState.done) {
                      return  TabBarView(
                        // These are the contents of the tab views, below the tabs.
                        // TODO:
                        children: _tabs.map((String name) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }).toList(),
                      );
                    }

                    // エラー発生時はエラーメッセージを表示
                    if (snapshot.hasError) {
                      return  TabBarView(
                        // These are the contents of the tab views, below the tabs.
                        // TODO:
                        children: _tabs.map((String name) {
                          return Center(
                            child: Text(snapshot.error.toString()),
                          );
                        }).toList(),
                      );
                      // return Text(snapshot.error.toString());
                    }

                    return TabBarView(
                      // These are the contents of the tab views, below the tabs.
                      // TODO:
                      children: _tabs.map((String name) {
                        articles = snapshot.data;
                        return _getCardChild(name);
                      }).toList(),
                    );
                  }
                ),
              ),
            );
          }
        ),
      ),
    );
  }


  Future<List<String>> _getTabs() async {
    List<String> result = [];
    //DBからカテゴリー一覧を取得
    debugPrint('quety start');
    var allRows =  await _query();

    debugPrint('fetchCategory start');
    List<String> remoteCategories = await _fetchCategories();
    debugPrint('remoteCategories: ${remoteCategories.toString()}');
    if(remoteCategories.length > 0) {
      debugPrint('remoteCategories set to _tab');
      result = remoteCategories;
    } else {
      result = ["Latest"];
    }
    var DBCatecorys = [];
    var notDBContains = [];
    var notTabsContains = [];

    allRows.forEach((element) {
      DBCatecorys.add(element[DatabaseHelper.csColumnId]);
    });

    // DBに含まれないカテゴリを抽出
    result.forEach((element) {
      if(!DBCatecorys.contains(element)) {
        notDBContains.add(element);
      }
    });
    // タブに含まれないカテゴリを抽出
    DBCatecorys.forEach((element) {
      if(!result.contains(element)){
        notTabsContains.add(element);
      }
    });

    debugPrint('allRows length: ${allRows.length}');
    debugPrint('notTabsContains length: ${notTabsContains.length}');
    debugPrint('notDBCotains length: ${notDBContains.length}');

    //カテゴリがDBに登録されていないとき
    if(allRows.length == 0){
      for (String category in result) {
        try {
          debugPrint(category);
          await _insert(catecoryId: category, isVisible: true);
        } catch (e) {
          // 型指定していないので総ての例外を扱う
          print('Something really unknown: $e');
        }
      }
    } else { //DBにカテゴリが登録されているとき
      if(notTabsContains.length == 0 && notDBContains.length == 0) {
        //  タブとDBの内容が一致するとき

      } else { // タブとDBの内容が一致しないとき
        if (notDBContains.length > 0) { //タブに含まれ、DBに含まれないカテゴリがあるとき
          debugPrint('notDBContains.length > 0');
          for (String category in notDBContains) {
            try {
              debugPrint('insert');
              await _insert(catecoryId: category, isVisible: true);
            } catch (e) {
              // 型指定していないので総ての例外を扱う
              print('Something really unknown: $e');
            }
          }
        }
        if (notTabsContains.length > 0 && remoteCategories.length > 0) { //リモートからタブ情報が得られた場合に、DBに含まれ、タブに含まれないカテゴリがあるとき
          // DBから該当のカテゴリを削除する
          for (String category in notTabsContains) {
            debugPrint('Delete!');
            await _delete(category);
          }
        }
      }
    }
    //DBからカテゴリー一覧を再取得
    allRows =  await _query();
    // TODO: allRowsのorderについて整合性をチェックする。

    List<Map<String, dynamic>> validatedRows = await _validateOrder(allRows);

    // タブの初期化
    result = []..length = validatedRows.length;
    validatedRows.forEach((element) {
      // 読み込んだDBのカテゴリをタブに反映する
      result[element[DatabaseHelper.csColumnOrder]] = element[DatabaseHelper.csColumnId];
    });

    debugPrint('_tabs is filled. _tabs length: ' + result.length.toString());

    debugPrint('_tabs length: ' + result.length.toString());

    result.forEach((element) {
      articles[element] = [];
    });

    debugPrint('_tabs length in initState: ' + result.length.toString());
    debugPrint('initState done');

    debugPrint('following is result');
    for (String category in result) {
      debugPrint(category);
    }
    return result;
  }

  Future<List<Map<String, dynamic>>> _validateOrder(dynamic allRows) async {
    debugPrint('_validateOrder');
    List<Map<String, dynamic>> result = [];
    List<int> orderList = [];
    allRows.asMap().forEach((int key, row) {
      if (row[DatabaseHelper.csColumnOrder] != null) {
        // orderに数字が入っているものの収集
        orderList.add(row[DatabaseHelper.csColumnOrder]);
        debugPrint('orderList.length: ' + orderList.length.toString());
      }
    });
    orderList.sort();
    bool isValidSort = true;
    // orderの重複がないかチェック、連番になっているかチェック
    for (int key in orderList.asMap().keys) {
      debugPrint('${key.toString()}, ${orderList[key].toString()}');
      if(key != orderList[key]) {
        isValidSort = false;
        break;
      }
    }
    if(!isValidSort) {
      int counter = 0;
      // リスト順にorderを再設定
      debugPrint(allRows.length.toString());
      for(int i = 0 ; i < allRows.length; i++) {
        debugPrint('for');
        if (allRows[i][DatabaseHelper.csColumnOrder] != null) {
          debugPrint('in if');
          debugPrint(allRows[i][DatabaseHelper.csColumnOrder].toString());
          Map<String, dynamic> tmpMap = {
            DatabaseHelper.csColumnId: allRows[i][DatabaseHelper.csColumnId],
            DatabaseHelper.csColumnOrder: counter,
            DatabaseHelper.csColumnIsVisible: allRows[i][DatabaseHelper.csColumnIsVisible],
          };
          result.add(tmpMap);
          counter += 1;
          debugPrint(counter.toString());
        } else {
          Map<String, dynamic> tmpMap = {
            DatabaseHelper.csColumnId: allRows[i][DatabaseHelper.csColumnId],
            DatabaseHelper.csColumnOrder: allRows[i][DatabaseHelper.csColumnOrder],
            DatabaseHelper.csColumnIsVisible: allRows[i][DatabaseHelper.csColumnIsVisible],
          };
          result.add(tmpMap);
        }
        debugPrint(allRows[i][DatabaseHelper.csColumnOrder].toString());
      }
      debugPrint('invalid order');
      // TODO:update
      for (dynamic row in result) {
        await _update(row);
      }
    } else {
      for(int i = 0 ; i < allRows.length; i++) {
        Map<String, dynamic> tmpMap = {
          DatabaseHelper.csColumnId: allRows[i][DatabaseHelper.csColumnId],
          DatabaseHelper.csColumnOrder: allRows[i][DatabaseHelper.csColumnOrder],
          DatabaseHelper.csColumnIsVisible: allRows[i][DatabaseHelper.csColumnIsVisible],
        };
        result.add(tmpMap);
      }
    }

    for (dynamic row in result) {
      debugPrint(row[DatabaseHelper.csColumnOrder].toString());
    }

    return result;
  }

  Future<void> _refresh() async {
    await Future.sync(() {
      _fetchNewsData().then((value) {
        setState(() {
          articles = value;
        });
      });
    });
  }

  Future<Map<String, List<ArticleData>>> _fetchNewsData() async {
    var url = Uri.parse(
        'https://n29rztuk36.execute-api.ap-northeast-1.amazonaws.com/prod/fetchnews2');
    Map<String, String> headers = {'content-type': 'application/json'};
    String body = json.encode({'name': 'moke'});
    Map<String, List<ArticleData>> result = {};

    var response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.

      _tabs.forEach((element) {
        result[element] = [];
      });
      if (jsonDecode(response.body)['data'] != null) {
        // articles = [];
        _tabs.forEach((element) {
          if (jsonDecode(response.body)['data'][element] != null) {
            jsonDecode(response.body)['data'][element].forEach((item) {
              var pubDate = null;
              try {
                pubDate = (item['pubDate'] == null)
                    ? ''
                    : DateTime.parse(item['pubDate'].substring(0, 22) + item['pubDate'].substring(23));
              } catch(e) {
                // 日時の最後に+09:00がない場合の処理
                pubDate = (item['pubDate'] == null)
                    ? ''
                    : DateTime.parse(item['pubDate'].substring(0, 19));
              }
              result[element].add( new ArticleData(
                title: (item['title'] == null) ? '' : item['title'],
                description: (item['description'] == null)
                    ? ''
                    : item['description'],
                url: item['url'],
                imgUrl: item['imgUrl'],
                mediaName: (item['siteName'] == null)
                    ? ''
                    : item['siteName'],
                pubDate: pubDate,
                )
              );
            });
          }
        });
      }
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load news');
    }

    print(result);
    debugPrint('_fetchNewsData done');
    return result;
  }

  Future<List<String>> _fetchCategories() async {
    Map<String, String> categories = {};
    var url = Uri.parse(
        'https://n29rztuk36.execute-api.ap-northeast-1.amazonaws.com/prod/fetchcategory');

    var response = await http.get(url);
    var body = jsonDecode(response.body) as Map<String, dynamic>;
     try {
       categories = body['categories'].cast<String, String>();//.cast<Map<String, String>>();
     } catch (e) {
       debugPrint('exception: ${e.toString()}');
       categories = {};
     }
     debugPrint('fetchCategories: ' + categories.toString());
     return categories.keys.toList();
  }

  Widget _getCardChild(String name) {
    if(articles == null || articles.length == 0) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return SafeArea(
        top: false,
        bottom: false,

        child: RefreshIndicator(
          onRefresh: _refresh,
          child: Builder(
            // This Builder is needed to provide a BuildContext that is "inside"
            // the NestedScrollView, so that sliverOverlapAbsorberHandleFor() can
            // find the NestedScrollView.
            builder: (BuildContext context) {
              return CustomScrollView(
                // The "controller" and "primary" members should be left
                // unset, so that the NestedScrollView can control this
                // inner scroll view.
                // If the "controller" property is set, then this scroll
                // view will not be associated with the NestedScrollView.
                // The PageStorageKey should be unique to this ScrollView;
                // it allows the list to remember its scroll position when
                // the tab view is not on the screen.
                key: PageStorageKey<String>(name),
                slivers: <Widget>[
                  SliverOverlapInjector(
                    // This is the flip side of the SliverOverlapAbsorber above.
                    handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(8.0),
                    // In this example, the inner scroll view has
                    // fixed-height list items, hence the use of
                    // SliverFixedExtentList. However, one could use any
                    // sliver widget here, e.g. SliverList or SliverGrid.
                    // sliver: SliverFixedExtentList(
                    sliver: SliverList(
                      // The items in this example are fixed to 48 pixels
                      // high. This matches the Material Design spec for
                      // ListTile widgets.
                      // itemExtent: 60.0,
                      delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                          // This builder is called for each child.
                          // In this example, we just number each list item.
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<WebViewScreen>(
                                  builder: (BuildContext _context) => WebViewScreen(articles[name][index].url),
                                ),
                              );
                            },
                            child: Card(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  ListTile(
                                    trailing: Image.network(articles[name][index].imgUrl),
                                    // trailing: Image(
                                    //   image: AssetImage('images/sample.png'),
                                    // ),
                                    // leading: Icon(Icons.album),
                                    title: Text(articles[name][index].title),
                                    // subtitle: Text(articles[name][index].description),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10.0, right: 10.0),
                                    child: Row(
                                      // mainAxisAlignment: MainAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween, // これで両端に寄せる
                                      children: <Widget>[
                                        Text(
                                          articles[name][index].mediaName,
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        Text(
                                          DateFormat('yyyy/MM/dd').format(articles[name][index].pubDate),
                                          style: TextStyle(fontSize: 12),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                        // The childCount of the SliverChildBuilderDelegate
                        // specifies how many children this inner list
                        // has. In this example, each tab has a list of
                        // exactly 30 items, but this is arbitrary.
                        childCount: articles[name].length,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    }
  }

  // queryが押されたときのメソッド
  Future<List<Map<String, dynamic>>> _query() async {
    final allRows = await dbHelper.queryAllRows(DatabaseHelper.categorySettingTable);
    print('query all rows:');
    allRows.forEach((row) => print(row));
    return allRows;
  }

  Future<void> _update(dynamic row) async {
    var res = await dbHelper.update(DatabaseHelper.categorySettingTable, DatabaseHelper.csColumnId, row);
  }

  // insertが押されたときのメソッド
  Future<void> _insert({String catecoryId, bool isVisible}) async {

    // TODO:orderにかぶりがなく、連番になっていること、連番の最後の番号が降られることのチェック
    bool isAvailable = true;

    final allRows = await dbHelper.queryAllRows(DatabaseHelper.categorySettingTable);
    debugPrint('IN insert. allRows length: ' + allRows.length.toString());
    List<int> orderList = [];
    int order;
    allRows.forEach((row) {
      // idがかぶっていないことのチェック
      if (row[DatabaseHelper.csColumnId] == catecoryId) {
        isAvailable = false;
      }
      if (row[DatabaseHelper.csColumnOrder] != null) {
        // orderに数字が入っているものの収集
        orderList.add(row[DatabaseHelper.csColumnOrder]);
        debugPrint('orderList.length: ' + orderList.length.toString());
      }
    });
    orderList.sort();
    bool isValidSort = true;
    // orderの重複がないかチェック、連番になっているかチェック
    for (int key in orderList.asMap().keys) {
      if(key != orderList[key]) {
        isValidSort = false;
        break;
      }
    }
    // orderに重複がある場合、連番になっていない場合修正
    if (!isValidSort) {
    //  TODO: 正しいソートでupdateする
      int i = 0;
      for (var tmpRow in allRows) {
        Map<String, dynamic> row = {
          DatabaseHelper.csColumnId : tmpRow[DatabaseHelper.csColumnId],
          DatabaseHelper.csColumnOrder  : i,
          DatabaseHelper.csColumnIsVisible : tmpRow[DatabaseHelper.csColumnIsVisible]
        };
        dbHelper.update(DatabaseHelper.categorySettingTable, DatabaseHelper.csColumnId, row);
        i += 1;
      }
    }
    order = orderList.length;


    Map<String, dynamic> row = {
      DatabaseHelper.csColumnId : catecoryId,
      DatabaseHelper.csColumnOrder  : order,
      DatabaseHelper.csColumnIsVisible : isVisible.toString()
    };
    final id = await dbHelper.insert(DatabaseHelper.categorySettingTable ,row);
    print('inserted row id: $id');
  }
  
  Future<void> _delete(String key) async {
    try {
      final id = await dbHelper.delete(
          DatabaseHelper.categorySettingTable, DatabaseHelper.csColumnId, key);
    } catch (e) {

    }
  }
}

class Choice {
  const Choice({this.title, this.icon});
  final String title;
  final IconData icon;
}


const List<Choice> choices = const <Choice>[
  const Choice(title: 'Settings', icon: Icons.settings),
  // const Choice(title: 'My Location', icon: Icons.my_location),
];
