import 'dart:async';

import 'package:flutter_reader/bean/search_result.dart';
import 'package:flutter_reader/crawler/parser.dart';
import 'package:flutter_reader/crawler/parsers/biquge.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/streams.dart';

class Crawler {
  final parsers = <Parser>[new ParserBiQuGe()];

  Stream<List<SearchResult>> search(String key) {
    return Rx.merge(parsers.map((e) => e.search(key)));
  }

  /// 内部构造方法，可避免外部暴露构造函数，进行实例化
  Crawler._internal();

  /// 单例对象
  static final Crawler _instance = Crawler._internal();

  factory Crawler() => _instance;

  /// 工厂构造方法，这里使用命名构造函数方式进行声明
  factory Crawler.getInstance() => _instance;
}
