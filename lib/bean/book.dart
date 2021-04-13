import 'package:flutter_reader/bean/chapter.dart';

class Book {
  Book(
      {this.id = -1,
      this.sourceDomain,
      this.sourceName,
      this.title,
      this.author,
      this.url,
      this.intro,
      this.cover,
      this.reading = false,
      this.readingChapter = -1,
      this.readingPos = -1,
      this.chapterList});

  ///数据库主键id
  int id;
  String? sourceDomain;
  String? sourceName;
  String? title;
  String? author;

  String? url;
  String? intro;
  String? cover;

  ///是否正在阅读本书
  bool reading;

  ///正在阅读的章节 从-1开始
  int readingChapter;

  ///正在阅读的文字索引从-1开始
  int readingPos;

  ///
  List<Chapter>? chapterList;

  @override
  String toString() {
    return 'Book{id: $id, sourceDomain: $sourceDomain, sourceName: $sourceName, title: $title, author: $author, url: $url, intro: $intro, cover: $cover, reading: $reading, readingChapter: $readingChapter, readingPos: $readingPos, chapterList: $chapterList}';
  }
}
