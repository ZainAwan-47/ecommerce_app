import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/product_model.dart';
import '../../widgets/product_card_widget.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF9F7),

      appBar: AppBar(
        backgroundColor: const Color(0xffFFF9F7),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Today's Offers",
          style: GoogleFonts.dmSerifDisplay(
            color: Colors.black,
            fontSize: 30,
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("products")
            .where(
              "discount",
              isGreaterThan: 0,
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No Offers Available",
              ),
            );
          }

          final docs = snapshot.data!.docs;
         return ListView.builder(
 padding: const EdgeInsets.symmetric(
  horizontal: 18,
  vertical: 12,
),
  itemCount: docs.length,
  itemBuilder: (context, index) {
    final product =
        ProductModel.fromFirestore(
      docs[index].id,
      docs[index].data()
          as Map<String, dynamic>,
    );

   return Padding(
  padding: const EdgeInsets.only(
    bottom: 18,
  ),
  child: SizedBox(
    height: 340,
    child: ProductCardWidget(
      product: product,
    ),
  ),
);
  },
);
        },
      ),
    );
  }
}