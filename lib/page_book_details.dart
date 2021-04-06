import 'package:flutter/material.dart';

class PageBookDetails extends StatefulWidget {
  PageBookDetails(this.bookId);

  final int bookId;

  @override
  State createState() {
    return _PageState(bookId);
  }
}

class _PageState extends State<PageBookDetails> {
  _PageState(this.bookId);

  int bookId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Text("$bookId"),
    );
  }
}
