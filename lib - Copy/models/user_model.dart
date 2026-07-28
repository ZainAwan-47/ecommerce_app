import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String photo;
  final String role;
  final String fcmToken;
  final bool isActive;
  final Timestamp? createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.photo,
    required this.role,
    required this.fcmToken,
    required this.isActive,
    this.createdAt,
  });

  factory UserModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return UserModel(
      uid: id,
      name: map["name"] ?? "",
      email: map["email"] ?? "",
      photo: map["photo"] ?? "",
      role: map["role"] ?? "customer",
      fcmToken: map["fcmToken"] ?? "",
      isActive: map["isActive"] ?? true,
      createdAt: map["createdAt"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "name": name,
      "email": email,
      "photo": photo,
      "role": role,
      "fcmToken": fcmToken,
      "isActive": isActive,
      "createdAt": createdAt,
    };
  }
}