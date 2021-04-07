import 'package:flutter/material.dart';
import 'package:flutter_reader/bean/book.dart';
import 'package:flutter_reader/database/db_book.dart';
import 'package:flutter_reader/page_reading.dart';
import 'package:flutter_reader/utils/logs.dart';

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
              title: Text("${book.title}"),
            ),
            body: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  left: 20,
                  top: 20,
                  right: 20,
                  bottom: 20,
                  child: RefreshIndicator(
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics()
                      ),
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              color: Colors.amberAccent,
                              width: 140,
                              height: 180,
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                    child: Text(
                                      "${book.title}",
                                      style: TextStyle(fontSize: 24),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                    child: Text(
                                      "${book.author}",
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.black54),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                    child: Text(
                                      "${book.sourceName}",
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.redAccent),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                    child: Text(
                                      "最新章节",
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.redAccent),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                          child: Text("简介：${book.intro ?? ""}"),
                        ),
                      ],
                    ),
                    onRefresh: onRefresh,
                  ),
                ),
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 10,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (c) => PageReading()));
                    },
                    child: Text(
                      "开始阅读",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
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

  Future<void> onRefresh() async {
    log("下拉刷新");
  }
}
