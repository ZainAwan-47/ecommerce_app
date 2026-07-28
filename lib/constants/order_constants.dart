class OrderStatus {
  static const String pending = 'Pending';
  static const String confirmed = 'Confirmed';
  static const String packed = 'Packed';
  static const String shipped = 'Shipped';
  static const String delivered = 'Delivered';
  static const String cancelled = 'Cancelled';

  static const List<String> values = [
    pending,
    confirmed,
    packed,
    shipped,
    delivered,
    cancelled,
  ];
}

class PaymentStatus {
  static const String pending = 'Pending';
  static const String verified = 'Verified';
  static const String rejected = 'Rejected';
  static const String refunded = 'Refunded';

  static const List<String> values = [
    pending,
    verified,
    rejected,
    refunded,
  ];
}