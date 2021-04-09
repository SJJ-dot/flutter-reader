import 'dart:math';
import 'package:stack_trace/stack_trace.dart';
void log(msg) {
  var str = msg.toString();
  var frame = Chain.current(1).toTrace().frames.first;
  var line = "${frame.uri}:${frame.line}:${frame.column}";

  for (int i = 0; i < str.length; i += 800) {
    print("$line===>${str.substring(i, min(i + 800, str.length))}");
  }
}
