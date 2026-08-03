import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../checkout/checkout_screen.dart';
import '../../models/checkout_item.dart';
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

          return StreamBuilder<List<DocumentSnapshot>>(
            stream: _streamAllProductsStock(cartItems),
            builder: (context, stockSnapshot) {
              final Map<String, bool> stockMap = {};
              if (stockSnapshot.hasData) {
                for (var doc in stockSnapshot.data!) {
                  if (doc.exists) {
                    final data = doc.data() as Map<String, dynamic>?;
                    stockMap[doc.id] = data?['inStock'] ?? true;
                  }
                }
              }

              double subtotal = 0.0;
              bool hasInStockItems = false;
              for (var item in cartItems) {
                final productId = item.id;
                final isLiveInStock = stockMap[productId] ?? true;
                if (isLiveInStock) {
                  hasInStockItems = true;
                  subtotal += ((item['price'] ?? 0) as num).toDouble() *
                      ((item['quantity'] ?? 1) as num).toDouble();
                }
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        final productId = item.id;
                        final isLiveInStock = stockMap[productId] ?? true;

                        Widget itemCard = Container(
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
                              Stack(
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
                                        loadingBuilder: (context, child, progress) {
                                          if (progress == null) return child;
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
                                  if (!isLiveInStock)
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          "OUT OF\nSTOCK",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.manrope(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
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
                                    if (!isLiveInStock) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        "Out of stock",
                                        style: GoogleFonts.manrope(
                                          color: Colors.red.shade600,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        InkWell(
                                          borderRadius: BorderRadius.circular(12),
                                          onTap: () async {
                                            await cartService.decreaseQuantity(item.id);
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
                                          onTap: isLiveInStock
                                              ? () {
                                                  cartService.increaseQuantity(item.id);
                                                }
                                              : null,
                                          child: CircleAvatar(
                                            radius: 14,
                                            backgroundColor: isLiveInStock
                                                ? const Color(0xff7F4F4F)
                                                : Colors.grey.shade300,
                                            child: Icon(
                                              Icons.add,
                                              size: 14,
                                              color: isLiveInStock
                                                  ? Colors.white
                                                  : Colors.grey.shade600,
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
                                  await cartService.removeFromCart(item.id);
                                  if (context.mounted) {
                                    AppNotifier.remove(
                                      context,
                                      "Item removed from cart",
                                    );
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

                        if (!isLiveInStock) {
                          return ColorFiltered(
                            colorFilter: const ColorFilter.matrix(<double>[
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0,      0,      0,      1, 0,
                            ]),
                            child: itemCard,
                          );
                        }
                        return itemCard;
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
                              onPressed: (!hasInStockItems)
                                  ? null
                                  : () {
                                      List<CheckoutItem> inStockItems = [];
                                      for (var item in cartItems) {
                                        final productId = item.id;
                                        final isLiveInStock = stockMap[productId] ?? true;
                                        if (isLiveInStock) {
                                          final data = item.data() as Map<String, dynamic>;
                                          inStockItems.add(
                                            CheckoutItem(
                                              productId: productId,
                                              name: data['name'] ?? '',
                                              image: data['image'] ?? '',
                                              price: (data['price'] ?? 0) as double,
                                              quantity: (data['quantity'] ?? 1) as int,
                                            ),
                                          );
                                        }
                                      }

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => CheckoutScreen(
                                            preFilteredItems: inStockItems,
                                          ),
                                        ),
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff7F4F4F),
                                disabledBackgroundColor: Colors.grey.shade300,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                "Proceed to Checkout",
                                style: GoogleFonts.manrope(
                                  color: hasInStockItems
                                      ? Colors.white
                                      : Colors.grey.shade600,
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
          );
        },
      ),
    );
  }

  Stream<List<DocumentSnapshot>> _streamAllProductsStock(
      List<QueryDocumentSnapshot> cartItems) {
    if (cartItems.isEmpty) return Stream.value([]);
    List<Stream<DocumentSnapshot>> streams = cartItems.map((item) {
      return FirebaseFirestore.instance
          .collection('products')
          .doc(item.id)
          .snapshots();
    }).toList();
    return _combineStreams(streams);
  }

  Stream<List<DocumentSnapshot>> _combineStreams(
      List<Stream<DocumentSnapshot>> streams) {
    if (streams.isEmpty) return Stream.value([]);
    late StreamController<List<DocumentSnapshot>> controller;
    List<DocumentSnapshot?> latestValues = List.filled(streams.length, null);
    int activeStreams = streams.length;
    List<StreamSubscription> subscriptions = [];

    controller = StreamController<List<DocumentSnapshot>>(
      onListen: () {
        for (int i = 0; i < streams.length; i++) {
          subscriptions.add(streams[i].listen((snapshot) {
            latestValues[i] = snapshot;
            if (latestValues.every((val) => val != null)) {
              controller.add(latestValues.cast<DocumentSnapshot>());
            }
          }, onError: (error) {
            controller.addError(error);
          }, onDone: () {
            activeStreams--;
            if (activeStreams == 0) {
              controller.close();
            }
          }));
        }
      },
      onCancel: () {
        for (var sub in subscriptions) {
          sub.cancel();
        }
      },
    );

    return controller.stream;
  }
}