import 'package:flutter/material.dart';
import 'package:flutter_reader/bean/book.dart';
import 'package:flutter_reader/database/db_book.dart';
import 'package:flutter_reader/page_reading.dart';

class PageBookDetails extends StatelessWidget {
  PageBookDetails(this.bookId);

  final int bookId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DbBook.getBookDetails(bookId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Book book = snapshot.data as Book;
          return Scaffold(
            appBar: AppBar(
              title: Text("书籍详情"),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.all(16),
                      color: Colors.amberAccent,
                      width: 140,
                      height: 180,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(book.title!),
                        Text("作者：${book.author}"),
                        Text("最新章节"),
                      ],
                    )
                  ],
                ),
                Text(book.sourceName!),
                Expanded(
                  child: Text("简介：${book.intro}"),
                ),
                Container(
                  width: double.infinity,
                  height: 50,
                  margin: EdgeInsets.all(10),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (c) => PageReading()));
                    },
                    child: Text("开始阅读"),
                  ),
                )
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        } else {
          return Center(
            child: Text("加载中"),
          );
        }
      },
    );
  }
}
