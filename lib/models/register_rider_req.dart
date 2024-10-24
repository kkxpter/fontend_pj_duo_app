import 'dart:convert';
// To parse this JSON data, do
//
//     final registerRiderRequest = registerRiderRequestFromJson(jsonString);

RegisterRiderRequest registerRiderRequestFromJson(String str) =>
    RegisterRiderRequest.fromJson(json.decode(str));

String registerRiderRequestToJson(RegisterRiderRequest data) =>
    json.encode(data.toJson());

class RegisterRiderRequest {
  String name;
  String phone;
  String password;
  String img;
  String carRegistration;

  RegisterRiderRequest({
    required this.name,
    required this.phone,
    required this.password,
    required this.img,
    required this.carRegistration,
  });

  factory RegisterRiderRequest.fromJson(Map<String, dynamic> json) =>
      RegisterRiderRequest(
        name: json["name"],
        phone: json["phone"],
        password: json["password"],
        img: json["img"],
        carRegistration: json["car_registration"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "phone": phone,
        "password": password,
        "img": img,
        "car_registration": carRegistration,
      };
}