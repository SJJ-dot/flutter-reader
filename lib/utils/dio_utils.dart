
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_reader/utils/logs.dart';
import 'package:path_provider/path_provider.dart';

class DioUtils {
  static Future<CookieManager> _cookieManager =
      getApplicationDocumentsDirectory().then((value) {
    String appDocPath = value.path;
    var pcj = PersistCookieJar(
        ignoreExpires: true, storage: FileStorage(appDocPath + "/.cookies/"));
    return CookieManager(pcj);
  });

  static Future<Dio> dio = Future(() async {
    var dio = Dio();
    log("create dio");
    dio.interceptors.add(await _cookieManager);
    dio.interceptors.add(LogInterceptor(requestBody: true));
    return dio;
  });

}
