import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_utilities2/pages/main_drawer.dart';
class Page1 extends StatefulWidget {
  const Page1({super.key});

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(),
      body: Container(),
    );
  }
}