import 'package:dio/dio.dart';
import 'package:flutter_reader/bean/book.dart';
import 'package:flutter_reader/bean/search_result.dart';

abstract class Parser {
  late String sourceDomain;
  late String sourceName;

  Future<List<SearchResult>> search(String key,CancelToken cancelToken);

  Future<Book> getBookDetail(Book book,CancelToken cancelToken);
}
