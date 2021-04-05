class Book {
  Book(
      {this.id = 0,
      this.sourceDomain,
      this.sourceName,
      this.title,
      this.author,
      this.url,
      this.reading = false,
      this.readingChapter = -1,
      this.readingPos = -1});
  ///数据库主键id
  int id;
  String? sourceDomain;
  String? sourceName;
  String? title;
  String? author;

  String? url;
  String? intro;

  ///是否正在阅读本书
  bool reading;

  ///正在阅读的章节 从-1开始
  int readingChapter;

  ///正在阅读的文字索引从-1开始
  int readingPos;
}
