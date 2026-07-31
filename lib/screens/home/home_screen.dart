import 'package:flutter/material.dart';
import '../product/products_screen.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/category_card.dart';
import 'widgets/home_appbar.dart';
import 'widgets/offer_banner.dart';
import 'widgets/product_card.dart';
import '../../core/page_controller_holder.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/you_may_like_section.dart';
import '../../core/filter_controller.dart';
import '../../../core/tab_controller.dart';
import '../../core/page_controller_holder.dart';
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

           ValueListenableBuilder<String?>(
  valueListenable: selectedCategory,
  builder: (context, category, _) {
    return ValueListenableBuilder<double>(
      valueListenable: maxPrice,
      builder: (context, price, _) {
        String title = "Best Sellers";

        if (category != null) {
          title = "$category Products";
        } else if (price < 9999) {
          title = "Products Under Rs ${price.toInt()}";
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  },
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
 goToTab(1);

  appPageController.animateToPage(
    1,
    duration: const Duration(milliseconds: 320),
    curve: Curves.easeOutCubic,
  );
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

const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}