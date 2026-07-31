import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/buy_now_service.dart';
import '../../services/cart_service.dart';
import '../../services/order_service.dart';
import '../../models/checkout_item.dart';
import '../../utils/app_notifier.dart';
import '../payment/payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final CartService _cartService = CartService();
  final OrderService _orderService = OrderService();
  
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  
  bool placingOrder = false;

  @override
  void initState() {
    super.initState();
    loadUserDetails();
  }

  Future<void> loadUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
          
      if (!doc.exists) return;
      final data = doc.data()!;
      if (!mounted) return;
      
      setState(() {
        addressController.text = data['address'] ?? "";
        phoneController.text = data['phoneNumber'] ?? "";
      });
    } catch (_) {}
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
      onPopInvokedWithResult: (didPop, result) {
        BuyNowService().item = null;
      },
      child: Scaffold(
        backgroundColor: const Color(0xffFFF9F7),
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: const Color(0xffFFF9F7),
          surfaceTintColor: Colors.transparent,
          iconTheme: const IconThemeData(
            color: Color(0xff2D2323),
          ),
          title: Text(
            "Checkout",
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xff2D2323),
            ),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _cartService.getCart(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xff7F4F4F),
                ),
              );
            }
            
            final buyNowItem = BuyNowService().item;
            
            if (!snapshot.hasData && buyNowItem == null) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xff7F4F4F),
                ),
              );
            }

            if (snapshot.hasData &&
                snapshot.data!.docs.isEmpty &&
                buyNowItem == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff2D2323),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Add products before checking out.",
                      style: GoogleFonts.manrope(
                        color: const Color(0xff8D7B7B),
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
                  name: data['name'] ?? '',
                  image: data['image'] ?? '',
                  price: (data['price'] as num?)?.toDouble() ?? 0.0,
                  quantity: (data['quantity'] as num?)?.toInt() ?? 1,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Shipping Address",
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff2D2323),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: addressController,
                      maxLines: 3,
                      textInputAction: TextInputAction.next,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        color: const Color(0xff2D2323),
                      ),
                      decoration: InputDecoration(
                        hintText: "Enter your complete address",
                        hintStyle: GoogleFonts.manrope(
                          color: const Color(0xff8D7B7B),
                          fontSize: 14,
                        ),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 45),
                          child: Icon(
                            Icons.location_on_outlined,
                            color: Color(0xff7F4F4F),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xff7F4F4F),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Phone Number",
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff2D2323),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        color: const Color(0xff2D2323),
                      ),
                      decoration: InputDecoration(
                        hintText: "03XXXXXXXXX",
                        hintStyle: GoogleFonts.manrope(
                          color: const Color(0xff8D7B7B),
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.phone_outlined,
                          color: Color(0xff7F4F4F),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xff7F4F4F),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      "Order Summary",
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff2D2323),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Items",
                              style: GoogleFonts.manrope(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xff2D2323),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          ...checkoutItems.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      item.image,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: GoogleFonts.manrope(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: const Color(0xff2D2323),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "Quantity: ${item.quantity}",
                                          style: GoogleFonts.manrope(
                                            fontSize: 13,
                                            color: const Color(0xff8D7B7B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    "Rs ${(item.price * item.quantity).toStringAsFixed(0)}",
                                    style: GoogleFonts.manrope(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xff7F4F4F),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Subtotal",
                                style: GoogleFonts.manrope(
                                  fontSize: 15,
                                  color: const Color(0xff8D7B7B),
                                ),
                              ),
                              Text(
                                "Rs ${subtotal.toStringAsFixed(0)}",
                                style: GoogleFonts.manrope(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xff2D2323),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Delivery",
                                style: GoogleFonts.manrope(
                                  fontSize: 15,
                                  color: const Color(0xff8D7B7B),
                                ),
                              ),
                              Text(
                                delivery == 0 ? "Free" : "Rs ${delivery.toStringAsFixed(0)}",
                                style: GoogleFonts.manrope(
                                  color: delivery == 0
                                      ? Colors.green.shade700
                                      : const Color(0xff2D2323),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Divider(),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total",
                                style: GoogleFonts.manrope(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xff2D2323),
                                ),
                              ),
                              Text(
                                "Rs ${total.toStringAsFixed(0)}",
                                style: GoogleFonts.manrope(
                                  fontSize: 20,
                                  color: const Color(0xff7F4F4F),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      "Next Step",
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff2D2323),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xff7F4F4F).withOpacity(0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            backgroundColor: Color(0xffF5EAEA),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: Color(0xff7F4F4F),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Continue to Payment",
                                  style: GoogleFonts.manrope(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xff2D2323),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Continue to the payment page to complete your order.",
                                  style: GoogleFonts.manrope(
                                    color: const Color(0xff8D7B7B),
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: placingOrder
                            ? null
                            : () async {
                                final address = addressController.text.trim();
                                if (address.length < 10) {
                                  AppNotifier.error(
                                    context,
                                    "Please enter a complete delivery address.",
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
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                      titlePadding:
                                          const EdgeInsets.fromLTRB(24, 24, 24, 8),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 24, vertical: 8),
                                      actionsPadding:
                                          const EdgeInsets.fromLTRB(20, 8, 20, 20),
                                      title: Text(
                                        "Confirm Order",
                                        style: GoogleFonts.manrope(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xff2D2323),
                                        ),
                                      ),
                                      content: Text(
                                        "Are you sure you want to proceed to payment?",
                                        style: GoogleFonts.manrope(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xff8D7B7B),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context, false);
                                          },
                                          child: Text(
                                            "Cancel",
                                            style: GoogleFonts.manrope(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xff8D7B7B),
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xff7F4F4F),
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context, true);
                                          },
                                          child: Text(
                                            "Proceed",
                                            style: GoogleFonts.manrope(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirm != true) return;

                                setState(() {
                                  placingOrder = true;
                                });

                                try {
                                  if (!mounted) return;
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
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(e.toString()),
                                    ),
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      placingOrder = false;
                                    });
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff7F4F4F),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: placingOrder
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.shopping_bag_outlined,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Continue to Payment",
                                    style: GoogleFonts.manrope(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        "By placing your order, you agree to our Terms & Conditions.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                          color: const Color(0xff8D7B7B),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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