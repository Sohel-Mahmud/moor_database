import 'package:flutter/material.dart';
import 'package:moor_database/data/moor_database.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'data/ui/home_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final db = AppDatabase();
    return MultiProvider(
      child: MaterialApp(
        title: 'Room Demo',
        home: HomePage(),
      ),
      providers: [
        Provider(
          create: (context) => db.taskDao,
        ),
        Provider(
          create: (context) => db.tagDao,
        ),
      ],
    );
  }
}
