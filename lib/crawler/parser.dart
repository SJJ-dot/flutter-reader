import 'package:flutter_reader/bean/search_result.dart';

abstract class Parser {
  late String domain;

  Stream<List<SearchResult>> search(String key);
}
