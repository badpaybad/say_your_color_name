import 'package:flutter_test/flutter_test.dart';

import 'package:say_your_color_name/self.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

Future<void> main() async {
  test('adds one to input values', () async {
    //
    var r = await http
        .get(Uri.parse("https://avatars.githubusercontent.com/u/6204507?v=4"));

    var name = await ColorHelper.instance.getColorNameFromImage(r.bodyBytes);

    print(name);
  });
}
