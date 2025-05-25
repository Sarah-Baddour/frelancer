import 'package:flutter/material.dart';

class Test extends StatefulWidget {
  //مشان اعمل تحديث للواجهة
  final String tx ;
  const Test({super.key, required this.tx});

  @override
  State<Test> createState() => _TestState();
}


class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.tx,
    style: TextStyle(
      color: Colors.white
    ),);
  }
}
