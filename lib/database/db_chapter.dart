import 'package:flutter_reader/bean/chapter.dart';
import 'package:flutter_reader/database/db.dart';
import 'package:sqflite/sqflite.dart';

class DbChapter {
  static Future<void> createTable(Database db, int version) async {
    await db.execute("""CREATE TABLE "Chapter" (
	"id"	INTEGER,
	"bookId"	INTEGER,
	"title"	TEXT,
	"url"	TEXT,
	"content"	TEXT,
	"index"	INTEGER UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
)""");
  }

  static Future<void> saveChapterList(List<Chapter> chapters,
      Batch batch) async {
    for (var value in chapters) {
      var values = {
        "bookId": value.bookId,
        "title": value.title,
        "url": value.url,
        "index": value.index,
      };
      if (value.id != -1) {
        values["id"] = value.id;
      }
      if (value.content?.isNotEmpty == true) {
        values["content"] = value.content!;
      }
      batch.insert("Chapter", values,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  static Future<List<Chapter>> getChapterList(int bookId) async {
    var db = await DB.db;

    var chapterList = await db.rawQuery("select id,title,url from Chapter where bookId = '$bookId' order by 'index'");
    var chapters = <Chapter>[];
    for (var value in chapterList) {
      chapters.add(Chapter(
          value["title"]?.toString() ?? "",
          value["url"]?.toString() ?? "",
          id: value["id"] as int,
          index: chapters.length),
      );
    }
    return chapters;
  }
}
