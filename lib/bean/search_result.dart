class SearchResult {
  SearchResult(this.domain, this.title, this.author, this.url);

  String domain;
  String title;
  String author;
  String url;

  @override
  String toString() {
    return 'SearchResult{domain: $domain, title: $title, author: $author, url: $url}';
  }
}
