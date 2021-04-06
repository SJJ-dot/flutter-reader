import 'dart:async';

import 'package:flutter_reader/bean/search_result.dart';
import 'package:flutter_reader/crawler/parser.dart';
import 'package:flutter_reader/crawler/parsers/biquge.dart';
import 'package:flutter_reader/utils/logs.dart';
import 'package:rxdart/rxdart.dart';

class Crawler {
  final parsers = <Parser>[new ParserBiQuGe()];

  Stream<List<List<SearchResult>>> search(String key) {
    Map<String, List<SearchResult>> result = {};
    return Rx.merge(parsers.map((e) => e.search(key)))
        .skipWhile((element) => element.isEmpty)
        .map((List<SearchResult> list) {
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
    });
  }

  /// 内部构造方法，可避免外部暴露构造函数，进行实例化
  Crawler._internal();

  /// 单例对象
  static final Crawler _instance = Crawler._internal();

  factory Crawler() => _instance;

  /// 工厂构造方法，这里使用命名构造函数方式进行声明
  factory Crawler.getInstance() => _instance;

  static const qidian = "qidian";
}
