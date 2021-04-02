import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_reader/bean/search_result.dart';
import 'package:flutter_reader/crawler/parser.dart';
import 'package:flutter_reader/utils/dio_utils.dart';
import 'package:flutter_reader/utils/logs.dart';
import 'package:html/parser.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/streams.dart';

class ParserBiQuGe extends Parser {
  @override
  String get domain => "www.biquge.se";

  @override
  Stream<List<SearchResult>> search(String key) {
    StreamController<List<SearchResult>> controller = StreamController();
    CancelToken cancelToken = CancelToken();

    controller.onCancel = () {
      cancelToken.cancel();
    };

    DioUtils.dio.then((dio) {
      return dio
          .get("http://www.biquge.se", cancelToken: cancelToken)
          .then((value) => dio);
    }).then((dio) {
      return dio.post("http://www.biquge.se/case.php",
          data: FormData.fromMap({"key": key}),
          queryParameters: {"m": "search"},
          cancelToken: cancelToken);
    }).then((res) {
      var html = parse(res.data, sourceUrl: res.realUri.toString());
      var bookListEl = html.querySelectorAll("#newscontent > div.l > ul > li");
      var results = <SearchResult>[];
      try {
        for (var bookEl in bookListEl) {
          var title = bookEl.querySelector(".s2 > a")!.text;
          var url = bookEl.querySelector(".s2 > a")!.attributes["href"]!;
          var author = bookEl.querySelector(".s4")!.text;
          var r = SearchResult(
              this.domain, title, author, res.realUri.resolve(url).toString());
          results.add(r);
        }
      } catch (e) {
        log(e);
      }
      controller.add(results);
      controller.close();
    });
    return controller.stream;
  }
}
