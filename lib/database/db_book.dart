import 'package:flutter_reader/bean/search_result.dart';
import 'package:flutter_reader/database/db.dart';
import 'package:sqflite/sqflite.dart';

class DbBook {
  static void createTable(Database db, int version) {
    db.execute("CREATE TABLE Book (id INTEGER PRIMARY KEY,"
        " sourceDomain TEXT,"
        " sourceName TEXT,"
        " title TEXT,"
        " author TEXT,"
        " url TEXT,"
        " intro TEXT,"
        " reading INTEGER,"
        " readingChapter INTEGER,"
        " readingPos INTEGER,)");
  }

  /// 保存搜索结果，返回被选中阅读的书籍，如果没有阅读记录，选择正版书源，如果正版书源不存在则随机返回
  static Future<int> saveSearchResult(List<SearchResult> list) async {
    var db = await DB.db;
    // db.insert(table, values);
    return 0;
  }
}
