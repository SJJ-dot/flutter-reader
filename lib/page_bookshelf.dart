import 'package:flutter/material.dart';
import 'package:flutter_reader/bean/book.dart';
import 'package:flutter_reader/database/db_book.dart';
import 'package:flutter_reader/page_book_details.dart';
import 'package:flutter_reader/page_search.dart';
import 'package:flutter_reader/utils/logs.dart';

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
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PageSearch(),
                  ));
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: DbBook.getAllReadingBook(),
        builder: (context, AsyncSnapshot<List<Book>> snapshot) {
          if (snapshot.hasData) {
            List<Book> list = snapshot.data!;
            return ListView.builder(
              itemBuilder: (ctx, index) {
                var bk = list[index];
                return GestureDetector(
                  child: Card(
                    child: ListTile(
                      title: Text(bk.title!),
                      subtitle: Text(bk.author!),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PageBookDetails(bk.id)),
                    );
                  },
                );
              },
              itemCount: list.length,
            );
          } else {
            return Center(
              child: Text("加载中"),
            );
          }
        },
      ),
    );
  }
}
