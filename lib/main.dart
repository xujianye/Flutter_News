import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api.dart';
import 'dart:convert';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _MyAppState();
  }
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {

  TabController _tabController;
  Map<String, List> map = new Map();

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: titles.length, vsync: this);
//    loadData();
  }

  loadData(String key) async {
    http.Response response = await http.get(Api.getApi(key));
    setState(() {
      Map data = json.decode(response.body);
      map[key] = data['result']['data'];
//      news = data['result']['data'];
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  showLoadingDialog(String key) {
    return map[key] == null;
  }

  Widget getProgressDialog() {
    return new Center(
      child: new CircularProgressIndicator(),
    );
  }

  ListView getListView(String key) =>
      new ListView.builder(
        itemCount: map[key].length,
        itemBuilder: (BuildContext context, int position) {
          if (position.isOdd) return new Divider();
          position = position ~/ 2;
          return new ListTile(
            title: new Text(map[key][position]['title']),
            subtitle: new Text(map[key][position]['author_name']),
            leading: new Image.network(map[key][position]['thumbnail_pic_s']),
            onTap: () {
              print('hello ${map[key][position]}');
              _startNewPage(context, map[key][position]['url']);
            },
          );
        },
      );

  void _startNewPage(BuildContext context, String url) {
    Navigator.of(context).push(
        new MaterialPageRoute(
          builder: (context) {
            return new WebviewScaffold(
              url: url,
              appBar: new AppBar(
                title: new Text('新闻详情'),
              ),
              withJavascript: false,
            );
          },
        )
    );
  }

  Widget getBody(String key) {
    if (showLoadingDialog(key)) {
      return getProgressDialog();
    } else {
      return getListView(key);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('新闻'),
          bottom: new TabBar(tabs: titles.map((SubTitle title) {
            return new Tab(text: title.title,);
          }).toList(), controller: _tabController, isScrollable: true,),
        ),
        body: new TabBarView(
          children: titles.map((SubTitle title) {
            if (map[title.key] == null) {
              loadData(title.key);
            }
            return getBody(title.key);
          }).toList(), controller: _tabController,),
      ),
    );
  }

}

class SubTitle {
  const SubTitle({this.title, this.key});

  final String title;
  final String key;
}

const List<SubTitle> titles = const <SubTitle>[
  const SubTitle(title: '头条', key: 'top'),
  const SubTitle(title: '社会', key: 'shehui'),
  const SubTitle(title: '国内', key: 'guonei'),
  const SubTitle(title: '国际', key: 'guoji'),
  const SubTitle(title: '军事', key: 'junshi'),
  const SubTitle(title: '科技', key: 'keji'),
  const SubTitle(title: '娱乐', key: 'yule'),
];