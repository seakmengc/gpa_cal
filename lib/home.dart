import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import './file_handling.dart';
import './models/course_model.dart';

class HomePageState extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePageState> {
  final _formKey = GlobalKey<FormState>();

  final List<String> _grades = ['AA', 'BA', 'BB', 'CB', 'CC', 'DC', 'DD', 'F'];
  final List<double> _gradePoints = [4.0, 3.5, 3.0, 2.5, 2.0, 1.5, 1.0, 0.0];
  List<Course> _courses = [];
  double _gpa = 0.0;

  double _calGpa(List<Course> courses) {
    double gpa = 0.0, totalCredit = 0.0;
    for (int i = 0; i < courses.length; ++i) {
      int index = _grades.indexWhere((String x) => x == courses[i].grade);

      gpa += _gradePoints[index] * courses[i].credit;
      totalCredit += courses[i].credit;
    }
    return gpa / totalCredit;
  }

  Widget _buildRaisedBtn(String btnText) {
    return RaisedButton(
      child: Text(btnText),
      onPressed: () {
        print('Cal Btn is pressed!');
        setState(() {
          print(_courses);
          _gpa = _calGpa(_courses);
        });
      },
    );
  }

  Widget _buildCourse(BuildContext context, int index) {
    return Row(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width / 3,
          child: Center(
            child: Text(
              _courses[index].courseName,
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width / 2.5,
          child: DropdownButton<String>(
            value: _courses[index].grade,
            isExpanded: true,
            items: _grades.map((String grade) {
              return DropdownMenuItem(
                child: Text(grade),
                value: grade,
              );
            }).toList(),
            onChanged: (String value) {
              setState(() {
                _courses[index].grade = value;
              });
            },
          ),
        ),
      ],
    );
  }

  void _addCourse(Course course) {
    setState(() {
      _courses.add(course);
    });
  }

  void readData() async {
    List<String> c = [];
    await FileUtils.readFromFile().then((List<String> s) => c = s);
    print('Read data');
    setState(() {
      _courses = FileUtils.toList(c);
    });
  }

  void deleteData() async {
    File file = await FileUtils.getFile;
    await file.delete();
    setState(() {
      _courses = [];
    });
  }

  void _showAddDialog() {
    Course _course = new Course();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Course'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: ListBody(
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Course Name',
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (String value) {
                      _course.courseName = value;
                    },
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Course Credit',
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (String value) {
                      _course.credit = double.parse(value);
                    },
                  ),
                ],
              ),
            ),
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          actions: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width / 3.5,
              margin: EdgeInsets.all(5.0),
              child: FlatButton(
                child: Text('DISCARD'),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 3.5,
              margin: EdgeInsets.all(5.0),
              child: RaisedButton(
                child: Text(
                  'SAVE',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  _formKey.currentState.save();
                  _addCourse(_course);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody() {
    Widget rtn = Container(
      margin: EdgeInsets.all(10.0),
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          Text(_gpa.toStringAsFixed(2)),
          _buildRaisedBtn('CALCULATE'),
          Expanded(
            child: ListView.builder(
              itemCount: _courses.length,
              itemBuilder: _buildCourse,
            ),
          ),
        ],
      ),
    );
    return rtn;
  }

  @override
  void deactivate() {
    print('deactivate');
    super.deactivate();
  }

  @override
  void initState() {
    readData();
    super.initState();
  }

  final _scaffoldState = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text('GPA Calculator'),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDialog();
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        elevation: 20.0,
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              padding: EdgeInsets.only(left: 30.0),
              iconSize: 30.0,
              icon: Icon(Icons.save),
              tooltip: 'Save courses',
              onPressed: () {
                FileUtils.writeToFile(_courses);
                _scaffoldState.currentState.showSnackBar(
                  SnackBar(content: Text('Saved')),
                );
              },
            ),
            IconButton(
              padding: EdgeInsets.only(right: 30.0),
              iconSize: 30.0,
              icon: Icon(Icons.delete_forever),
              tooltip: 'Delete courses',
              onPressed: () {
                deleteData();
                _scaffoldState.currentState.showSnackBar(
                  SnackBar(content: Text('Deleted')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
