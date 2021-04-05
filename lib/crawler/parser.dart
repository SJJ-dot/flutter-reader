import 'package:flutter_reader/bean/search_result.dart';

abstract class Parser {
  late String sourceDomain;
  late String sourceName;

  Stream<List<SearchResult>> search(String key);
}
