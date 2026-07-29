import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../utils/app_notifier.dart';
import '../../../../models/user_model.dart';
import '../../../../services/user_service.dart';

class DeactivateUserDialog extends StatefulWidget {
  final UserModel user;
  const DeactivateUserDialog({super.key, required this.user});

  @override
  State<DeactivateUserDialog> createState() => _DeactivateUserDialogState();
}

class _DeactivateUserDialogState extends State<DeactivateUserDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final bool willActivate = !widget.user.isActive;
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        willActivate ? "Activate User" : "Deactivate User",
        style: GoogleFonts.manrope(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: const Color(0xff2D2323),
        ),
      ),
      content: Text(
        willActivate
            ? "Are you sure you want to activate ${widget.user.name}?"
            : "Are you sure you want to deactivate ${widget.user.name}? They will no longer be able to log in.",
        style: GoogleFonts.manrope(
          fontSize: 14,
          color: const Color(0xff5D4E4E),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(
            "Cancel",
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w600,
              color: const Color(0xff8D7B7B),
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: willActivate ? Colors.green.shade600 : const Color(0xffED6C02), // Using our new orange alert color
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
onPressed: _isLoading
              ? null
              : () async {
                  setState(() => _isLoading = true);
                  try {
                    await UserService().toggleUserStatus(
                      uid: widget.user.uid,
                      isActive: willActivate,
                    );
                    if (!mounted) return;
                    Navigator.pop(context);
                    
                    // Separate notifications based on action
                    if (willActivate) {
                      AppNotifier.success(context, "User activated successfully.");
                    } else {
                      AppNotifier.alert(context, "User deactivated successfully.");
                    }
                  } catch (e) {
                    if (!mounted) return;
                    setState(() => _isLoading = false);
                    AppNotifier.error(context, "Operation failed: $e");
                  }
                },
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  willActivate ? "Activate" : "Deactivate",
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
      ],
    );
  }
}