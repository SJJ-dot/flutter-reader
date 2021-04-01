import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageSearch extends StatefulWidget {
  @override
  State createState() {
    return PageSearchState();
  }
}

class PageSearchState extends State<PageSearch> {
  final _searchCtr = TextEditingController();
  final _focusNode = FocusNode();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(handleFocusChange);
    final Future<List<String>> searchHistoryList =
        _prefs.then((value) => value.getStringList("search_history_list"));
  }

  @override
  void dispose() {
    super.dispose();
    _searchCtr.dispose();
    _focusNode.removeListener(handleFocusChange);
    _focusNode.dispose();
  }

  void handleFocusChange() {
    setState(() {
      print("focus hasFocus:${_focusNode.hasFocus}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(
            hintText: '请输入书名',
            hintStyle: TextStyle(color: const Color(0xFFFFFFFF)),
            border: InputBorder.none,
            hoverColor: const Color(0xFFFFFFFF),
          ),
          style: TextStyle(color: const Color(0xFFFFFFFF)),
          cursorColor: const Color(0xFFFFFFFF),
          textInputAction: TextInputAction.search,
          onSubmitted: (text) => search(context, _searchCtr.text),
          controller: _searchCtr,
          focusNode: _focusNode,
          autofocus: true,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            tooltip: '搜索',
            onPressed: () {
              FocusScope.of(context).requestFocus(FocusNode());
              search(context, _searchCtr.text);
            },
          ),
        ],
      ),
      body: _focusNode.hasFocus
          ? buildSearchHint(context)
          : buildSearchResult(context),
    );
  }

  Widget buildSearchHint(BuildContext context) {
    return FutureBuilder<List<String>>(
        future: _prefs.then((sp) => sp.getStringList("search_history_list")),
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          print(snapshot.data);
          if (snapshot.hasData) {
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: snapshot.data.map((e) => Text(e)).toList(),
            );
          } else {
            return Wrap(children: []);
          }
        });
  }

  Widget buildSearchResult(BuildContext context) {
    return Text("buildSearchResult");
  }

  void search(BuildContext context, String str) {
    if (str.isEmpty) {
      _focusNode.requestFocus();
      return;
    }
    _prefs.then((sp) {
      var list = sp.getStringList("search_history_list") ?? [];
      list.add(str);
      sp.setStringList("search_history_list", list);
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("搜索……$str")));
  }
}
