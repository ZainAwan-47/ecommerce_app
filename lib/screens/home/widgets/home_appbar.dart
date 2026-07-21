import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/tab_controller.dart';
import '../../auth/login_screen.dart';
import '../../cart/cart_screen.dart';
import '../../notification/notification_screen.dart';
import '../../../core/page_controller_holder.dart';
class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
         GestureDetector(
  onTap: () {
  goToTab(4);
  },
  child: const CircleAvatar(
    radius: 24,
    backgroundColor: Color(0xffF0E5E1),
    child: Icon(
      Icons.person,
      color: Color(0xff7F4F4F),
    ),
  ),
),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome Back to",
                  style: GoogleFonts.manrope(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 1),

                Text(
                  "Tehreem Store",
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff3A2B2B),
                  ),
                ),
              ],
            ),
          ),

          /// CART
          Builder(
            builder: (context) {
              final user = FirebaseAuth.instance.currentUser;

              /// Guest
              if (user == null) {
                return GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Sign In Required"),
                        content: const Text(
                          "Please sign in to access your cart.",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            },
                            child: const Text("Sign In"),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    height: 42,
                    width: 42,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.shopping_cart_outlined,
                      size: 21,
                      color: Color(0xff7F4F4F),
                    ),
                  ),
                );
              }

              /// Logged In
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('cart')
                    .snapshots(),
                builder: (context, snapshot) {
                  final count = snapshot.data?.docs.length ?? 0;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CartScreen(),
                        ),
                      );
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: 42,
                          width: 42,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.shopping_cart_outlined,
                            size: 21,
                            color: Color(0xff7F4F4F),
                          ),
                        ),

                        if (count > 0)
                          Positioned(
                            right: 4,
                            top: -4,
                            child: Container(
                              width: 20,
                              height: 20,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                count.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),

          /// Notification
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationScreen(),
                ),
              );
            },
            child: Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 12,
                    color: Colors.black.withOpacity(.04),
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.notifications_none,
                size: 21,
                color: Color(0xff7F4F4F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}