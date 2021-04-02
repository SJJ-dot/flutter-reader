import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reader/bean/search_result.dart';
import 'package:flutter_reader/utils/logs.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'crawler/crawler.dart';

class PageSearch extends StatefulWidget {
  @override
  State createState() {
    return _PageState();
  }
}

class _PageState extends State<PageSearch> {
  List<List<SearchResult>>? _searchResult;
  late TextEditingController _searchCtr;
  late FocusNode _focusNode;

  @override
  void initState() {
    _searchCtr = TextEditingController();
    _focusNode = FocusNode();

    _focusNode.addListener(handleFocusChange);
    super.initState();
  }

  @override
  void dispose() {
    _searchCtr.dispose();
    _focusNode.removeListener(handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void handleFocusChange() {
    setState(() {
      _searchResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(
            hintText: '请输入书名',
            hintStyle: TextStyle(color: Colors.white),
            border: InputBorder.none,
            hoverColor: Colors.white,
          ),
          style: TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          textInputAction: TextInputAction.search,
          onSubmitted: (text) => _search(_searchCtr.text),
          controller: _searchCtr,
          focusNode: _focusNode,
          autofocus: true,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            tooltip: '搜索',
            onPressed: () {
              _search(_searchCtr.text);
            },
          ),
        ],
      ),
      body: _PageData(state: this, child: _BodyWidget()),
    );
  }

  StreamSubscription? _lastRequest;

  void _search(String str) {
    if (str.isEmpty) {
      _focusNode.requestFocus();
      return;
    }
    _focusNode.unfocus();

    // FocusScope.of(context).requestFocus(FocusNode());
    SharedPreferences.getInstance().then((sp) {
      var list = sp.getStringList("search_history_list") ?? [];
      list.remove(str);
      list.insert(0, str);
      sp.setStringList("search_history_list", list);
    });
    log("搜索……$str");
    _lastRequest?.cancel();
    Map<String, List<SearchResult>> result = {};
    _lastRequest = Crawler.getInstance().search(str).listen((event) {
      if (event.isNotEmpty) {
        for (var book in event) {
          var key = "title:${book.title}author:${book.author}";
          var list = result[key];
          if (list == null) {
            list = [];
            result[key] = list;
          }
          list.add(book);
        }
        var r = result.values.toList();
        r.sort((l1, l2) {
          var c = l1.length.compareTo(l2.length);
          if (c == 0) {
            return "title:${l1.first.title}author:${l1.first.author}"
                .compareTo("title:${l2.first.title}author:${l2.first.author}");
          } else {
            return c;
          }
        });
        setState(() {
          _searchResult = r;
        });
      }
    });
  }
}

class _PageData extends InheritedWidget {
  _PageData({required this.state, required Widget child})
      : this.searchResult = state._searchResult,
        this.focus = state._focusNode.hasFocus,
        super(child: child);

  List<List<SearchResult>>? searchResult;
  bool focus;
  _PageState state;

  void search(String str) {
    state._searchCtr.text = str;
    state._search(str);
  }

  @override
  bool updateShouldNotify(_PageData oldWidget) {
    return oldWidget.searchResult != searchResult || oldWidget.focus != focus;
  }

  static _PageData of(BuildContext context) {
    final _PageData? result = context.dependOnInheritedWidgetOfExactType();
    return result!;
  }
}

//body widget
class _BodyWidget extends StatefulWidget {
  _BodyWidget();

  @override
  State createState() {
    return _BodyState();
  }
}

//body state
class _BodyState extends State<_BodyWidget> {
  _PageState get _pageSearchState =>
      context.findAncestorStateOfType<_PageState>()!;

  @override
  Widget build(BuildContext context) {
    return _PageData.of(context).focus
        ? buildSearchHint(context)
        : buildSearchResult(context);
  }

  Widget buildSearchHint(BuildContext context) {
    return FutureBuilder<List<String>?>(
        future: SharedPreferences.getInstance()
            .then((sp) => sp.getStringList("search_history_list")),
        builder: (BuildContext context, AsyncSnapshot<List<String>?> snapshot) {
          if (snapshot.hasData) {
            var childrens = <Widget>[];
            for (var str in snapshot.data!) {
              var item = Container(
                padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                margin: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 2, //阴影范围
                      spreadRadius: 1, //阴影浓度
                      color: Colors.black12, //阴影颜色
                    ),
                  ],
                  borderRadius: BorderRadius.circular(19), // 圆角也可控件一边圆角大小
                ),
                child: Text(str),
              );
              childrens.add(GestureDetector(
                child: item,
                onLongPress: () {
                  SharedPreferences.getInstance().then((sp) {
                    var list = sp.getStringList("search_history_list") ?? [];
                    list.remove(str);
                    sp.setStringList("search_history_list", list);
                    setState(() {});
                  });
                },
                onTap: () {
                  _pageSearchState._searchCtr.text = str;
                  _pageSearchState._search(str);
                },
              ));
            }

            return Wrap(children: childrens);
          } else {
            return Wrap(children: []);
          }
        });
  }

  Widget buildSearchResult(BuildContext context) {
    var list = _PageData.of(context).searchResult ?? [];
    ListView listView = ListView.builder(
        itemBuilder: (ctx, index) {
          var sr = list[index];
          return Card(
              child: ListTile(
            title: Text(sr.first.title),
            subtitle: Text(sr.first.author),
            trailing: Text(sr.length.toString()),
          ));
        },
        itemCount: list.length);

    return listView;
  }
}
