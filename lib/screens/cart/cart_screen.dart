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
    final CartService cartService = CartService();

    return Scaffold(
      backgroundColor: const Color(0xffFFF9F7),

      appBar: AppBar(
        backgroundColor: const Color(0xffFFF9F7),
        elevation: 0,
        centerTitle: true,

        title: Text(
          "My Cart",
          style: GoogleFonts.playfairDisplay(
            fontSize: 30,
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
                    size: 90,
                    color: Colors.grey.shade400,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "Your Cart is Empty",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Looks like you haven't\nadded anything yet.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 15,
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
                  padding: const EdgeInsets.all(18),
                  itemCount: cartItems.length,

                  itemBuilder: (context, index) {

                    final item = cartItems[index];

                    return Container(
                      margin: const EdgeInsets.only(
                        bottom: 18,
                      ),

                      padding:
                          const EdgeInsets.all(15),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius:
                            BorderRadius.circular(22),

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
  width: 90,
  height: 90,
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

                          const SizedBox(width: 18),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [

                                Text(
                                  item['name'],
                                  maxLines: 2,
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 21,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  "Rs ${item['price']}",
                                  style: GoogleFonts.poppins(
                                    color:
                                        const Color(0xff7F4F4F),
                                    fontWeight:
                                        FontWeight.w600,
                                    fontSize: 17,
                                  ),
                                ),

                                const SizedBox(height: 14),

                                Row(
                                  children: [

                                    InkWell(
                                      onTap: () {
                                        cartService
                                            .decreaseQuantity(
                                          item.id,
                                        );
                                      },

                                      child: const CircleAvatar(
                                        radius: 15,
                                        backgroundColor:
                                            Color(0xffF3ECE9),
                                        child: Icon(
                                          Icons.remove,
                                          size: 18,
                                          color:
                                              Color(0xff7F4F4F),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 14),

                                    Text(
                                      item['quantity']
                                          .toString(),
                                      style:
                                          GoogleFonts.poppins(
                                        fontWeight:
                                            FontWeight.bold,
                                        fontSize: 17,
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

                                      child: const CircleAvatar(
                                        radius: 15,
                                        backgroundColor:
                                            Color(0xff7F4F4F),
                                        child: Icon(
                                          Icons.add,
                                          size: 18,
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

                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
                            Container(
                margin: const EdgeInsets.all(18),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
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
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                          ),
                        ),

                        Text(
                          "Rs ${subtotal.toStringAsFixed(0)}",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                          ),
                        ),

                        Text(
                          "Free",
                          style: GoogleFonts.poppins(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
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
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text(
                          "Rs ${subtotal.toStringAsFixed(0)}",
                          style: GoogleFonts.playfairDisplay(
                            color: const Color(0xff7F4F4F),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),
                                        SizedBox(
                      width: double.infinity,
                      height: 58,
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
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
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