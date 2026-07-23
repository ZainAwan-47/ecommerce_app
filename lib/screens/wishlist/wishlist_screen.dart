import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_notifier.dart';
import '../../models/product_model.dart';
import '../../services/cart_service.dart';
import '../../services/wishlist_service.dart';
import '../../core/page_controller_holder.dart';
import '../../core/tab_controller.dart';
class WishlistScreen extends StatelessWidget {
  WishlistScreen({super.key});

  final WishlistService wishlistService =
      WishlistService();

  final CartService cartService =
      CartService();  
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
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
   goBackTab();
  },
),
        title: Text(
          "My Wishlist",
 style: GoogleFonts.manrope(            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: wishlistService.getWishlist(),

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
           if (snapshot.hasError) {
  return Center(
    child: Text(
      snapshot.error.toString(),
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.red,
      ),
    ),
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
                    Icons.favorite_border,
                    size: 90,
                    color: Colors.grey.shade400,
                  ),

                  const SizedBox(height: 20),

                 Text(
  "Your Wishlist is Empty",
  style: GoogleFonts.dmSerifDisplay(
    fontSize: 28,
    fontWeight: FontWeight.bold,
  ),
),

                  const SizedBox(height: 10),

                  Text(
                    "Save products you love\nand they'll appear here.",
                    textAlign: TextAlign.center,
  style: GoogleFonts.manrope(                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          final wishlist =
              snapshot.data!.docs;

          return ListView.builder(
padding: EdgeInsets.all(width * 0.028),
            itemCount: wishlist.length,

            itemBuilder: (context, index) {

              final item = wishlist[index];


              return Container(
 margin: EdgeInsets.only(bottom: width * 0.025),
 padding: EdgeInsets.all(width * 0.04),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(.05),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  ),

  child: Row(
    children: [

      ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.network(
          item['image'],
       width: width * 0.17,
height: width * 0.17,
          fit: BoxFit.cover,

          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;

            return SizedBox(
          width: width * 0.17,
  height: width * 0.17,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            );
          },

          errorBuilder: (context, error, stackTrace) {
            return Container(
  width: width * 0.17,
  height: width * 0.17,
              color: const Color(0xffF6F1EE),
              child: const Icon(
                Icons.image_not_supported_outlined,
                color: Colors.grey,
              ),
            );
          },
        ),
      ),

    SizedBox(width: width * 0.03),

      Expanded(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            Text(
              item['name'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
 style: GoogleFonts.manrope(                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Rs ${item['price']}",
  style: GoogleFonts.manrope(                color: const Color(0xff7F4F4F),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
           const SizedBox(height: 4),

Row(
  children: [
    const Icon(
      Icons.star,
      color: Colors.amber,
      size: 18,
    ),

    const SizedBox(width: 5),

   Text(
  item['rating'].toString(),
  style: GoogleFonts.manrope(),
),
  ],
),
const SizedBox(height: 7),

SizedBox(
  width: double.infinity,
 height: width * 0.085,
  child: ElevatedButton.icon(
   onPressed: () async {

  final product = ProductModel(
    id: item.id,
    name: item['name'],
    image: item['image'],
    price: (item['price'] as num).toDouble(),
    oldPrice: (item['oldPrice'] as num).toDouble(),
    rating: (item['rating'] as num).toDouble(),
    category: item['category'],
    description: item['description'],
    featured: item['featured'],
    discount: item['discount'],
    inStock: item['inStock'],
  );

  final added = await cartService.addToCart(
    product,
    1,
  );

  if (!context.mounted) return;

  if (!added) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please sign in."),
      ),
    );
    return;
  }

 if (!context.mounted) return;

AppNotifier.cart(
  context,
  "Added to Cart",
);

await Future.delayed(
  const Duration(milliseconds: 200),
);

await wishlistService.removeFromWishlist(
  item.id,
);
},

    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xff7F4F4F),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),

    icon: const Icon(
      Icons.shopping_cart_outlined,
      color: Colors.white,
      size: 14,
    ),

    label: Text(
      "Add to Cart",
  style: GoogleFonts.manrope(        color: Colors.white,
        fontWeight: FontWeight.w400,
      ),
    ),
  ),
),
          ],
        ),
      ),

      IconButton(
    onPressed: () async {
  if (!context.mounted) return;

  AppNotifier.remove(
    context,
    "Removed from Wishlist",
  );

  await Future.delayed(
    const Duration(milliseconds: 200),
  );

  await wishlistService.removeFromWishlist(
    item.id,
  );
},

        icon: Icon(
          Icons.favorite,
          color: Colors.red,
       size: width * 0.07,
        ),
      ),
    ],
  ),
);
            },
          );
        },
      ),
    );
  }
}