import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/tab_controller.dart';
import '../auth/login_screen.dart';
import 'order_details_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
   
if (user == null) {
  return Scaffold(
    backgroundColor: const Color(0xffFFF9F7),

    appBar: AppBar(
      backgroundColor: const Color(0xffFFF9F7),
      elevation: 0,
      centerTitle: true,
     leading: IconButton(
  icon: const Icon(
    Icons.arrow_back_ios_new,
    color: Colors.black,
  ),
 onPressed: () {
  selectedTab.value = previousTab;
},
),

title: Text(
  "My Orders",
  style: GoogleFonts.dmSerifDisplay(
    fontSize: 30,
    fontWeight: FontWeight.bold,
  ),
),
    ),

    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Icon(
              Icons.lock_outline,
              size: 90,
              color: Color(0xff7F4F4F),
            ),

            const SizedBox(height: 20),

            Text(
              "Login Required",
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Please sign in to view your orders.",
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: 220,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                  );
                },
                child: Text(
                  "Login",
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
    return Scaffold(
      backgroundColor: const Color(0xffFFF9F7),

      appBar: AppBar(
        backgroundColor: const Color(0xffFFF9F7),
        elevation: 0,
        centerTitle: true,

       leading: IconButton(
  icon: const Icon(
    Icons.arrow_back_ios_new,
    color: Colors.black,
  ),
  onPressed: () {
    selectedTab.value = previousTab;
  },
),

        title: Text(
          "My Orders",
 style: GoogleFonts.dmSerifDisplay(            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
       stream: FirebaseFirestore.instance
    .collection("orders")
    .where(
      "userId",
      isEqualTo: user!.uid,
    )
    .orderBy(
      "createdAt",
      descending: true,
    )
            .snapshots(),

        builder: (context, snapshot) {
         if (snapshot.hasError) {
  return Center(
    child: Text(snapshot.error.toString()),
  );
}
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
                    Icons.inventory_2_outlined,
                    size: 90,
                    color: Colors.grey.shade400,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "No Orders Yet",
 style: GoogleFonts.dmSerifDisplay(                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Place your first order\nand it will appear here.",
                    textAlign: TextAlign.center,
  style: GoogleFonts.manrope(                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: 220,
                    height: 50,
                    child: ElevatedButton(
                     onPressed: () {
  Navigator.pop(context);
},
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xff7F4F4F),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(15),
                        ),
                      ),
                     child: Text(
  "Continue Shopping",
  style: GoogleFonts.manrope(
    color: Colors.white,
    fontWeight: FontWeight.w600,
  ),
),
                    ),
                  ),
                ],
              ),
            );
          }

          final orders = snapshot.data!.docs;
          return RefreshIndicator(
  color: const Color(0xff7F4F4F),

  onRefresh: () async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    );
  },

  child: ListView.builder(
    padding: const EdgeInsets.all(18),
    itemCount: orders.length,

    itemBuilder: (context, index) {

      final order = orders[index];

      final products =
          order['products'] as List<dynamic>;

      final itemCount = products.length;

      final Timestamp? timestamp =
          order['createdAt'] as Timestamp?;

      final DateTime? date =
          timestamp?.toDate();

      Color statusColor = Colors.orange;

      switch (order['status']) {

        case "Delivered":
          statusColor = Colors.green;
          break;

        case "Cancelled":
          statusColor = Colors.red;
          break;

        case "Processing":
          statusColor = Colors.blue;
          break;

        default:
          statusColor = Colors.orange;
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(18),

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
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Row(
              children: [

                const CircleAvatar(
                  radius: 25,
                  backgroundColor:
                      Color(0xffF5EAEA),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    color: Color(0xff7F4F4F),
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                    Text(
  "Order #${order.id.substring(0, 6).toUpperCase()}",
  style: GoogleFonts.dmSerifDisplay(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
),

                      const SizedBox(height: 4),

                      Text(
                        date == null
                            ? "Just now"
                            : "${date.day}-${date.month}-${date.year} • ${date.hour}:${date.minute.toString().padLeft(2, '0')}",
  style: GoogleFonts.manrope(   
                           color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        statusColor.withOpacity(.15),
                    borderRadius:
                        BorderRadius.circular(30),
                  ),
                  child: Text(
                    order['status'],
  style: GoogleFonts.manrope(                      color: statusColor,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),
            Row(
  children: [

    Expanded(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          Text(
            "$itemCount Item${itemCount > 1 ? "s" : ""}",
  style: GoogleFonts.manrope(   
               color: Colors.grey,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            "Rs ${(order['total'] as num).toStringAsFixed(0)}",
 style: GoogleFonts.dmSerifDisplay(      
          fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xff7F4F4F),
            ),
          ),
        ],
      ),
    ),
  ],
),

const SizedBox(height: 20),

SizedBox(
  width: double.infinity,
  height: 48,
  child: OutlinedButton.icon(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OrderDetailsScreen(
            order: order,
          ),
        ),
      );
    },

    style: OutlinedButton.styleFrom(
      side: const BorderSide(
        color: Color(0xff7F4F4F),
      ),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),
    ),

    icon: const Icon(
      Icons.visibility_outlined,
      color: Color(0xff7F4F4F),
    ),

    label: Text(
  "View Details",
  style: GoogleFonts.manrope(    color: const Color(0xff7F4F4F),
    fontWeight: FontWeight.w600,
  ),
),
  ),
),

          ],
        ),
      );
    },
  ),
);
        },
      ),
    );
  }
}