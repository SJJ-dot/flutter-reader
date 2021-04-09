import 'package:flutter/material.dart';
import 'package:flutter_reader/database/db_book.dart';
import 'package:flutter_reader/database/db_chapter.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DB {
  static Future<Database> db = Future(() async {
    WidgetsFlutterBinding.ensureInitialized();
    return openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'book_database.db'),
      version: 1,
      onCreate: (db, version) async {
       await DbBook.createTable(db, version);
       await BdChapter.createTable(db, version);
      },
    );
  });
}
