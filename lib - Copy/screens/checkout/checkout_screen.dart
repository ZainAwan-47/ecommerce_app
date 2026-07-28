import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/buy_now_service.dart';
import '../../services/cart_service.dart';
import '../../services/order_service.dart';
import '../../models/checkout_item.dart';
import '../../models/product_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/app_notifier.dart';
import '../payment/payment_screen.dart';
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() =>
      _CheckoutScreenState();
}

class _CheckoutScreenState
    extends State<CheckoutScreen> {

  final CartService _cartService = CartService();
  final OrderService _orderService = OrderService();

  final TextEditingController addressController =
      TextEditingController();

  final TextEditingController phoneController =
      TextEditingController();

  bool placingOrder = false;
  bool editingDetails = false;
Future<void> loadUserDetails() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) return;

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();

  if (!doc.exists) return;

  final data = doc.data()!;

  addressController.text =
      data['address'] ?? "";

  phoneController.text =
      data['phoneNumber'] ?? "";
}
@override
void initState() {
  super.initState();
  loadUserDetails();
}
  @override
  void dispose() {
    addressController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
  onPopInvoked: (didPop) {
    BuyNowService().clear();
  },
  child: Scaffold(
      backgroundColor: const Color(0xffFFF9F7),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xffFFF9F7),

        iconTheme: const IconThemeData(
          color: Colors.black,
        ),

        title: Text(
          "Checkout",
          style: GoogleFonts.manrope(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: _cartService.getCart(),

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

final buyNowItem = BuyNowService().item;

if (!snapshot.hasData && buyNowItem == null) {
  return const Center(
    child: CircularProgressIndicator(),
  );
}

if (snapshot.hasData &&
    snapshot.data!.docs.isEmpty &&
    buyNowItem == null){
            return Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [

                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 90,
                    color: Colors.grey.shade400,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "Your Cart is Empty",
                    style: GoogleFonts.manrope(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Add products before checking out.",
  style: GoogleFonts.manrope(                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

List<CheckoutItem> checkoutItems = [];

if (buyNowItem != null) {
  checkoutItems = [buyNowItem];
} else {
  checkoutItems = snapshot.data!.docs.map((doc) {
final data = doc.data() as Map<String, dynamic>;
    return CheckoutItem(
      productId: doc.id,
      name: data['name'],
      image: data['image'],
      price: (data['price'] as num).toDouble(),
      quantity: (data['quantity'] as num).toInt(),
    );
  }).toList();
}
         final subtotal = checkoutItems.fold(
  0.0,
  (sum, item) => sum + item.subtotal,
);

          const delivery = 0.0;

          final total = subtotal + delivery;

       return SafeArea(
  top: false,
  child: SingleChildScrollView(
    padding: const EdgeInsets.all(22),
    child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                                Text(
                  "Shipping Address",
                  style: GoogleFonts.manrope(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 18),

                TextField(
                  controller: addressController,
                  maxLines: 3,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: "Enter your complete address",
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 45),
                      child: Icon(Icons.location_on_outlined),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(
                        color: Color(0xff7F4F4F),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  "Phone Number",
                  style: GoogleFonts.manrope(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 18),

                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: "03XXXXXXXXX",
                    prefixIcon: const Icon(
                      Icons.phone_outlined,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(
                        color: Color(0xff7F4F4F),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                Text(
                  "Order Summary",
                  style: GoogleFonts.manrope(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 18),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.05),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                     const Divider(),

const SizedBox(height: 15),

Align(
  alignment: Alignment.centerLeft,
  child: Text(
    "Items",
    style: GoogleFonts.manrope(
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  ),
),

const SizedBox(height: 15),

...checkoutItems.map(
  (item) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            item.image,
            width: 55,
            height: 55,
            fit: BoxFit.contain,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
  style: GoogleFonts.manrope(                  fontWeight: FontWeight.w600,
                ),
              ),

              Text(
                "Quantity: ${item.quantity}",
  style: GoogleFonts.manrope(                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        Text(
          "Rs ${(item.price * item.quantity).toStringAsFixed(0)}",
  style: GoogleFonts.manrope(            fontWeight: FontWeight.bold,
            color: const Color(0xff7F4F4F),
          ),
        ),
      ],
    ),
  ),
),

const Divider(),

const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                        

                          Text(
                            "Subtotal",
  style: GoogleFonts.manrope(                              fontSize: 16,
                            ),
                          ),

                          Text(
                            "Rs ${subtotal.toStringAsFixed(0)}",
  style: GoogleFonts.manrope(                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [

                          Text(
                            "Delivery",
  style: GoogleFonts.manrope(                              fontSize: 16,
                            ),
                          ),

                          Text(
                            delivery == 0
                                ? "Free"
                                : "Rs ${delivery.toStringAsFixed(0)}",
  style: GoogleFonts.manrope(                              color: Colors.green,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 18,
                        ),
                        child: Divider(),
                      ),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [

                          Text(
                            "Total",
                            style: GoogleFonts.oswald(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            "Rs ${total.toStringAsFixed(0)}",
                            style: GoogleFonts.manrope(
                              fontSize: 24,
                              color: const Color(0xff7F4F4F),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
  const SizedBox(height: 35),
 Text(
  "Next Step",
  style: GoogleFonts.manrope(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 18),

Container(
  padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(.05),
        blurRadius: 15,
        offset: const Offset(0, 8),
      ),
    ],
    border: Border.all(
      color: const Color(0xff7F4F4F).withOpacity(.15),
    ),
  ),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const CircleAvatar(
        radius: 22,
        backgroundColor: Color(0xffF5EAEA),
        child: Icon(
          Icons.arrow_forward_rounded,
          color: Color(0xff7F4F4F),
        ),
      ),

      const SizedBox(width: 16),

      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Continue to Payment",
              style: GoogleFonts.manrope(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "Continue to the payment page to complete your payment.",
              style: GoogleFonts.manrope(
                color: Colors.grey.shade700,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),

                const SizedBox(height: 35),
                                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: placingOrder
                        ? null
                        : () async {

                           final address = addressController.text.trim();

if (address.length < 50) {
  AppNotifier.error(
    context,
    "Please enter a complete delivery address (minimum 50 characters).",
  );
  return;
}

                          final phone = phoneController.text.trim();

if (!RegExp(r'^03\d{9}$').hasMatch(phone)) {
  AppNotifier.error(
    context,
    "Enter a valid phone number (03XXXXXXXXX).",
  );
  return;
}
final confirm = await showDialog<bool>(
  context: context,
  builder: (context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text("Confirm Order"),
      content: const Text(
        "Are you sure you want to place this order?",
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff7F4F4F),
          ),
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: const Text(
            "Place Order",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  },
);

if (confirm != true) {
  return;
}
                            setState(() {
                              placingOrder = true;
                            });

                            try {
setState(() {
  placingOrder = false;
});

 await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => PaymentScreen(
  address: addressController.text.trim(),
  phone: phoneController.text.trim(),
  items: checkoutItems,
  subtotal: subtotal,
  delivery: delivery,
  total: total,
),
  ),
);

return;

                            } catch (e) {

                              setState(() {
                                placingOrder = false;
                              });

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.toString(),
                                  ),
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xff7F4F4F),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                    ),
                    child: placingOrder
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [

                              const Icon(
                                Icons.shopping_bag_outlined,
                                color: Colors.white,
                              ),

                              const SizedBox(width: 10),

                            Text(
  "Place Order",
  style: GoogleFonts.manrope(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  ),
),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 30),
Text(
  "By placing your order, you agree to our Terms & Conditions.",
  textAlign: TextAlign.center,
  style: GoogleFonts.manrope(    color: Colors.grey,
    fontSize: 12,
  ),
),
SizedBox(
  height: MediaQuery.of(context).viewPadding.bottom + 15,
),
                            ],
                          ),
  ),
                        );
                      },
                    ),
                  ),
                );
              }
            }