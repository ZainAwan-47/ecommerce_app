import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String orderId;
  final String userId;
  final String userName;
  final String email;

  final String phone;
  final String address;

  final List<Map<String, dynamic>> products;

  final double subtotal;
  final double delivery;
  final double total;

  final String paymentMethod;
final String receiptUrl;

/// Legacy status (for current OrdersScreen)
final String status;

/// New payment flow
final String paymentStatus;
  final String orderStatus;

  final bool adminSeen;

  final Timestamp createdAt;
  final Timestamp updatedAt;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.userName,
    required this.email,
    required this.phone,
    required this.address,
    required this.products,
    required this.subtotal,
    required this.delivery,
    required this.total,
    required this.paymentMethod,
required this.receiptUrl,

required this.status,

required this.paymentStatus,
    required this.orderStatus,
    required this.adminSeen,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "orderId": orderId,
      "userId": userId,
      "userName": userName,
      "email": email,
      "phone": phone,
      "address": address,
      "products": products,
      "subtotal": subtotal,
      "delivery": delivery,
      "total": total,
    "paymentMethod": paymentMethod,
"receiptUrl": receiptUrl,

"status": status,

"paymentStatus": paymentStatus,
      "orderStatus": orderStatus,
      "adminSeen": adminSeen,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map["orderId"],
      userId: map["userId"],
      userName: map["userName"],
      email: map["email"],
      phone: map["phone"],
      address: map["address"],
      products: List<Map<String, dynamic>>.from(map["products"]),
      subtotal: (map["subtotal"] as num).toDouble(),
      delivery: (map["delivery"] as num).toDouble(),
      total: (map["total"] as num).toDouble(),
    paymentMethod: map["paymentMethod"],
receiptUrl: map["receiptUrl"],

status: map["status"] ?? "Pending Verification",

paymentStatus: map["paymentStatus"] ?? "Pending",
      orderStatus: map["orderStatus"],
      adminSeen: map["adminSeen"],
      createdAt: map["createdAt"],
      updatedAt: map["updatedAt"],
    );
  }
}