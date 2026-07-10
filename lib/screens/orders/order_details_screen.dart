import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderDetailsScreen extends StatelessWidget {
  final DocumentSnapshot order;

  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {

    final List products =
        order['products'];

    return Scaffold(
      backgroundColor: const Color(0xffFFF9F7),

      appBar: AppBar(
        backgroundColor: const Color(0xffFFF9F7),
        elevation: 0,
        centerTitle: true,

        title: Text(
          "Order Details",
          style: GoogleFonts.playfairDisplay(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
                        Text(
              "Products",
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            ListView.builder(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),
              itemCount: products.length,

              itemBuilder: (context, index) {

                final product =
                    products[index];

                return Card(
                  margin:
                      const EdgeInsets.only(bottom: 16),

                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(18),
                  ),

                  child: ListTile(

                    leading: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(10),
                      child: Image.network(
                        product['image'],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),

                    title: Text(
                      product['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: Text(
                      "Qty : ${product['quantity']}",
                    ),

                    trailing: Text(
                      "Rs ${product['price']}",
                      style: GoogleFonts.poppins(
                        color:
                            const Color(0xff7F4F4F),
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),
                        Text(
              "Delivery Information",
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [

                      const Icon(
                        Icons.location_on_outlined,
                        color: Color(0xff7F4F4F),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          order['address'],
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [

                      const Icon(
                        Icons.phone_outlined,
                        color: Color(0xff7F4F4F),
                      ),

                      const SizedBox(width: 10),

                      Text(
                        order['phone'],
                        style: GoogleFonts.poppins(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [

                      const Icon(
                        Icons.payments_outlined,
                        color: Color(0xff7F4F4F),
                      ),

                      const SizedBox(width: 10),

                      Text(
                        order['paymentMethod'],
                        style: GoogleFonts.poppins(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [

                      const Icon(
                        Icons.local_shipping_outlined,
                        color: Color(0xff7F4F4F),
                      ),

                      const SizedBox(width: 10),

                      Text(
                        order['status'],
                        style: GoogleFonts.poppins(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 35),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [

                      Text(
                        "Grand Total",
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        "Rs ${(order['total'] as num).toStringAsFixed(0)}",
                        style: GoogleFonts.playfairDisplay(
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

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}