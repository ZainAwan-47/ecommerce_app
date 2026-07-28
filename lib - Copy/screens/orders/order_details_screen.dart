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
final width = MediaQuery.sizeOf(context).width;
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
          style: GoogleFonts.manrope(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),

      body: SingleChildScrollView(
     padding: EdgeInsets.all(width * 0.03),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
                        Text(
              "Products",
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

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
                      const EdgeInsets.only(bottom: 10),

                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                  ),

                  child: ListTile(

                    leading: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(10),
                      child: Image.network(
                        product['image'],
                    width: width * 0.12,
height: width * 0.12,
                        fit: BoxFit.cover,
                      ),
                    ),

                    title: Text(
  product['name'],
  style: GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.w700,
  ),
),

                  subtitle: Text(
  "Qty : ${product['quantity']}",
  style: GoogleFonts.manrope(
    fontSize: 13,
  ),
),

                    trailing: Text(
                      "Rs ${product['price']}",
                      style: GoogleFonts.manrope(
                        color:
                            const Color(0xff7F4F4F),
                      fontSize: 15,
fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 8),
                        Text(
              "Delivery Information",
              style: GoogleFonts.manrope(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            Container(
              width: double.infinity,
padding: EdgeInsets.symmetric(
  horizontal: width * 0.04,
  vertical: width * 0.03,
),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
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
                          style: GoogleFonts.manrope(),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [

                      const Icon(
                        Icons.phone_outlined,
                        color: Color(0xff7F4F4F),
                      ),

                      const SizedBox(width: 10),

                      Text(
                        order['phone'],
                        style: GoogleFonts.manrope(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [

                      const Icon(
                        Icons.payments_outlined,
                        color: Color(0xff7F4F4F),
                      ),

                      const SizedBox(width: 10),

                      Text(
                        order['paymentMethod'],
                        style: GoogleFonts.manrope(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [

                      const Icon(
                        Icons.local_shipping_outlined,
                        color: Color(0xff7F4F4F),
                      ),

                      const SizedBox(width: 10),

                      Text(
                        order['status'],
                        style: GoogleFonts.manrope(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 18),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [

                      Text(
                        "Grand Total",
                        style: GoogleFonts.manrope(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        "Rs ${(order['total'] as num).toStringAsFixed(0)}",
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

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}