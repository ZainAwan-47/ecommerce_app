import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../offers/offers_screen.dart';
class OfferBanner extends StatelessWidget {
  const OfferBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        height: 240,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xff7F4F4F),
              Color(0xffA56C6C),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff7F4F4F).withOpacity(.25),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            /// Decorative Background Icon
            Positioned(
              right: -30,
              top: -20,
              child: Icon(
                Icons.spa,
                size: 180,
                color: Colors.white.withOpacity(.06),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      "LIMITED OFFER",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.3,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    "20% OFF",
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  SizedBox(
                    width: 190,
                    child: Text(
                      "Luxury skincare & makeup collection",
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),

                  const Spacer(),

                  SizedBox(
                    height: 42,
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
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xff7F4F4F),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                         vertical: 0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        "Shop Now",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
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
    );
  }
}