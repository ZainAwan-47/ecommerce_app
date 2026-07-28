import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../utils/app_notifier.dart';

class PaymentMethodCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  final String accountTitle;
  final String accountNumber;
  final String? iban;

  const PaymentMethodCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.accountTitle,
    required this.accountNumber,
    this.iban,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: color.withOpacity(.12),
          child: Icon(
            icon,
            color: color,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            "Tap to view payment details",
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showDetails(context),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                CircleAvatar(
                  radius: 34,
                  backgroundColor: color.withOpacity(.15),
                  child: Icon(
                    icon,
                    size: 34,
                    color: color,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 28),

                _detailTile(
                  context,
                  "Account Title",
                  accountTitle,
                ),

                _detailTile(
                  context,
                  "Account Number",
                  accountNumber,
                ),

                if (iban != null)
                  _detailTile(
                    context,
                    "IBAN",
                    iban!,
                  ),

                const SizedBox(height: 25),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailTile(
    BuildContext context,
    String title,
    String value,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffFFF9F7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              Clipboard.setData(
                ClipboardData(text: value),
              );

             AppNotifier.success(
  context,
  "Copied to clipboard",
);
            },
            icon: const Icon(
              Icons.copy_rounded,
            ),
          ),
        ],
      ),
    );
  }
}