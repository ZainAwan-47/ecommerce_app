import 'package:flutter/material.dart';

import 'widgets/home_appbar.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/category_card.dart';
import 'widgets/offer_banner.dart';
import 'widgets/product_card.dart';
import 'widgets/bottom_nav.dart';

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
            children:[
              SizedBox(height: 15),

              /// App Bar
              HomeAppBar(),

              SizedBox(height: 25),

              /// Search Bar
              SearchBarWidget(),

              SizedBox(height: 30),

              /// Categories Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 22),
                child: Text(
                  "Categories",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: 18),

              /// Categories
              CategoryCard(),

              SizedBox(height: 30),

              /// Offer Banner
              OfferBanner(),

              SizedBox(height: 35),

              /// Best Sellers Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 22),
                child: Text(
                  "Best Sellers",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: 18),

              /// Products
              ProductCard(),

              SizedBox(height: 110),
            ],
          ),
        ),
      ),

      /// Bottom Navigation
     bottomNavigationBar: const BottomNav(
  currentIndex: 0,
),
    );
  }
}