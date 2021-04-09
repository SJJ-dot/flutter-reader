import 'package:flutter_reader/bean/chapter.dart';
import 'package:sqflite/sqflite.dart';

class BdChapter {
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

  static Future<void> saveChapterList(
      List<Chapter> chapters, Batch batch) async {
    for (var value in chapters) {
      var values = {
        "bookId": value.id,
        "title": value.title,
        "url": value.url,
        "index": value.index,
      };
      if (value.id != -1) {
        values["id"] = value.id;
      }
      if(value.content?.isNotEmpty == true) {
        values["content"] = value.content!;
      }
      batch.insert("Chapter", values,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }
}
