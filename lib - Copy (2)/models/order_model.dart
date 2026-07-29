import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/order_constants.dart';

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
    required this.paymentStatus,
    required this.orderStatus,
    required this.adminSeen,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Computes total quantity of items across all products in this order
  int get itemCount {
    return products.fold<int>(
      0,
      (sum, item) => sum + ((item['quantity'] ?? 1) as num).toInt(),
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
      "receiptUrl": receiptUrl,
      "paymentStatus": paymentStatus,
      "orderStatus": orderStatus,
      "adminSeen": adminSeen,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map["orderId"] ?? "",
      userId: map["userId"] ?? "",
      userName: map["userName"] ?? "",
      email: map["email"] ?? "",
      phone: map["phone"] ?? "",
      address: map["address"] ?? "",

      // Defensive list parsing to handle nested Map dynamic types safely
      products: (map["products"] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),

      subtotal: ((map["subtotal"] ?? 0) as num).toDouble(),
      delivery: ((map["delivery"] ?? 0) as num).toDouble(),
      total: ((map["total"] ?? 0) as num).toDouble(),

      paymentMethod: map["paymentMethod"] ?? "",
      receiptUrl: map["receiptUrl"] ?? "",

      paymentStatus: map["paymentStatus"] ?? PaymentStatus.pending,
      orderStatus: map["orderStatus"] ?? OrderStatus.pending,

      adminSeen: map["adminSeen"] ?? false,

      createdAt: map["createdAt"] is Timestamp
          ? map["createdAt"]
          : Timestamp.now(),
      updatedAt: map["updatedAt"] is Timestamp
          ? map["updatedAt"]
          : Timestamp.now(),
    );
  }

  /// Instantiates model directly from a Firestore DocumentSnapshot
  factory OrderModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    // Ensures orderId falls back to document ID if omitted or empty
    if ((data['orderId'] as String?)?.isEmpty ?? true) {
      data['orderId'] = doc.id;
    }
    return OrderModel.fromMap(data);
  }

  /// Creates a copy of [OrderModel] with updated fields
  OrderModel copyWith({
    String? orderId,
    String? userId,
    String? userName,
    String? email,
    String? phone,
    String? address,
    List<Map<String, dynamic>>? products,
    double? subtotal,
    double? delivery,
    double? total,
    String? paymentMethod,
    String? receiptUrl,
    String? paymentStatus,
    String? orderStatus,
    bool? adminSeen,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return OrderModel(
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      products: products ?? this.products,
      subtotal: subtotal ?? this.subtotal,
      delivery: delivery ?? this.delivery,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      orderStatus: orderStatus ?? this.orderStatus,
      adminSeen: adminSeen ?? this.adminSeen,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'OrderModel(orderId: $orderId, status: $orderStatus, total: $total)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderModel && other.orderId == orderId;
  }

  @override
  int get hashCode => orderId.hashCode;
}