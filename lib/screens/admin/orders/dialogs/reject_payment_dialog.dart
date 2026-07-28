import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../utils/app_notifier.dart';

class RejectPaymentDialog extends StatefulWidget {
  final String orderId;
  final String userId;

  const RejectPaymentDialog({
    super.key,
    required this.orderId,
    required this.userId,
  });

  @override
  State<RejectPaymentDialog> createState() => _RejectPaymentDialogState();
}

class _RejectPaymentDialogState extends State<RejectPaymentDialog> {
  final TextEditingController _reasonController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _presets = [
    "Blurry or unreadable receipt",
    "Payment amount does not match order total",
    "Transaction ID / Reference number missing",
    "Duplicate or invalid payment proof",
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submitRejection() async {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      AppNotifier.error(context, "Please enter or select a rejection reason.");
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final batch = FirebaseFirestore.instance.batch();

      // 1. Update Order document status & rejection reason
      final orderRef = FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId);

      batch.update(orderRef, {
        'paymentStatus': 'rejected',
        'payment_status': 'rejected',
        'rejectionReason': reason,
        'rejection_reason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2. Add notification to user's notifications subcollection
      if (widget.userId.isNotEmpty) {
        final notificationRef = FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('notifications')
            .doc();

        batch.set(notificationRef, {
          'title': 'Payment Verification Rejected',
          'body': 'Reason: $reason. Please upload a valid receipt to proceed.',
          'type': 'payment_status',
          'orderId': widget.orderId,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      if (!mounted) return;
      Navigator.pop(context, true);
      AppNotifier.success(context, "Payment marked as rejected.");
    } catch (e) {
      if (!mounted) return;
      AppNotifier.error(context, "Failed to reject payment: $e");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.gavel_rounded,
                    color: Color(0xFFDC2626),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Reject Payment",
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              "Select or type the reason why this payment proof was rejected. This will be shown directly to the customer.",
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),

            // Quick Preset Chips
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _presets.map((preset) {
                final isSelected = _reasonController.text == preset;
                return ChoiceChip(
                  label: Text(
                    preset,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFFDC2626),
                  backgroundColor: Colors.grey.shade100,
                  onSelected: (selected) {
                    setState(() {
                      _reasonController.text = selected ? preset : '';
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Custom Text Field
            TextField(
              controller: _reasonController,
              maxLines: 3,
              style: GoogleFonts.manrope(fontSize: 14),
              decoration: InputDecoration(
                hintText: "Enter custom reason...",
                hintStyle: GoogleFonts.manrope(
                  color: Colors.grey.shade400,
                  fontSize: 13,
                ),
                filled: true,
                fillColor: const Color(0xFFFFF9F7),
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFDC2626)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Actions
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.manrope(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _isSubmitting ? null : _submitRejection,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            "Confirm Rejection",
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}