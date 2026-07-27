import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/cart_service.dart';
import '../../models/product_model.dart';
import '../auth/login_screen.dart';
import '../../services/wishlist_service.dart';
import '../../utils/app_notifier.dart';
import '../../services/buy_now_service.dart';
import '../checkout/checkout_screen.dart';
import '../../models/checkout_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState
    extends State<ProductDetailsScreen> {
      int currentImage = 0;

final PageController _pageController = PageController();

  int quantity = 1;
final CartService _cartService = CartService();
final WishlistService _wishlistService = WishlistService();
  @override
  Widget build(BuildContext context) {
final width = MediaQuery.sizeOf(context).width;
    final product = widget.product;

    return Scaffold(
      backgroundColor: const Color(0xffFFF9F7),

    body: SafeArea(
  top: false,
  child: CustomScrollView(
    slivers: [

          SliverAppBar(
        expandedHeight: width * 0.75,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,

            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),

            actions: [

             StreamBuilder<bool>(
  stream: _wishlistService.isWishlisted(product.id),
  builder: (context, snapshot) {
    final isWishlisted = snapshot.data ?? false;

    return CircleAvatar(
      backgroundColor: Colors.white,
      child: IconButton(
        icon: Icon(
          isWishlisted
              ? Icons.favorite
              : Icons.favorite_border,
          color: Colors.redAccent,
        ),
       onPressed: () async {
  final wasWishlisted = isWishlisted;

  final success = await _wishlistService.toggleWishlist(
    product,
  );

  if (!mounted) return;

  if (!success) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Sign In Required"),
        content: const Text(
          "Please sign in to use Wishlist.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
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
    return;
  }

  if (wasWishlisted) {
    AppNotifier.remove(
      context,
      "Removed from Wishlist",
    );
  } else {
    AppNotifier.wishlist(
      context,
      "Added to Wishlist",
    );
  }
},
      ),
    );
  },
),

              const SizedBox(width: 10),

           CircleAvatar(
  backgroundColor: Colors.white,
  child: IconButton(
    icon: const Icon(
      Icons.share,
      color: Colors.black87,
    ),
   onPressed: () {
  final productLink =
      "https://shopbytehreem.com/products/${product.id}";

  SharePlus.instance.share(
    ShareParams(
      subject: product.name,
      text: '''
Shop by Tehreem

${product.name}

Price: Rs ${product.price.toStringAsFixed(0)}
Rating: ${product.rating}/5

${product.description}

View Product
$productLink

Download the Shop by Tehreem App
https://shopbytehreem.com
''',
    ),
  );
},
  ),
),

              const SizedBox(width: 14),
            ],

            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
  children: [

    Container(color: Colors.white),

    Center(
      child: Hero(
        tag: product.id,
        child: Padding(
          padding: EdgeInsets.only(
            top: width * 0.12,
            left: width * 0.08,
            right: width * 0.08,
            bottom: width * 0.03,
          ),
          child: PageView.builder(
            controller: _pageController,
            itemCount: product.images.length,
            onPageChanged: (index) {
              setState(() {
                currentImage = index;
              });
            },
            itemBuilder: (context, index) {
              return Image.network(
                product.images[index],
                fit: BoxFit.contain,
                loadingBuilder: (
                  context,
                  child,
                  progress,
                ) {
                  if (progress == null) return child;

                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return const Icon(
                    Icons.image_not_supported,
                    size: 100,
                  );
                },
              );
            },
          ),
        ),
      ),
    ), // <-- Center ends here

    Positioned(
      bottom: 12,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          product.images.length,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: currentImage == index ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: currentImage == index
                  ? const Color(0xff7F4F4F)
                  : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    ),

          if (product.discount > 0)
  Positioned(
 top: width * 0.24,
left: width * 0.04,
right: width * 0.04,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            "${product.discount}% OFF",
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        if (product.featured)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              "Featured",
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontWeight: FontWeight.w600,
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

          SliverToBoxAdapter(
            child: Padding(
         padding: EdgeInsets.all(width * 0.045),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Text(
                    "Shop by Tehreem",
  style: GoogleFonts.manrope(                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),

           SizedBox(height: width * 0.012),

                  Text(
                    product.name,
 style: GoogleFonts.manrope(                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                SizedBox(height: width * 0.03),

                  Row(
                    children: [

                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),

                      const SizedBox(width: 6),

                      Text(
                        product.rating.toString(),
  style: GoogleFonts.manrope(                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                       color: product.inStock
    ? Colors.green.shade100
    : Colors.red.shade100,
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                       child: Text(
  product.inStock ? "In Stock" : "Out of Stock",
  style: GoogleFonts.manrope(
    color: product.inStock ? Colors.green : Colors.red,
    fontWeight: FontWeight.w600,
  ),
),
                      ),
                    ],
                  ),

                SizedBox(height: width * 0.04),
                  Row(
                    children: [

                    Text(
  "Rs ${product.price.toStringAsFixed(0)}",
  style: GoogleFonts.manrope(
    color: const Color(0xff7F4F4F),
    fontWeight: FontWeight.bold,
    fontSize: 28,
  ),
),

                      const SizedBox(width: 12),

                  if (product.discount > 0)
  Text(
    "Rs ${product.oldPrice.toStringAsFixed(0)}",
    style: GoogleFonts.manrope(
      decoration: TextDecoration.lineThrough,
      color: Colors.grey,
    ),
  ),
                    ],
                  ),

                 SizedBox(height: width * 0.045),
                                    Container(
padding: EdgeInsets.all(width * 0.04),
                    decoration: BoxDecoration(
                      color: Colors.white,
             borderRadius: BorderRadius.circular(width * 0.05),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Description",
 style: GoogleFonts.manrope(                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                      SizedBox(height: width * 0.02),

                        Text(
                          product.description,
  style: GoogleFonts.manrope(                            fontSize: 14,
                            height: 1.7,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

               SizedBox(height: width * 0.045),

                 Text(
  "Quantity",
 style: GoogleFonts.manrope(    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 18),

Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    IconButton(
      onPressed: () {
        if (quantity > 1) {
          setState(() {
            quantity--;
          });
        }
      },
      icon: const Icon(Icons.remove_circle_outline),
    ),

    Text(
      quantity.toString(),
  style: GoogleFonts.manrope(       fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    ),

    IconButton(
      onPressed: () {
        setState(() {
          quantity++;
        });
      },
      icon: const Icon(Icons.add_circle_outline),
    ),
  ],
),

const SizedBox(height: 30),

SizedBox(
  width: double.infinity,
  height: width * 0.13,
  child: ElevatedButton(
    onPressed: () async {
      final added = await _cartService.addToCart(
        product,
        quantity,
      );

      if (!mounted) return;

      if (!added) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Sign In Required"),
            content: const Text(
              "Please sign in to add products to your cart.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
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
        return;
      }

      AppNotifier.cart(
  context,
  "Added to Cart",
);
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xff7F4F4F),
      shape: RoundedRectangleBorder(
     borderRadius: BorderRadius.circular(width * 0.04),
      ),
    ),
    child: Text(
      "Add to Cart",
  style: GoogleFonts.manrope(        fontSize: 14,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
),
                SizedBox(height: width * 0.025),

                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: OutlinedButton(
onPressed: () {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
    return;
  }

  BuyNowService().item = CheckoutItem(
    productId: product.id,
    name: product.name,
    image: product.image,
    price: product.price,
    quantity: quantity,
  );

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const CheckoutScreen(),
    ),
  );
},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xff7F4F4F),
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        "Buy Now",
  style: GoogleFonts.manrope(                       fontSize: 14,
                          color: const Color(0xff7F4F4F),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                 SizedBox(height: width * 0.06),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}