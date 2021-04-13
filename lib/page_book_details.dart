import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_reader/bean/book.dart';
import 'package:flutter_reader/crawler/crawler.dart';
import 'package:flutter_reader/database/db_book.dart';
import 'package:flutter_reader/page_reading.dart';
import 'package:flutter_reader/utils/logs.dart';

class PageBookDetails extends StatefulWidget {
  PageBookDetails(this.bookId);

  final int bookId;

  @override
  State createState() {
    return _PageState(bookId);
  }
}

class _PageState extends State<PageBookDetails> {
  _PageState(this.bookId);

  final int bookId;
  Book? _bk;

  @override
  Widget build(BuildContext context) {
    if (_bk != null) {
      return buildPage(context, _bk!);
    }
    return FutureBuilder(
      future: DbBook.getBookDetails(bookId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Book book = snapshot.data as Book;
          _bk = book;
          return buildPage(context, book);
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

  Widget buildPage(BuildContext context, Book book) {
    var chapterList = book.chapterList ?? List.empty();

    return Scaffold(
      appBar: AppBar(
        title: Text("${book.title}"),
      ),
      // onEndDrawerChanged: (b) {
      //   log("drawer b$b");
      // },
      endDrawer: Drawer(
        child: ListView.builder(
          itemCount: chapterList.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              child: Container(
                padding: EdgeInsets.all(10),
                child: Text(chapterList[index].title),
              ),
            );
          },
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: 20,
            top: 20,
            right: 20,
            bottom: 20,
            child: EasyRefresh(
              child: ListView(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 140,
                        height: 180,
                        child: Image.network(book.cover ?? ""),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                child: Expanded(
                                  child: Text(
                                    "${book.title}",
                                    style: TextStyle(fontSize: 24),
                                  ),
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
                                      fontSize: 18, color: Colors.redAccent),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: Text(
                                  "最新章节",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.redAccent),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                    child: Html(data: "简介：${book.intro ?? ""}"),
                  ),
                ],
              ),
              onRefresh: () => onRefresh(book),
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            bottom: 10,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (c) => PageReading()));
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
  }

  CancelToken? _cancelToken;

  Future<void> onRefresh(Book book) async {
    _cancelToken?.cancel();
    try {
      var bk = await Crawler.getInstance()
          .getBookDetail(book, _cancelToken = CancelToken());
      await DbBook.saveBookDetails(bk);
      setState(() {
        _bk = bk;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(days: 1),
          content: Text(e.toString()),
          action: SnackBarAction(
            label: "ok",
            onPressed: () {
              // Code to execute.
            },
          ),
        ),
      );
      log(e);
    }

    //var a =  await _lastRequest;
  }
}
