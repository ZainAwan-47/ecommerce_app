import 'package:flutter/material.dart';

import '../../models/checkout_item.dart';

import 'widgets/payment_summary_card.dart';
import 'widgets/payment_method_card.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class PaymentScreen extends StatefulWidget {
  final String address;
  final String phone;

  final List<CheckoutItem> items;

  final double subtotal;
  final double delivery;
  final double total;

  const PaymentScreen({
    super.key,
    required this.address,
    required this.phone,
    required this.items,
    required this.subtotal,
    required this.delivery,
    required this.total,
  });

  @override
  State<PaymentScreen> createState() =>
      _PaymentScreenState();
}

class _PaymentScreenState
    extends State<PaymentScreen> {

final ImagePicker picker = ImagePicker();
String? selectedPaymentMethod;

bool uploadingReceipt = false;

bool placingOrder = false;

String? receiptImagePath;

String? receiptDownloadUrl;

Future<void> pickReceipt() async {

  final image = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 80,
  );

  if (image == null) return;

  setState(() {
    receiptImagePath = image.path;
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF9F7),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xffFFF9F7),
        title: const Text(
          "Secure Checkout",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            /// PAYMENT SUMMARY

            PaymentSummaryCard(
              items: widget.items,
              subtotal: widget.subtotal,
              delivery: widget.delivery,
              total: widget.total,
            ),

            const SizedBox(height: 35),

            const Text(
              "Choose Payment Method",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            PaymentMethodCard(
              title: "Meezan Bank",
              icon: Icons.account_balance,
              color: const Color(0xff7F4F4F),
              accountTitle: "Shop by Tehreem",
              accountNumber: "03XX XXXXXXX",
              iban:
                  "PK36MEZN0001234567890123",
            ),

            PaymentMethodCard(
              title: "Easypaisa",
              icon:
                  Icons.account_balance_wallet,
              color: Colors.green,
              accountTitle: "Shop by Tehreem",
              accountNumber: "03XX XXXXXXX",
            ),

            PaymentMethodCard(
              title: "JazzCash",
              icon:
                  Icons.account_balance_wallet,
              color: Colors.red,
              accountTitle: "Shop by Tehreem",
              accountNumber: "03XX XXXXXXX",
            ),

            const SizedBox(height: 35),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(.05),
                    blurRadius: 15,
                    offset:
                        const Offset(0, 8),
                  ),
                ],
              ),
              child: const Row(
                children: [

                  Icon(
                    Icons.info_outline,
                    color: Color(0xff7F4F4F),
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      "Choose any ONE payment method above. "
                      "After making payment you'll upload "
                      "the receipt for verification.",
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),

           const Text(
  "Upload Payment Receipt",
  style: TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 18),

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(22),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(22),
    border: Border.all(
      color: const Color(0xff7F4F4F).withOpacity(.15),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(.05),
        blurRadius: 15,
        offset: const Offset(0, 8),
      ),
    ],
  ),
  child: Column(
    children: [

      CircleAvatar(
        radius: 38,
        backgroundColor:
            const Color(0xff7F4F4F).withOpacity(.08),
        child: const Icon(
          Icons.cloud_upload_outlined,
          size: 38,
          color: Color(0xff7F4F4F),
        ),
      ),

      const SizedBox(height: 18),

      const Text(
        "Upload Receipt",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 8),

      const Text(
        "PNG • JPG • JPEG",
        style: TextStyle(
          color: Colors.grey,
        ),
      ),

      const SizedBox(height: 22),

    Column(
  children: [

    SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: pickReceipt,
        icon: const Icon(Icons.photo_library),
        label: const Text(
          "Choose Receipt",
        ),
      ),
    ),

    if (receiptImagePath != null) ...[

      const SizedBox(height: 20),

      ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.file(
          File(receiptImagePath!),
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),

      const SizedBox(height: 15),

      TextButton.icon(
        onPressed: pickReceipt,
        icon: const Icon(Icons.refresh),
        label: const Text(
          "Replace Receipt",
        ),
      ),

    ],

  ],
),
    ],
  ),
),
const SizedBox(height: 35),

const Text(
  "Instructions",
  style: TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 18),

Container(
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(22),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(.05),
        blurRadius: 15,
        offset: const Offset(0, 8),
      ),
    ],
  ),
  child: const Column(
    children: [

      Row(
        children: [

          Icon(
            Icons.looks_one,
            color: Color(0xff7F4F4F),
          ),

          SizedBox(width: 12),

          Expanded(
            child: Text(
              "Transfer the exact order amount.",
            ),
          ),
        ],
      ),

      SizedBox(height: 18),

      Row(
        children: [

          Icon(
            Icons.looks_two,
            color: Color(0xff7F4F4F),
          ),

          SizedBox(width: 12),

          Expanded(
            child: Text(
              "Take a screenshot after successful payment.",
            ),
          ),
        ],
      ),

      SizedBox(height: 18),

      Row(
        children: [

          Icon(
            Icons.looks_3,
            color: Color(0xff7F4F4F),
          ),

          SizedBox(width: 12),

          Expanded(
            child: Text(
              "Upload the payment receipt before submitting.",
            ),
          ),
        ],
      ),

      SizedBox(height: 18),

      Row(
        children: [

          Icon(
            Icons.looks_4,
            color: Color(0xff7F4F4F),
          ),

          SizedBox(width: 12),

          Expanded(
            child: Text(
              "Our admin will verify your payment before processing your order.",
            ),
          ),
        ],
      ),
    ],
  ),
),

const SizedBox(height: 35),

Container(
  padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(
    color: const Color(0xffFFF4E5),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: Colors.orange.shade300,
    ),
  ),
  child: const Row(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [

      Icon(
        Icons.verified_user_outlined,
        color: Colors.orange,
      ),

      SizedBox(width: 12),

      Expanded(
        child: Text(
          "Payments are verified manually. Your order will start processing after payment approval.",
          style: TextStyle(
            height: 1.5,
          ),
        ),
      ),
    ],
  ),
),

const SizedBox(height: 35),

SizedBox(
  width: double.infinity,
  height: 58,
  child: ElevatedButton.icon(
  onPressed: receiptImagePath == null
    ? null
    : () {
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text(
      "Receipt selected successfully. Upload integration will be enabled after Firebase Storage setup.",
    ),
  ),
);

    },
    style: ElevatedButton.styleFrom(
      backgroundColor:
          const Color(0xff7F4F4F),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(18),
      ),
    ),
    icon: const Icon(
      Icons.lock_outline,
      color: Colors.white,
    ),
    label: const Text(
      "Submit Payment",
      style: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),

const SizedBox(height: 40),

          ],
        ),
      ),
    );
  }
}