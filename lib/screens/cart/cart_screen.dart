import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../checkout/checkout_screen.dart';
import '../../services/cart_service.dart';
import '../../utils/app_notifier.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final CartService cartService = CartService();

    return Scaffold(
      backgroundColor: const Color(0xffFFF9F7),
      appBar: AppBar(
        backgroundColor: const Color(0xffFFF9F7),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          "My Cart",
          style: GoogleFonts.manrope(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xff2D2323),
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xff2D2323),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: cartService.getCart(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xff7F4F4F),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 72,
                    color: const Color(0xff8D7B7B).withOpacity(0.4),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Your Cart is Empty",
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 24,
                      color: const Color(0xff2D2323),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Looks like you haven't\nadded anything yet.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      color: const Color(0xff8D7B7B),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          final cartItems = snapshot.data!.docs;
          final subtotal = cartService.calculateTotal(cartItems);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.08),
                          width: 0.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xff7F4F4F).withOpacity(0.04),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: 75,
                              height: 75,
                              color: const Color(0xffFFF9F7),
                              child: Image.network(
                                item['image'] ?? '',
                                fit: BoxFit.contain,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      color: Color(0xff7F4F4F),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      color: Color(0xff8D7B7B),
                                      size: 28,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'] ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.manrope(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xff2D2323),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Rs ${item['price']}",
                                  style: GoogleFonts.manrope(
                                    color: const Color(0xff7F4F4F),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () async {
                                        final removed = await cartService
                                            .decreaseQuantity(item.id);
                                        if (!context.mounted) return;
                                        if (removed) {
                                          AppNotifier.remove(
                                            context,
                                            "Item removed from cart",
                                          );
                                        }
                                      },
                                      child: CircleAvatar(
                                        radius: 14,
                                        backgroundColor: const Color(0xffF3ECE9),
                                        child: const Icon(
                                          Icons.remove,
                                          size: 14,
                                          color: Color(0xff7F4F4F),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Text(
                                        item['quantity'].toString(),
                                        style: GoogleFonts.manrope(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xff2D2323),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () {
                                        cartService.increaseQuantity(item.id);
                                      },
                                      child: CircleAvatar(
                                        radius: 14,
                                        backgroundColor: const Color(0xff7F4F4F),
                                        child: const Icon(
                                          Icons.add,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              final shouldDelete = await showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    titlePadding: const EdgeInsets.fromLTRB(
                                      24,
                                      24,
                                      24,
                                      8,
                                    ),
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 8,
                                    ),
                                    actionsPadding:
                                        const EdgeInsets.fromLTRB(
                                      20,
                                      8,
                                      20,
                                      20,
                                    ),
                                    title: Text(
                                      "Remove Item",
                                      style: GoogleFonts.manrope(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xff2D2323),
                                      ),
                                    ),
                                    content: Text(
                                      "Are you sure you want to remove this item from your cart?",
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
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
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
                                            horizontal: 20,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context, true);
                                        },
                                        child: Text(
                                          "Delete",
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

                              if (shouldDelete == true) {
                                await cartService.removeFromCart(item.id);
                                if (context.mounted) {
                                  AppNotifier.remove(
                                    context,
                                    "Item removed from cart",
                                  );
                                }
                              }
                            },
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.red.shade400,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SafeArea(
                top: false,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.black.withOpacity(0.08),
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff7F4F4F).withOpacity(0.04),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Subtotal",
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              color: const Color(0xff8D7B7B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "Rs ${subtotal.toStringAsFixed(0)}",
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
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
                              fontSize: 14,
                              color: const Color(0xff8D7B7B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "Free",
                            style: GoogleFonts.manrope(
                              color: Colors.green.shade600,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Divider(height: 1),
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
                            "Rs ${subtotal.toStringAsFixed(0)}",
                            style: GoogleFonts.manrope(
                              color: const Color(0xff7F4F4F),
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: cartItems.isEmpty
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const CheckoutScreen(),
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff7F4F4F),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            "Proceed to Checkout",
                            style: GoogleFonts.manrope(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}