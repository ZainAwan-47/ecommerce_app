import '../models/checkout_item.dart';

class BuyNowService {
  static final BuyNowService _instance =
      BuyNowService._internal();

  factory BuyNowService() => _instance;

  BuyNowService._internal();

  CheckoutItem? item;

  void clear() {
    item = null;
  }
}