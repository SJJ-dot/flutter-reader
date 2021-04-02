import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_reader/crawler/parser.dart';
import 'package:flutter_reader/utils/logs.dart';
import 'package:path_provider/path_provider.dart';

class ParserBiQuGe extends Parser {
  Future<CookieManager> _cookieManager;

  ParserBiQuGe() {
    Future<Directory> appDocDir = getApplicationDocumentsDirectory();
    _cookieManager = appDocDir.then((value) {
      String appDocPath = value.path;
      var pcj = PersistCookieJar(
          ignoreExpires: true, storage: FileStorage(appDocPath + "/.cookies/"));
      return CookieManager(pcj);
    });
  }

  @override
  void search(String key) async {
    var dio = Dio();
    dio.interceptors.add(await _cookieManager);
    await dio.get("http://www.biquge.se");
    Response res = await dio.post("http://www.biquge.se/case.php",
        data: {"key": key}, queryParameters: {"m": "search"});

    log(res.data);
  }
}
