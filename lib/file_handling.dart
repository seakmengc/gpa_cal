import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';

import './models/course_model.dart';

class FileUtils {
  static Future<File> get getFile async {
    var dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/data.txt');
  }

  static Future<File> writeToFile(List<Course> contents) async {
    String write = '';
    for (var s in contents) {
      write += s.courseName + '|' + s.credit.toString() + '|' + s.grade + '\n';
    }

    final file = await getFile;
    print(write);
    return file.writeAsString(write);
  }

  static Future<List<String>> readFromFile() async {
    try {
      final file = await getFile;
      return file.readAsLines();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  static List<Course> toList(List<String> listStrings) {
    List<Course> courses = [];
    Course c;
    for (var s in listStrings) {
      c = new Course();
      var split = s.split('|');
      c.courseName = split[0];
      c.credit = double.parse(split[1]);
      c.grade = split[2];
      courses.add(c);
    }
    return courses;
  }
}
