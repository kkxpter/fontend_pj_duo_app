import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_utilities2/pages/update1_rider.dart';
import 'package:google_fonts/google_fonts.dart';

class MapRider extends StatefulWidget {
  const MapRider({super.key});

  @override
  State<MapRider> createState() => _MapRider();
}

class _MapRider extends State<MapRider> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // พื้นหลังสีขาว
        title: Center( // จัดตำแหน่งข้อความให้ตรงกลาง
          child: Text(
            'Map',
            style: GoogleFonts.kanit(
              color: const Color.fromARGB(255, 12, 24, 68), // สีข้อความ
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        leading: Container(), // ปิดการแสดงปุ่มย้อนกลับ
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16), // เว้นระยะจากขอบขวา
            child: Image.asset(
              'assets/images/m.png', // เปลี่ยนให้ตรงกับโลโก้ของคุณ
              height: 40, // ปรับขนาดโลโก้
            ),
          ),
        ],
        elevation: 0, // ปิดเงาของ AppBar
      ),
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

          Expanded(child: Container()), // เพื่อผลักดันปุ่มไปยังด้านล่าง

          // ปุ่มรับงาน
          SizedBox(
            width: 200,
            height: 40,
            child: ElevatedButton(
              onPressed: () {
                log("ปุ่ม รับงาน!");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Update1()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 12, 24, 68),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                textStyle: GoogleFonts.kanit(fontSize: 18),
              ),
              child: Text(
                'รับงาน',
                style: GoogleFonts.kanit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
