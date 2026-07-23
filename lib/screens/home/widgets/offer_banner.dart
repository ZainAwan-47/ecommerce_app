import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../product/products_screen.dart';
import '../../offers/offers_screen.dart';

class OfferBanner extends StatelessWidget {
  const OfferBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection("products")
      .snapshots(),
      builder: (context, snapshot) {
        int maxDiscount = 0;
       if (snapshot.connectionState ==
    ConnectionState.waiting) {
  return const SizedBox(
    height: 187,
    child: Center(
      child: CircularProgressIndicator(),
    ),
  );
}

if (snapshot.hasError) {
  return const SizedBox.shrink();
}
        if (snapshot.hasData) {
          for (final doc in snapshot.data!.docs) {
            final data =
                doc.data() as Map<String, dynamic>;

            final discount =
                (data["discount"] as num?)
                        ?.toInt() ??
                    0;

            if (discount > maxDiscount) {
              maxDiscount = discount;
            }
          }
        }

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
        child:Container(
              height: 193,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(30),
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
                    color: const Color(
                            0xff7F4F4F)
                        .withOpacity(.18),
                    blurRadius: 28,
                    offset:
                        const Offset(0, 12),
                  ),
                ],
              ),

              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(30),
                child: Stack(
                  children: [

                    /// Top glossy light
                    Positioned(
                      top: -70,
                      left: -40,
                      child: Container(
                        width: 250,
                        height: 150,
                        decoration:
                            BoxDecoration(
                          gradient:
                              RadialGradient(
                            colors: [
                              Colors.white
                                  .withOpacity(.22),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    /// Bottom glow
                    Positioned(
                      right: -70,
                      bottom: -70,
                      child: Container(
                        width: 210,
                        height: 210,
                        decoration:
                            BoxDecoration(
                          shape:
                              BoxShape.circle,
                          color: Colors.white
                              .withOpacity(.05),
                        ),
                      ),
                    ),

                    /// Glass chip
                    Positioned(
                      top: 18,
                      left: 18,
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(
                                40),
                        child: BackdropFilter(
                          filter:
                              ImageFilter.blur(
                            sigmaX: 10,
                            sigmaY: 10,
                          ),
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration:
                                BoxDecoration(
                              color: Colors.white
                                  .withOpacity(.14),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          40),
                              border:
                                  Border.all(
                                color: Colors
                                    .white
                                    .withOpacity(
                                        .30),
                              ),
                            ),
                            child: Row(
                              mainAxisSize:
                                  MainAxisSize
                                      .min,
                              children: [
                                const Icon(
                                  Icons
                                      .workspace_premium_rounded,
                                  color:
                                      Colors.white,
                                  size: 15,
                                ),

                                const SizedBox(
                                    width: 6),

                                Text(
                                  "LIMITED OFFER",
                                  style:
                                      GoogleFonts
                                          .manrope(
                                    color: Colors
                                        .white,
                                    fontWeight:
                                        FontWeight
                                            .w800,
                                    fontSize: 11,
                                    letterSpacing:
                                        1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                                        /// Main Content
                                        const SizedBox(height: 16),
                    Positioned.fill(
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(
                          18,
                          50,
                          18,
                          14,
                        ),
                        child: Row(
                          children: [

                            /// Left Side
                            Expanded(
                              flex: 6,
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [

                                  Text(
                                    maxDiscount == 0
                                        ? "NEW ARRIVALS"
                                        : "SAVE UP TO",
                                    style:
                                        GoogleFonts.manrope(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      letterSpacing: 2,
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [

                                      Text(
                                        maxDiscount == 0
                                            ? "Premium"
                                            : "$maxDiscount%",
                                        style:
                                            GoogleFonts
                                                .manrope(
                                          color:
                                              Colors.white,
                                          fontSize: 35,
                                          height: .9,
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),

                                      if (maxDiscount > 0)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(
                                            left: 6,
                                            bottom: 5,
                                          ),
                                          child: Text(
                                            "OFF",
                                            style:
                                                GoogleFonts.manrope(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight:
                                                  FontWeight.w800,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),

                                  const SizedBox(height: 3),

                                  SizedBox(
                                    width: 240,
                                    child: Text(
                                      maxDiscount == 0
                                          ? "Explore our newest premium beauty collection."
                                          : "Exclusive savings on skincare, makeup and fragrances.",
                                      style:
                                          GoogleFonts.manrope(
                                        color: Colors.white
                                            .withOpacity(.92),
                                        fontSize: 12,
                                        height: 1.25,
                                        fontWeight:
                                            FontWeight.w500,
                                      ),
                                    ),
                                  ),

const SizedBox(height: 4),
                               if (maxDiscount > 0)
  SizedBox(
    height: 34,
    child: ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const OffersScreen(),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xff6E4747),
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children:[
          Text(
            "Claim Offer",
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.arrow_forward_rounded,
            size: 16,
          ),
        ],
      ),
    ),
  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 4),

                            /// Right Decoration
                            Expanded(
                              flex: 4,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [

                                  Container(
                                    width: 110,
                                    height: 110,
                                    decoration:
                                        BoxDecoration(
                                      shape:
                                          BoxShape.circle,
                                      color: Colors.white
                                          .withOpacity(.08),
                                    ),
                                  ),

                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration:
                                        BoxDecoration(
                                      shape:
                                          BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white
                                            .withOpacity(.15),
                                        width: 2,
                                      ),
                                    ),
                                  ),

                                  Icon(
                                    Icons.spa_rounded,
                                    size: 68,
                                    color: Colors.white
                                        .withOpacity(.18),
                                  ),

                                  Positioned(
                                    top: 12,
                                    right: 18,
                                    child: Icon(
                                      Icons.auto_awesome,
                                      color: Colors.white
                                          .withOpacity(.45),
                                      size: 16,
                                    ),
                                  ),

                                  Positioned(
                                    bottom: 18,
                                    left: 12,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration:
                                          BoxDecoration(
                                        color: Colors.white
                                            .withOpacity(.35),
                                        shape:
                                            BoxShape.circle,
                                      ),
                                    ),
                                  ),

                                  Positioned(
                                    top: 35,
                                    left: 18,
                                    child: Container(
                                      width: 5,
                                      height: 5,
                                      decoration:
                                          BoxDecoration(
                                        color: Colors.white
                                            .withOpacity(.25),
                                        shape:
                                            BoxShape.circle,
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
                  ],
                ),
              ),
          ),
        );
      },
    );
  }
}