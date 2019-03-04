import 'package:flutter/material.dart';

import './home.dart';
import './file_handling.dart';
import './models/course_model.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static final int courseCnt = 4;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePageState(),
    );
  }
}
