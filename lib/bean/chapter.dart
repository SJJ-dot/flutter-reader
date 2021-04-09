class Chapter {
  int id;
  int bookId;
  String title;
  String url;
  String? content;
  int index;

  Chapter(this.title, this.url,
      {this.index = -1, this.id = -1, this.bookId = -1});

  @override
  String toString() {
    return 'Chapter{title: $title, url: $url}';
  }
}
