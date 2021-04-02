import 'package:flutter_reader/crawler/parser.dart';
import 'package:flutter_reader/crawler/parsers/biquge.dart';
import 'package:flutter_reader/utils/logs.dart';

var crawler = Crawler();

class Crawler {
  final parsers = <Parser>[new ParserBiQuGe()];

  void search(String key) async{
    parsers.first.search(key);
  }
}
