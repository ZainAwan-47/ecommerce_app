import 'package:flutter/material.dart';
import '../product/products_screen.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/category_card.dart';
import 'widgets/home_appbar.dart';
import 'widgets/offer_banner.dart';
import 'widgets/product_card.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/you_may_like_section.dart';
import '../../../core/tab_controller.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF9F7),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              const HomeAppBar(),

              const SizedBox(height: 18),

              const SearchBarWidget(),

              const SizedBox(height: 22),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Categories",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              CategoryCard(),

              const SizedBox(height: 22),

              const OfferBanner(),

              const SizedBox(height: 24),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Best Sellers",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              ProductCard(),

            const SizedBox(height: 30),

const Padding(
  padding: EdgeInsets.symmetric(horizontal: 16),
  child: Text(
    "You May Also Like",
    style: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  ),
),

const SizedBox(height: 16),

const YouMayLikeSection(),

const SizedBox(height: 20),

Center(
  child: ElevatedButton(
 onPressed: () {
  selectedTab.value = 1;
},
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(160, 48),
      backgroundColor: const Color(0xff7F4F4F),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
    child: const Text("See All"),
  ),
),

const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}