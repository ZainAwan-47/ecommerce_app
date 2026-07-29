import 'package:flutter/material.dart';

class OrderedProductsCard extends StatelessWidget {
  final List<Map<String, dynamic>> products;

  const OrderedProductsCard({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ordered Products',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            if (products.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No products found.',
                  style: theme.textTheme.bodyMedium,
                ),
              )
            else
              ...List.generate(
                products.length,
                (index) {
                  final product = products[index];

                  final image =
                      (product['image'] ?? '').toString();

                  final name =
                      (product['name'] ?? 'Unknown Product')
                          .toString();

                  final quantity =
                      (product['quantity'] ?? 1) as num;

                  final price =
                      (product['price'] ?? 0) as num;

                  final variant =
                      (product['variant'] ?? '').toString();

                  final total = quantity * price;

                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(10),
                            child: image.isNotEmpty
                                ? Image.network(
                                    image,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, __, ___) =>
                                            _placeholder(),
                                  )
                                : _placeholder(),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  maxLines: 2,
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style: theme
                                      .textTheme.titleSmall
                                      ?.copyWith(
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),

                                if (variant.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    variant,
                                    style: theme
                                        .textTheme.bodySmall,
                                  ),
                                ],

                                const SizedBox(height: 8),

                                Text(
                                  "Qty: $quantity × PKR ${price.toStringAsFixed(0)}",
                                  style: theme
                                      .textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 12),

                          Text(
                            "PKR ${total.toStringAsFixed(0)}",
                            style: theme
                                .textTheme.titleSmall
                                ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      if (index != products.length - 1)
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          child: Divider(height: 1),
                        ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey.shade600,
      ),
    );
  }
}