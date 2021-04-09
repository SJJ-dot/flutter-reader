class Chapter{
  String title;
  String url;

  Chapter(this.title, this.url);

  @override
  String toString() {
    return 'Chapter{title: $title, url: $url}';
  }
}