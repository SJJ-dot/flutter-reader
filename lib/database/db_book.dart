import 'package:flutter_reader/bean/book.dart';
import 'package:flutter_reader/bean/search_result.dart';
import 'package:flutter_reader/crawler/crawler.dart';
import 'package:flutter_reader/database/db.dart';
import 'package:flutter_reader/database/db_chapter.dart';
import 'package:sqflite/sqflite.dart';

class DbBook {
  static Future<void> createTable(Database db, int version) async {
    await db.execute("""CREATE TABLE "Book" (
	"id"	INTEGER,
	"sourceDomain"	TEXT,
	"sourceName"	TEXT,
	"title"	TEXT,
	"author"	TEXT,
	"url"	TEXT,
	"intro"	TEXT,
	"cover"	TEXT,
	"reading"	INTEGER DEFAULT 0,
	"readingChapter"	INTEGER DEFAULT -1,
	"readingPos"	INTEGER DEFAULT -1,
	PRIMARY KEY("id" AUTOINCREMENT)
)""");
  }

  /// 保存搜索结果，返回被选中阅读的书籍，如果没有阅读记录，选择正版书源，如果正版书源不存在则随机返回
  static Future<int> saveSearchResult(List<SearchResult> list) async {
    var db = await DB.db;
    var readingId = await db.transaction((txn) async {
      var batch = txn.batch();
      var readingId = -1;
      SearchResult? qidian;
      for (var sr in list) {
        if (sr.sourceDomain == Crawler.qidian) {
          qidian = sr;
        }
        var bks = await txn.query("Book",
            columns: ["id", "reading"],
            where: 'title = ? and author = ? and sourceDomain = ?',
            whereArgs: [sr.title, sr.author, sr.sourceDomain]);
        //同一个网站，不考虑同名同作者存在不同的多本书籍的情况。
        Map<String, Object?> bk = {
          "sourceDomain": sr.sourceDomain,
          "sourceName": sr.sourceName,
          "title": sr.title,
          "author": sr.author,
          "url": sr.url,
        };
        if (bks.isNotEmpty) {
          batch.update(
            "Book",
            bk,
            where: 'id = ?',
            whereArgs: [bks.first["id"]],
          );
          if (bks.first["reading"] != 0) {
            readingId = bks.first["id"] as int;
          }
        } else {
          batch.insert("Book", bk);
        }
      }
      if (readingId == -1) {
        //没有正在阅读的书 更改正在阅读状态。有限使用起点。
        var sr = qidian ?? list.first;
        batch.update("Book", {"reading": 1},
            where: 'title = ? and author = ? and sourceDomain = ?',
            whereArgs: [sr.title, sr.author, sr.sourceDomain]);
      }

      await batch.commit();
      return readingId;
    });
    if (readingId != -1) {
      //正在阅读中的id
      return readingId;
    }
    var sr = list.first;
    //查询正在阅读的书
    var bks = await db.query("Book",
        columns: ["id"],
        where: 'title = ? and author = ? and reading = ?',
        whereArgs: [sr.title, sr.author, 1]);
    return bks.first["id"] as int;
  }

  static Future<void> saveBookDetails(Book book) async {
    var db = await DB.db;
    await db.transaction((txn) async {
      var bookValues = {
        "sourceName": book.sourceName,
        "title": book.title,
        "author": book.author,
        "intro": book.intro,
        "url": book.url,
        "cover": book.cover,
      };
      var batch = txn.batch();
      batch.update("Book", bookValues, where: "id=?", whereArgs: [book.id]);
      DbChapter.saveChapterList(book.chapterList ?? List.empty(), batch);
      await batch.commit(noResult: true);
    });
  }

  static Future<List<Book>> getAllReadingBook() async {
    var db = await DB.db;
    var bks = await db.rawQuery("select * from Book where reading = ?", [1]);
    var res = <Book>[];
    for (var e in bks) {
      res.add(Book(
        id: e["id"] as int,
        sourceDomain: e["sourceDomain"] as String,
        sourceName: e["sourceName"] as String,
        title: e["title"] as String,
        author: e["author"] as String,
        url: e["url"] as String,
        intro: e["intro"] as String?,
        reading: e["reading"] as int == 1,
        readingChapter: e["readingChapter"] as int,
        readingPos: e["readingPos"] as int,
      ));
    }
    return res;
  }

  static Future<Book> getBookDetails(int id) async {
    var db = await DB.db;
    var mapList = await db.rawQuery("select * from Book where id = ?", [id]);
    var map = mapList.first;
    return Book(
        id: map["id"] as int,
        sourceDomain: map["sourceDomain"] as String,
        sourceName: map["sourceName"] as String,
        title: map["title"] as String,
        author: map["author"] as String,
        url: map["url"] as String,
        intro: map["intro"] as String?,
        cover: map["cover"] as String?,
        reading: map["reading"] as int == 1,
        readingChapter: map["readingChapter"] as int,
        readingPos: map["readingPos"] as int,
        chapterList: await DbChapter.getChapterList(map["id"] as int));
  }
}
