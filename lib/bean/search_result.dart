class SearchResult {
  SearchResult(this.sourceDomain,this.sourceName, this.title, this.author, this.url);

  String sourceDomain;
  String sourceName;
  String title;
  String author;
  String url;

  @override
  String toString() {
    return 'SearchResult{sourceDomain: $sourceDomain, title: $title, author: $author, url: $url}';
  }
}
