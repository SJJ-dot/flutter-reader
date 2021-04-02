import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'crawler/crawler.dart';

class PageSearch extends StatefulWidget {
  @override
  State createState() {
    return _PageSearchState();
  }
}

class _PageSearchState extends State<PageSearch> {
  TextEditingController _searchCtr;
  FocusNode _focusNode;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    _searchCtr = TextEditingController();
    _focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _searchCtr.dispose();
    _focusNode.dispose();
    super.dispose();
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
          onSubmitted: (text) => _search(context, _searchCtr.text),
          controller: _searchCtr,
          focusNode: _focusNode,
          autofocus: true,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            tooltip: '搜索',
            onPressed: () {
              _search(context, _searchCtr.text);
            },
          ),
        ],
      ),
      body: _PageSearchBodyWidget(this),
    );
  }

  void _search(BuildContext context, String str) {
    if (str.isEmpty) {
      _focusNode.requestFocus();
      return;
    }
    _focusNode.unfocus();

    // FocusScope.of(context).requestFocus(FocusNode());
    _prefs.then((sp) {
      var list = sp.getStringList("search_history_list") ?? [];
      list.remove(str);
      list.add(str);
      sp.setStringList("search_history_list", list);
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("搜索……$str")));
    print("搜索……$str");
    crawler.search(str);
  }
}

class _PageSearchBodyWidget extends StatefulWidget {
  _PageSearchBodyWidget(this._pageSearchState);

  final _PageSearchState _pageSearchState;

  @override
  State createState() {
    return _PageSearchBodyState(_pageSearchState);
  }
}

class _PageSearchBodyState extends State<_PageSearchBodyWidget> {
  _PageSearchBodyState(this._pageSearchState);

  final _PageSearchState _pageSearchState;

  @override
  void initState() {
    super.initState();
    _pageSearchState._focusNode.addListener(handleFocusChange);
  }

  @override
  void dispose() {
    super.dispose();
    _pageSearchState._focusNode.removeListener(handleFocusChange);
  }

  @override
  Widget build(BuildContext context) {
    return _pageSearchState._focusNode.hasFocus
        ? buildSearchHint(context)
        : buildSearchResult(context);
  }

  void handleFocusChange() {
    setState(() {});
  }

  Widget buildSearchHint(BuildContext context) {
    return FutureBuilder<List<String>>(
        future: _pageSearchState._prefs
            .then((sp) => sp.getStringList("search_history_list")),
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.hasData) {
            var childrens = <Widget>[];
            for (var str in snapshot.data) {
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
                  _pageSearchState._prefs.then((sp) {
                    var list = sp.getStringList("search_history_list") ?? [];
                    list.remove(str);
                    sp.setStringList("search_history_list", list);
                    setState(() {});
                  });
                },
                onTap: () {
                  _pageSearchState._searchCtr.text = str;
                  _pageSearchState._search(context, str);
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
    return Text("buildSearchResult");
  }
}
