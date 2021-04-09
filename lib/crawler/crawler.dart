import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_reader/bean/book.dart';
import 'package:flutter_reader/bean/search_result.dart';
import 'package:flutter_reader/crawler/parser.dart';
import 'package:flutter_reader/crawler/parsers/biquge.dart';
import 'package:flutter_reader/utils/logs.dart';
import 'package:rxdart/rxdart.dart';

class Crawler {
  final _parsers = <Parser>[new ParserBiQuGe()];
  final Map<String, Parser> _parsersMap = {};

  Stream<List<List<SearchResult>>> search(String key) {
    Map<String, List<SearchResult>> result = {};
    CancelToken cancelToken = CancelToken();
    return Rx.merge(_parsers.map((e) => e
            .search(key, cancelToken)
            .catchError((error, stackTrace) => {})
            .asStream()))
        .doOnCancel(() => cancelToken.cancel())
        .skipWhile((element) => element.isEmpty)
        .map(
      (List<SearchResult> list) {
        for (var book in list) {
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
        return r;
      },
    );
  }

  Future<Book> getBookDetail(Book book, CancelToken cancelToken) async {
    return _parsersMap[book.sourceDomain]?.getBookDetail(book, cancelToken) ??
        Future.error("未找到书源");
  }

  /// 内部构造方法，可避免外部暴露构造函数，进行实例化
  Crawler._internal() {
    for (var value in _parsers) {
      _parsersMap[value.sourceDomain] = value;
    }
  }

  /// 单例对象
  static final Crawler _instance = Crawler._internal();

  factory Crawler() => _instance;

  /// 工厂构造方法，这里使用命名构造函数方式进行声明
  factory Crawler.getInstance() => _instance;

  static const qidian = "qidian";
}
