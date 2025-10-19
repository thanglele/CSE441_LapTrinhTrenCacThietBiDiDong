import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My TLU',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}