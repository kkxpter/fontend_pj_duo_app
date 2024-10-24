import 'package:flutter/material.dart';
import 'package:flutter_utilities2/pages/main_drawer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FilledButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainDrawerPage(),
                        ));
                  },
                  child: const Text('หน้าหลัก')),
                  FilledButton(
                      onPressed: () {
                      // Fluttertoast.showToast(
                      //   msg: "This is Center Short Toast",
                      //   toastLength: Toast.LENGTH_SHORT,
                      //   gravity: ToastGravity.CENTER,
                      //   timeInSecForIosWeb: 1,
                      //   backgroundColor: Colors.red,
                      //   textColor: Colors.white,
                      //   fontSize: 16.0);
                      //Get.to() => const _GetXPageState();
                      },
                    child: const Text('GetX'))
                      
            ],
            
          ),
        ),
      ),
    );
  }
}
