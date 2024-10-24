import 'package:flutter/material.dart';
import 'package:flutter_utilities2/pages/selectLogin.dart';

class StartLogin extends StatefulWidget {
  const StartLogin({super.key});

  @override
  State<StartLogin> createState() => _StartLogin();
}

class _StartLogin extends State<StartLogin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 12, 24, 68), // สีพื้นหลังที่กำหนด
      body: GestureDetector(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const SelectLogin()));
        },
        child: Center(
          child: Image.asset(
            'assets/images/m.png',
            width: 300,
            height: 300,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
