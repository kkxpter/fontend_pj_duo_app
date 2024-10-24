import 'dart:convert';
import 'dart:developer';
import 'dart:io'; // สำหรับการจัดการไฟล์รูปภาพ
import 'package:flutter/material.dart';
import 'package:flutter_utilities2/config/config.dart';
import 'package:flutter_utilities2/models/register_req.dart';
import 'package:flutter_utilities2/pages/gps.dart';
import 'package:flutter_utilities2/pages/login_user.dart';
import 'package:flutter_utilities2/pages/login_user.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart'; // สำหรับการเลือกหรือถ่ายรูป
import 'package:flutter_utilities2/widgets/appbar.dart';
import 'package:firebase_storage/firebase_storage.dart'; // สำหรับการอัปโหลดไฟล์
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class RegisUser extends StatefulWidget {
  const RegisUser({super.key});

  @override
  State<RegisUser> createState() => _RegisUser();
}

class _RegisUser extends State<RegisUser> {
  // ตัวแปรสำหรับจัดเก็บรูปและข้อมูลฟอร์ม
  XFile? _image;
  final ImagePicker picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _latitudeController =
      TextEditingController(); // ควบคุมละติจูด
  final TextEditingController _longitudeController =
      TextEditingController(); // ควบคุมลองจิจูด

  Future<String?> uploadImage() async {
    if (_image != null) {
      try {
        // สร้าง reference ไปยัง Firebase Storage
        final ref = FirebaseStorage.instance
            .ref()
            .child('IMG/${DateTime.now().millisecondsSinceEpoch}.jpg');

        // แปลง XFile เป็น File ก่อนอัปโหลด
        UploadTask uploadTask = ref.putFile(File(_image!.path));

        // รอให้อัปโหลดเสร็จสิ้น
        TaskSnapshot snapshot = await uploadTask;

        // ตรวจสอบสถานะการอัปโหลด
        if (snapshot.state == TaskState.success) {
          String downloadUrl = await ref.getDownloadURL();
          log('Image uploaded successfully: $downloadUrl');
          return downloadUrl;
        } else {
          log('Image upload failed');
          return null;
        }
      } catch (e) {
        log('Error uploading image: $e');
        return null;
      }
    } else {
      log('No image selected');
      return null;
    }
  }

  // ฟังก์ชันสำหรับเลือกรูป
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile; // เก็บเป็น XFile
      });
    }
  }

  // แสดงเมนูเลือกรูป
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('เลือกจากแกลเลอรี่'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('ถ่ายรูปใหม่'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ตรวจสอบรหัสผ่านและยืนยันรหัสผ่าน
  bool _validatePasswords() {
    return _passwordController.text == _confirmPasswordController.text;
  }

  // แสดง Popup ยืนยัน
  void _showConfirmationDialog() async {
    if (_validatePasswords()) {
      if (_image != null) {
        // อัปโหลดรูปภาพไปยัง Firebase
        String? imageUrl = await uploadImage();
        if (imageUrl != null) {
          // สร้างข้อมูล JSON สำหรับส่งไปที่ API
          print(imageUrl);
          var model = RegisterRequst(
              name: _nameController.text,
              phone: _phoneController.text,
              password: _passwordController.text,
              img: imageUrl,
              address: _addressController.text,
              latitude: _latitudeController.text,
              longitude: _longitudeController.text);

          try {
            var config = await Configuration.getConfig();
            var url = config['apiEndpoint'];

            // ส่งข้อมูลไปยัง API
            final dataPOST = await http.post(
              Uri.parse("$url/user/insert"),
              headers: {"Content-Type": "application/json"},
              body: registerRequstToJson(model),
            );

            log(dataPOST.body);
                log(dataPOST.statusCode.toString());
                print("Model data to send: ${registerRequstToJson(model)}");


            // ตรวจสอบรหัสสถานะ HTTP
            if (dataPOST.statusCode == 201) {
              // แปลงข้อมูล JSON จากการตอบกลับ
              final responseJson = jsonDecode(dataPOST.body);

              // ตรวจสอบข้อความใน JSON
              if (responseJson['message'] == "User inserted successfully") {
              log("สมัครสำเร็จ");
              // นำทางไปยังหน้า login
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginUser()), // ปรับเป็น LoginPage() ของคุณ
              );
            }  else {
                log("สมัครไม่สำเร็จ: ${dataPOST.body}");
                _showErrorDialog('การลงทะเบียนไม่สำเร็จ');
              }
            } else {
              // ถ้าไม่ใช่ 201 แสดงข้อผิดพลาด
              log("สมัครไม่สำเร็จ: ${dataPOST.body}");
              _showErrorDialog('การลงทะเบียนไม่สำเร็จ');
            }
          } catch (e) {
            log("เกิดข้อผิดพลาด: $e");
            _showErrorDialog('เกิดข้อผิดพลาดในการเชื่อมต่อกับเซิร์ฟเวอร์');
          }
        } else {
          _showErrorDialog('การอัปโหลดรูปภาพไม่สำเร็จ');
        }
      } else {
        _showErrorDialog('กรุณาเลือกรูปภาพก่อนลงทะเบียน');
      }
    } else {
      _showErrorDialog('รหัสผ่านและการยืนยันรหัสผ่านไม่ตรงกัน');
    }
  }

  // แสดง Popup ข้อผิดพลาด
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.red,
          title: Text('เกิดข้อผิดพลาด',
              style: GoogleFonts.kanit(color: Colors.white)),
          content: Text(message, style: GoogleFonts.kanit(color: Colors.white)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child:
                  Text('ตกลง', style: GoogleFonts.kanit(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'ลงทะเบียน'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // รูปโปรไฟล์
            Center(
              child: GestureDetector(
                onTap: _showImageSourceDialog,
                child: _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(75),
                        child: Image.file(
                          File(_image!.path), // แปลง XFile เป็น File
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add_a_photo,
                          color: Colors.grey[700],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 30),

            // ชื่อผู้ใช้
            _buildLabel('ชื่อผู้ใช้'),
            _buildTextField('กรอกชื่อผู้ใช้', TextInputType.name,controller:  _nameController),
            const SizedBox(height: 20),

            // รหัสผ่าน
            _buildLabel('รหัสผ่าน'),
            _buildTextField(
              'กรอกรหัสผ่าน',
              TextInputType.visiblePassword,
              isPassword: true,
              controller: _passwordController,
            ),
            const SizedBox(height: 20),

            // ยืนยันรหัสผ่าน
            _buildLabel('ยืนยันรหัสผ่าน'),
            _buildTextField(
              'กรอกยืนยันรหัสผ่าน',
              TextInputType.visiblePassword,
              isPassword: true,
              controller: _confirmPasswordController,
            ),
            const SizedBox(height: 20),

            // เบอร์โทรศัพท์
            _buildLabel('เบอร์โทรศัพท์'),
            _buildTextField('กรอกเบอร์โทรศัพท์', TextInputType.phone,controller:  _phoneController),
            const SizedBox(height: 20),

            // ที่อยู่
            _buildLabel('ที่อยู่'),
            _buildTextField('กรอกที่อยู่', TextInputType.streetAddress,
                maxLines: 3 ,controller: _addressController),
            const SizedBox(height: 20),

            // ละติจูดและลองจิจูดในแถวเดียวกัน
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('ละติจูด'),
                      _buildTextField(
                        'กรอกละติจูด',
                        TextInputType.number,
                        controller: _latitudeController,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16), // เว้นระยะห่างระหว่างสองช่อง
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('ลองจิจูด'),
                      _buildTextField(
                        'กรอกลองจิจูด',
                        TextInputType.number,
                        controller: _longitudeController,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // ปุ่มเปิดแผนที่
            Center(
              child: SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Gpspage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 162, 13, 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    'เปิดแผนที่',
                    style: GoogleFonts.kanit(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ปุ่มลงทะเบียน
            Center(
              child: SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: _showConfirmationDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 12, 24, 68),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    'ลงทะเบียน',
                    style: GoogleFonts.kanit(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันสร้างข้อความ Label
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: GoogleFonts.kanit(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  // ฟังก์ชันสร้าง TextField
  Widget _buildTextField(
    String hint,
    TextInputType inputType, {
    bool isPassword = false,
    int maxLines = 1,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      obscureText: isPassword,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.kanit(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
