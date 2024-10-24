import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_utilities2/pages/send_product.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_utilities2/pages/add_product.dart';
import 'package:flutter_utilities2/widgets/appbar.dart';

class Mapping extends StatefulWidget {
  const Mapping({super.key});

  @override
  State<Mapping> createState() => _MapPage();
}

class _MapPage extends State<Mapping> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Map'),
      body: Column(
        children: [
          // Divider ใต้ AppBar
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // จัดให้อยู่ตรงกลาง
            children: [
              Container(
                width: 400, // กำหนดความยาวของเส้น
                child: const Divider(
                  color: Color.fromARGB(255, 100, 95, 95), // สีของเส้น
                  thickness: 0.5, // ความหนาของเส้น
                  height: 1, // ความสูงของเส้น
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
