import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../utils/app_notifier.dart';
import 'reject_payment_dialog.dart';

class ReceiptViewerDialog extends StatefulWidget {
  final String imageUrl;
  final String orderId;
  final String userId;

  const ReceiptViewerDialog({
    super.key,
    required this.imageUrl,
    required this.orderId,
    required this.userId,
  });

  @override
  State<ReceiptViewerDialog> createState() => _ReceiptViewerDialogState();
}

class _ReceiptViewerDialogState extends State<ReceiptViewerDialog> {
  bool _isVerifying = false;

  /// Handles approving the payment proof
  Future<void> _verifyPayment() async {
    setState(() => _isVerifying = true);

    try {
      final batch = FirebaseFirestore.instance.batch();

      // 1. Update order payment status
      final orderRef = FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId);

      batch.update(orderRef, {
        'paymentStatus': 'verified',
        'payment_status': 'verified',
        'rejectionReason': FieldValue.delete(),
        'rejection_reason': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2. Add notification for user
      if (widget.userId.isNotEmpty) {
        final notificationRef = FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('notifications')
            .doc();

        batch.set(notificationRef, {
          'title': 'Payment Verified!',
          'body': 'Your payment proof for Order #${widget.orderId.substring(0, 6)} has been approved.',
          'type': 'payment_status',
          'orderId': widget.orderId,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      if (!mounted) return;
      Navigator.pop(context, true);
      AppNotifier.success(context, "Payment verified successfully.");
    } catch (e) {
      if (!mounted) return;
      AppNotifier.error(context, "Failed to verify payment: $e");
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  /// Opens the rejection dialog over the current modal
  Future<void> _openRejectionDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => RejectPaymentDialog(
        orderId: widget.orderId,
        userId: widget.userId,
      ),
    );

    if (result == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Payment Proof",
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Interactive Zoomable Image
            Expanded(
              child: Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: const Color(0xFF7F4F4F),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.broken_image_outlined,
                            color: Colors.grey,
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Failed to load receipt image",
                            style: GoogleFonts.manrope(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Action Bar
            SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                color: Colors.grey.shade900,
                child: Row(
                  children: [
                    // Reject Button
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFDC2626)),
                          foregroundColor: const Color(0xFFDC2626),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isVerifying ? null : _openRejectionDialog,
                        icon: const Icon(Icons.cancel_outlined, size: 18),
                        label: Text(
                          "Reject",
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Verify Button
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isVerifying ? null : _verifyPayment,
                        icon: _isVerifying
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check_circle_outline, size: 18),
                        label: Text(
                          _isVerifying ? "Verifying..." : "Approve",
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
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