import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_utilities2/pages/main_drawer.dart';
import 'package:flutter_utilities2/pages/regis_user.dart';
import 'package:flutter_utilities2/pages/startlogin.dart';
import 'package:flutter_utilities2/widgets/drawer.dart';
import 'package:flutter_utilities2/pages/home.dart';
import 'package:get/get.dart';
import 'package:flutter_utilities2/pages/main_rider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ต้องเรียกใช้ก่อนที่จะใช้ Firebase
  
  await Firebase.initializeApp(); // เริ่มต้น Firebase
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  runApp(const MyApp()); // เปลี่ยนให้เป็นชื่อของแอปของคุณ
  
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      title: 'Flutter Demo',
      home: StartLogin(),
    );
  }
  
}