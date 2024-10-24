// To parse this JSON data, do
//
//     final registerRequst = registerRequstFromJson(jsonString);

import 'dart:convert';

RegisterRequst registerRequstFromJson(String str) => RegisterRequst.fromJson(json.decode(str));

String registerRequstToJson(RegisterRequst data) => json.encode(data.toJson());

class RegisterRequst {
    String name;
    String phone;
    String password;
    String img;
    String address;
    String latitude;
    String longitude;

    RegisterRequst({
        required this.name,
        required this.phone,
        required this.password,
        required this.img,
        required this.address,
        required this.latitude,
        required this.longitude,
    });

    factory RegisterRequst.fromJson(Map<String, dynamic> json) => RegisterRequst(
        name: json["name"],
        phone: json["phone"],
        password: json["password"],
        img: json["img"],
        address: json["address"],
        latitude: json["latitude"],
        longitude: json["longitude"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "phone": phone,
        "password": password,
        "img": img,
        "address": address,
        "latitude": latitude,
        "longitude": longitude,
    };
}
