import 'dart:convert';
import 'dart:developer';
import 'dart:io'; // สำหรับการจัดการไฟล์รูปภาพ
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_utilities2/config/config.dart';
import 'package:flutter_utilities2/models/register_rider_req.dart';
import 'package:flutter_utilities2/pages/login_rider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart'; // สำหรับการเลือกหรือถ่ายรูป
import 'package:flutter_utilities2/widgets/appbar.dart';
import 'package:http/http.dart' as http;
class RegisRider extends StatefulWidget {
  const RegisRider({super.key});

  @override
  State<RegisRider> createState() => _RegisRider();
}

class _RegisRider extends State<RegisRider> {
  XFile? _image; // เก็บรูปภาพที่เลือก
  final ImagePicker picker = ImagePicker();
  // ตัวควบคุม TextField สำหรับแต่ละฟิลด์
  final TextEditingController _riderNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
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
          var model = RegisterRiderRequest(
              name: _riderNameController.text,
              phone: _phoneController.text,
              password: _passwordController.text,
              img: imageUrl,
              carRegistration: _licenseController.text
              );

          try {
            var config = await Configuration.getConfig();
            var url = config['apiEndpoint'];

            // ส่งข้อมูลไปยัง API
            final dataPOST = await http.post(
              Uri.parse("$url/rider/register"),
              headers: {"Content-Type": "application/json"},
              body: registerRiderRequestToJson(model),
            );

            log(dataPOST.body);
                log(dataPOST.statusCode.toString());
                print("Model data to send: ${registerRiderRequestToJson(model)}");


            // ตรวจสอบรหัสสถานะ HTTP
            if (dataPOST.statusCode == 201) {
              // แปลงข้อมูล JSON จากการตอบกลับ
              final responseJson = jsonDecode(dataPOST.body);

              // ตรวจสอบข้อความใน JSON
              if (responseJson['message'] == "User inserted successfully") {
              log("สมัครสำเร็จ");
              // นำทางไปยังหน้า login
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginRider()),
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

            // ชื่อไรเดอร์
            _buildLabel('ชื่อไรเดอร์'),
            _buildTextField('กรอกชื่อไรเดอร์',
            TextInputType.name,
             controller: _riderNameController),
            const SizedBox(height: 20),

            // รหัสผ่าน
            _buildLabel('รหัสผ่าน'),
            _buildTextField('กรอกรหัสผ่าน',
            TextInputType.visiblePassword,
             controller: _passwordController, isPassword: true),
            const SizedBox(height: 20),

            // ยืนยันรหัสผ่าน
            _buildLabel('ยืนยันรหัสผ่าน'),
            _buildTextField('กรอกยืนยันรหัสผ่าน',
            TextInputType.visiblePassword,
             controller: _confirmPasswordController, isPassword: true),
            const SizedBox(height: 20),

            // เบอร์โทร
            _buildLabel('เบอร์โทร'),
            _buildTextField('กรอกเบอร์โทร',
            TextInputType.phone,
             controller: _phoneController,),
            const SizedBox(height: 20),

            // ทะเบียนรถ
            _buildLabel('ทะเบียนรถ'),
            _buildTextField('กรอกทะเบียนรถ',
            TextInputType.text,
            controller: _licenseController),
            const SizedBox(height: 40),

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
