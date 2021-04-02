import 'dart:math';

void log(msg) {
  var str = msg.toString();

  for (int i = 0; i < str.length; i += 950) {
    print(str.substring(i, min(i + 950, str.length)));
  }
}
