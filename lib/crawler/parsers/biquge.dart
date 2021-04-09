import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_reader/bean/book.dart';
import 'package:flutter_reader/bean/chapter.dart';
import 'package:flutter_reader/bean/search_result.dart';
import 'package:flutter_reader/crawler/parser.dart';
import 'package:flutter_reader/utils/dio_utils.dart';
import 'package:flutter_reader/utils/logs.dart';
import 'package:html/parser.dart';

class ParserBiQuGe extends Parser {
  @override
  String get sourceDomain => "www.biquge.se";

  @override
  String get sourceName => "笔趣阁se";

  @override
  Future<List<SearchResult>> search(String key, CancelToken cancelToken) async {
    var dio = await DioUtils.dio;
    //set cookie
    await dio.get("http://www.biquge.se", cancelToken: cancelToken);
    var res = await dio.post("http://www.biquge.se/case.php",
        data: FormData.fromMap({"key": key}),
        queryParameters: {"m": "search"},
        cancelToken: cancelToken);

    return compute(parseSearchResult, {
      "data": res.data,
      "realUri": res.realUri,
      "sourceDomain": sourceDomain,
      "sourceName": sourceName,
    });
  }

  @override
  Future<Book> getBookDetail(Book book, CancelToken cancelToken) async {
    var dio = await DioUtils.dio;
    var res = await dio.get(book.url!, cancelToken: cancelToken);
    return compute(parseBookDetails, {
      "data": res.data,
      "realUri": res.realUri,
      "sourceDomain": sourceDomain,
      "sourceName": sourceName,
    }).then((value) {
      book.sourceName = value.sourceName;
      book.title = value.title;
      book.author = value.author;
      book.intro = value.intro;
      book.url = value.url;
      book.cover = value.cover;
      book.chapterList = value.chapterList;
      for (var i = 0; i < (value.chapterList?.length ?? 0); i++) {
        value.chapterList![i].index = i;
        value.chapterList![i].bookId = book.id;
      }
      return book;
    });
  }
}

Book parseBookDetails(Map<String, dynamic> map) {
  Book book = Book();
  var data = map["data"];
  Uri uri = map["realUri"];
  String sourceDomain = map["sourceDomain"];
  String sourceName = map["sourceName"];
  var html = parse(data, sourceUrl: uri.toString());
  book.sourceDomain = sourceDomain;
  book.sourceName = sourceName;
  book.title = html.querySelector("#info > h1")?.text;
  book.author = html.querySelector("#info")?.children[1].text.split("者：")[1];
  book.url = uri.toString();
  book.intro = html.querySelector("#intro")?.outerHtml;
  var src = html.querySelector("#fmimg > img")?.attributes["src"];
  book.cover = uri.resolve(src ?? "").toString();
  var chapterList = <Chapter>[];
  var chapterListEl = html.querySelectorAll("#list > dl > *");
  for (int i = chapterListEl.length - 1; i >= 0; i--) {
    var chapterEl = chapterListEl[i];
    if ("dt" == chapterEl.localName) {
      break;
    }
    var chapterA = chapterEl.querySelector("a");
    var url = uri.resolve(chapterA?.attributes["href"] ?? "").toString();
    chapterList.insert(0, Chapter(chapterA?.text ?? "empty", url));
  }
  book.chapterList = chapterList;
  return book;
}

List<SearchResult> parseSearchResult(Map<String, dynamic> map) {
  var data = map["data"];
  var uri = map["realUri"];
  var sourceDomain = map["sourceDomain"];
  var sourceName = map["sourceName"];
  var html = parse(data, sourceUrl: uri.toString());
  var bookListEl = html.querySelectorAll("#newscontent > div.l > ul > li");
  var results = <SearchResult>[];
  try {
    for (var bookEl in bookListEl) {
      var title = bookEl.querySelector(".s2 > a")!.text;
      var url = bookEl.querySelector(".s2 > a")!.attributes["href"]!;
      var author = bookEl.querySelector(".s4")!.text;
      var r = SearchResult(
          sourceDomain, sourceName, title, author, uri.resolve(url).toString());
      results.add(r);
    }
  } catch (e) {
    log(e);
  }
  return results;
}
