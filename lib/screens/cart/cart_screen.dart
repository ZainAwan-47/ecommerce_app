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
        centerTitle: true,

        title: Text(
          "My Cart",
          style: GoogleFonts.manrope(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: cartService.getCart(),

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [

                  Icon(
                    Icons.shopping_cart_outlined,
                  size: width * 0.18,
                    color: Colors.grey.shade400,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "Your Cart is Empty",
                    style: GoogleFonts.manrope(
                   fontSize: width * 0.065,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Looks like you haven't\nadded anything yet.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      color: Colors.grey,
                   fontSize: width * 0.037,
                    ),
                  ),
                ],
              ),
            );
          }

          final cartItems = snapshot.data!.docs;

          final subtotal =
              cartService.calculateTotal(cartItems);

          return Column(
            children: [

              Expanded(
                child: ListView.builder(
              padding: EdgeInsets.all(width * 0.04),
                  itemCount: cartItems.length,

                  itemBuilder: (context, index) {

                    final item = cartItems[index];

                    return Container(
                    margin: EdgeInsets.only(bottom: width * 0.03),

                  padding: EdgeInsets.symmetric(
  horizontal: width * 0.03,
  vertical: width * 0.018,
),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius:
                         BorderRadius.circular(width * 0.04),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(.05),
                            blurRadius: 15,
                            offset:
                                const Offset(0, 8),
                          ),
                        ],
                      ),

                      child: Row(
                        children: [
                                                      ClipRRect(
                            borderRadius:
                                BorderRadius.circular(18),
                            child: Image.network(
  item['image'],
width: width * 0.16,
height: width * 0.16,
  fit: BoxFit.cover,

  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) {
      return child;
    }

    return const SizedBox(
      width: 90,
      height: 90,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  },

  errorBuilder: (context, error, stackTrace) {
    return Container(
      width: 90,
      height: 90,
      color: const Color(0xffF6F1EE),
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey,
        size: 35,
      ),
    );
  },
),
                          ),

                        SizedBox(width: width * 0.035),

                          Expanded(
                        child: Column(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Text(
                                  item['name'],
                                  maxLines: 2,
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style: GoogleFonts.manrope(
                              fontSize: width * 0.05,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                          SizedBox(height: width * 0.008),

                                Text(
                                  "Rs ${item['price']}",
  style: GoogleFonts.manrope(                                    color:
                                        const Color(0xff7F4F4F),
                                    fontWeight:
                                        FontWeight.w600,
                                fontSize: width * 0.042,
                                  ),
                                ),

                       SizedBox(height: width * 0.012),

                                Row(
                                  children: [

                                    InkWell(
onTap: () async {
  final removed = await cartService.decreaseQuantity(item.id);

  if (!context.mounted) return;

  if (removed) {
    AppNotifier.remove(
      context,
      "Item removed from cart",
    );
  }
},
                                      child: CircleAvatar(
                                      radius: width * 0.032,
                                        backgroundColor:
                                            Color(0xffF3ECE9),
                                        child: Icon(
                                          Icons.remove,
                                        size: width * 0.04,
                                          color:
                                              Color(0xff7F4F4F),
                                        ),
                                      ),
                                    ),

                                 SizedBox(width: width * 0.025),

                                    Text(
                                      item['quantity']
                                          .toString(),
 style: GoogleFonts.manrope(
  fontSize: width * 0.042,
  fontWeight: FontWeight.bold,
),
                                    ),

                                    const SizedBox(width: 14),

                                    InkWell(
                                      onTap: () {
                                        cartService
                                            .increaseQuantity(
                                          item.id,
                                        );
                                      },

                                    child: CircleAvatar(
  radius: width * 0.032,
                                        backgroundColor:
                                            Color(0xff7F4F4F),
                                        child: Icon(
                                          Icons.add,
                                     size: width * 0.04,
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
        title: const Text("Remove Item"),
        content: const Text(
          "Are you sure you want to remove this item from your cart?",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text("Delete"),
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
                              Icons.delete_outline,
                              color: Colors.red,
                          size: width * 0.06,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
                            Container(
            margin: EdgeInsets.all(width * 0.04),
            padding: EdgeInsets.all(width * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
             borderRadius: BorderRadius.circular(width * 0.05),
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

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [

                        Text(
                          "Subtotal",
  style: GoogleFonts.manrope(                            fontSize: 14,
                          ),
                        ),

                        Text(
                          "Rs ${subtotal.toStringAsFixed(0)}",
  style: GoogleFonts.manrope(                            fontWeight: FontWeight.bold,
                            fontSize: 14,
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
  style: GoogleFonts.manrope(                            fontSize: 14,
                          ),
                        ),

                        Text(
                          "Free",
  style: GoogleFonts.manrope(                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
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
                          style: GoogleFonts.manrope(
                        fontSize: width * 0.055,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text(
                          "Rs ${subtotal.toStringAsFixed(0)}",
                          style: GoogleFonts.manrope(
                            color: const Color(0xff7F4F4F),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),
                                        SizedBox(
                      width: double.infinity,
                  height: width * 0.12,
                      child: ElevatedButton(
                        onPressed: cartItems.isEmpty? null
                       : () {
                       Navigator.push(
                          context,
                        MaterialPageRoute(
                         builder: (_) => CheckoutScreen(),
                           ),
                          );
                       },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff7F4F4F),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          "Proceed to Checkout",
  style: GoogleFonts.manrope(                            color: Colors.white,
                          fontSize: width * 0.043,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}