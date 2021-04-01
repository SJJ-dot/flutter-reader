import 'package:flutter/material.dart';
import 'package:flutter_reader/page_search.dart';

class PageBookshelf extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("书架"),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              tooltip: 'search',
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context)=>PageSearch(),
                ));
              },
            ),
          ],
        ),
        body: Text("书架body"));
  }
}
