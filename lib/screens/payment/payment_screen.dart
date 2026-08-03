import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../../models/checkout_item.dart';
import '../../services/order_service.dart';
import '../../utils/app_notifier.dart';
import 'widgets/payment_summary_card.dart';
import 'widgets/payment_method_card.dart';

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
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final ImagePicker picker = ImagePicker();
  final OrderService _orderService = OrderService();
  
  String? selectedPaymentMethodTitle;
  bool placingOrder = false;
  String? receiptImagePath;

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

  void _showRemoveReceiptConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Text(
            "Remove Receipt",
            style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xff2D2323)),
          ),
          content: Text(
            "Are you sure you want to remove the attached receipt?",
            style: GoogleFonts.manrope(fontSize: 14, color: const Color(0xff8D7B7B)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: GoogleFonts.manrope(color: const Color(0xff8D7B7B), fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  receiptImagePath = null;
                });
                AppNotifier.success(context, "Receipt removed.");
              },
              child: Text("Remove", style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _submitOrderFinal() async {
    if (receiptImagePath == null) {
      AppNotifier.error(context, "Please upload your payment receipt to proceed.");
      return;
    }

    setState(() {
      placingOrder = true;
    });

    try {
      final userEmail = FirebaseAuth.instance.currentUser?.email ?? "No Email";
      final userName = FirebaseAuth.instance.currentUser?.displayName ?? "Customer";

      await _orderService.placeManualPaymentOrder(
        userName: userName,
        email: userEmail,
        address: widget.address,
        phone: widget.phone,
        products: widget.items.map((i) => {
          'productId': i.productId,
          'name': i.name,
          'image': i.image,
          'price': i.price,
          'quantity': i.quantity,
        }).toList(),
        subtotal: widget.subtotal,
        delivery: widget.delivery,
        total: widget.total,
        paymentMethod: selectedPaymentMethodTitle ?? "Direct Transfer",
        receipt: File(receiptImagePath!),
      );

      if (!mounted) return;
      AppNotifier.success(context, "Order placed successfully!");
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      AppNotifier.error(context, e.toString().replaceAll("Exception: ", ""));
    } finally {
      if (mounted) {
        setState(() {
          placingOrder = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF9F7),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xffFFF9F7),
        title: Text(
          "Secure Checkout",
          style: GoogleFonts.manrope(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PaymentSummaryCard(
              items: widget.items,
              subtotal: widget.subtotal,
              delivery: widget.delivery,
              total: widget.total,
            ),
            const SizedBox(height: 35),
            Text(
              "Payment Accounts",
              style: GoogleFonts.manrope(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Copy details below to transfer payment, then upload your receipt.",
              style: GoogleFonts.manrope(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('payment_accounts').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xff7F4F4F)));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Text("No payment methods configured by admin yet.", style: GoogleFonts.manrope(color: Colors.grey));
                }

                final accounts = snapshot.data!.docs;
                return Column(
                  children: accounts.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final title = data['title'] ?? 'Payment Method';
                    final isSelected = selectedPaymentMethodTitle == title;
                    final isBank = data['type'] == 'bank';

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedPaymentMethodTitle = title;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: PaymentMethodCard(
                          title: title,
                          icon: isBank ? Icons.account_balance : Icons.account_balance_wallet,
                          color: isSelected ? const Color(0xff7F4F4F) : Colors.grey,
                          accountTitle: data['accountName'] ?? '',
                          accountNumber: data['accountNumber'] ?? '',
                          iban: data['iban'],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 35),
            Text(
              "Upload Payment Receipt",
              style: GoogleFonts.manrope(
                fontSize: 22,
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
                    backgroundColor: const Color(0xff7F4F4F).withOpacity(.08),
                    child: const Icon(
                      Icons.cloud_upload_outlined,
                      size: 38,
                      color: Color(0xff7F4F4F),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    "Upload Receipt",
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "PNG • JPG • JPEG",
                    style: GoogleFonts.manrope(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: pickReceipt,
                      icon: const Icon(Icons.photo_library),
                      label: Text(
                        receiptImagePath == null ? "Choose Receipt" : "Change Receipt",
                        style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  if (receiptImagePath != null) ...[
                    const SizedBox(height: 20),
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.file(
                            File(receiptImagePath!),
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: _showRemoveReceiptConfirmation,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton.icon(
                // Button remains disabled if no receipt is attached or if currently placing order
                onPressed: (receiptImagePath == null || placingOrder) ? null : _submitOrderFinal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff7F4F4F),
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                icon: placingOrder
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.lock_outline, color: Colors.white),
                label: Text(
                  placingOrder ? "Submitting Order..." : "Submit Payment",
                  style: GoogleFonts.manrope(
                    color: receiptImagePath == null ? Colors.grey.shade600 : Colors.white,
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