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
          // Profile Avatar Trigger
          GestureDetector(
            onTap: () {
              goToTab(4);
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xff7F4F4F).withOpacity(0.2),
                  width: 1.2,
                ),
              ),
              child: const CircleAvatar(
                radius: 22,
                backgroundColor: Color(0xffF8EEEB),
                child: Icon(
                  Icons.person_rounded,
                  color: Color(0xff7F4F4F),
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Greeting & Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome Back to",
                  style: GoogleFonts.manrope(
                    color: const Color(0xff8D7B7B),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  "Tehreem Store",
                  style: GoogleFonts.manrope(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff2D2323),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),

          /// CART ICON & BADGE
          Builder(
            builder: (context) {
              final user = FirebaseAuth.instance.currentUser;
              
              // Guest Cart Handling
              if (user == null) {
                return GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: Colors.white,
                        surfaceTintColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                        title: Text(
                          "Sign In Required",
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: const Color(0xff2D2323),
                          ),
                        ),
                        content: Text(
                          "Please sign in to access your cart and complete your purchases.",
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            color: const Color(0xff8D7B7B),
                            height: 1.4,
                          ),
                        ),
                        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        actions: [
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    "Cancel",
                                    style: GoogleFonts.manrope(
                                      color: const Color(0xff8D7B7B),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xff7F4F4F),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const LoginScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Sign In",
                                    style: GoogleFonts.manrope(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xff7F4F4F).withOpacity(0.12),
                        width: 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 12,
                          color: Colors.black.withOpacity(0.03),
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.shopping_cart_outlined,
                      size: 19,
                      color: Color(0xff7F4F4F),
                    ),
                  ),
                );
              }

              // Logged In Cart Stream
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
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xff7F4F4F).withOpacity(0.12),
                              width: 0.8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 12,
                                color: Colors.black.withOpacity(0.03),
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.shopping_cart_outlined,
                            size: 19,
                            color: Color(0xff7F4F4F),
                          ),
                        ),
                        if (count > 0)
                          Positioned(
                            right: 4,
                            top: -4,
                            child: Container(
                              width: 18,
                              height: 18,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: Color(0xff7F4F4F),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                count.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.5,
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

          /// NOTIFICATION ICON
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
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xff7F4F4F).withOpacity(0.12),
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 12,
                    color: Colors.black.withOpacity(0.03),
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 19,
                color: Color(0xff7F4F4F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}