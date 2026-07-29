class AdminModel {
  final String uid;
  final String name;
  final String email;
  final String role;

  const AdminModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  factory AdminModel.fromMap(
    String uid,
    Map<String, dynamic> map,
  ) {
    return AdminModel(
      uid: uid,
      name: map["name"] ?? "",
      email: map["email"] ?? "",
      role: map["role"] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "email": email,
      "role": role,
    };
  }
}