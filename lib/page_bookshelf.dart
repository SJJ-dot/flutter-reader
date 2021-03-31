import 'package:flutter/material.dart';

class Bookshelf extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("书架"),
          actions:  [
            IconButton(
              icon: Icon(Icons.search),
              tooltip: 'search',
              onPressed: () {
                // handle the press
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Awesome Snackbar!"),
                  ),
                );

              },
            ),
          ],
        ),
        body: Text("书架body"));
  }
}
