class OrderModel {
  final String orderId;
  final String userId;

  final String userName;
  final String email;
  final String phone;
  final String address;

  final List<dynamic> products;

  final double subtotal;
  final double delivery;
  final double total;

  final String paymentMethod;
  final String status;

  final String? receiptUrl;

  final DateTime? createdAt;

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
    required this.status,
    this.receiptUrl,
    this.createdAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map["orderId"] ?? "",
      userId: map["userId"] ?? "",
      userName: map["userName"] ?? "",
      email: map["email"] ?? "",
      phone: map["phone"] ?? "",
      address: map["address"] ?? "",
      products: List<dynamic>.from(map["products"] ?? []),
      subtotal: (map["subtotal"] ?? 0).toDouble(),
      delivery: (map["delivery"] ?? 0).toDouble(),
      total: (map["total"] ?? 0).toDouble(),
      paymentMethod: map["paymentMethod"] ?? "",
      status: map["status"] ?? "Pending",
      receiptUrl: map["receiptUrl"],
      createdAt: map["createdAt"] != null
          ? (map["createdAt"] as Timestamp).toDate()
          : null,
    );
  }

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
      "status": status,
      "receiptUrl": receiptUrl,
      "createdAt": createdAt,
    };
  }
}