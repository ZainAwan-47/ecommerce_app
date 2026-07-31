import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../product/products_screen.dart';
import '../../offers/offers_screen.dart';
import '../../../core/page_controller_holder.dart';
import '../../../core/tab_controller.dart';

class OfferBanner extends StatelessWidget {
  const OfferBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("products").snapshots(),
      builder: (context, snapshot) {
        int maxDiscount = 0;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 180,
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xff7F4F4F)),
            ),
          );
        }
        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }
        if (snapshot.hasData) {
          for (final doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final discount = (data["discount"] as num?)?.toInt() ?? 0;
            if (discount > maxDiscount) {
              maxDiscount = discount;
            }
          }
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                constraints: const BoxConstraints(minHeight: 180),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xff6E4747),
                      Color(0xff956767),
                      Color(0xffC89797),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff7F4F4F).withOpacity(0.2),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Stack(
                    children: [
                      // Ambient background light orb for depth
                      Positioned(
                        top: -50,
                        right: -30,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                      ),
                      
                      Padding(
                        padding: EdgeInsets.all(isWide ? 28 : 22),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 7,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Editorial Tag
                                  Text(
                                    maxDiscount == 0 ? "CURATED COLLECTION" : "LIMITED OFFER",
                                    style: GoogleFonts.manrope(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  
                                  // Headline
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        maxDiscount == 0 ? "New Arrivals" : "$maxDiscount%",
                                        style: GoogleFonts.manrope(
                                          color: Colors.white,
                                          fontSize: isWide ? 38 : 32,
                                          height: 0.95,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: -1,
                                        ),
                                      ),
                                      if (maxDiscount > 0)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 6, bottom: 4),
                                          child: Text(
                                            "OFF",
                                            style: GoogleFonts.manrope(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  
                                  // Subtitle description
                                  Text(
                                    maxDiscount == 0
                                        ? "Explore our newest luxury additions crafted for timeless elegance."
                                        : "Exclusive seasonal savings across our premier catalog.",
                                    style: GoogleFonts.manrope(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 13,
                                      height: 1.3,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Action Button
                                  SizedBox(
                                    height: 38,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (maxDiscount > 0) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => const OffersScreen(),
                                            ),
                                          );
                                        } else {
                                          goToTab(1);
                                          appPageController.animateToPage(
                                            1,
                                            duration: const Duration(milliseconds: 320),
                                            curve: Curves.easeOutCubic,
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        backgroundColor: Colors.white,
                                        foregroundColor: const Color(0xff6E4747),
                                        padding: const EdgeInsets.symmetric(horizontal: 20),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            maxDiscount > 0 ? "Claim Offer" : "Have a Look",
                                            style: GoogleFonts.manrope(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 15,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            
                            // Right Editorial Geometric Badge (Shows "SALE" when discounted, "PREMIUM" when new arrivals)
                            Expanded(
                              flex: 3,
                              child: Center(
                                child: SizedBox(
                                  width: 90,
                                  height: 90,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 72,
                                        height: 72,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white.withOpacity(0.1),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.3),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            maxDiscount == 0 ? "PREMIUM" : "SALE",
                                            style: GoogleFonts.manrope(
                                              color: Colors.white,
                                              fontSize: maxDiscount == 0 ? 10 : 13,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}