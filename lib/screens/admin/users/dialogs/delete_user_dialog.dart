import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../utils/app_notifier.dart';
import '../../../../models/user_model.dart';
import '../../../../services/user_service.dart';

class DeleteUserDialog extends StatefulWidget {
  final UserModel user;
  const DeleteUserDialog({super.key, required this.user});

  @override
  State<DeleteUserDialog> createState() => _DeleteUserDialogState();
}

class _DeleteUserDialogState extends State<DeleteUserDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        "Delete User",
        style: GoogleFonts.manrope(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: const Color(0xff2D2323),
        ),
      ),
      content: Text(
        "Are you sure you want to permanently delete ${widget.user.name}? This action cannot be undone.",
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
            backgroundColor: Colors.red.shade600,
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
                    await UserService().deleteUser(widget.user.uid);
                    if (!mounted) return;
                    Navigator.pop(context);
                    AppNotifier.success(context, "User deleted successfully.");
                  } catch (e) {
                    if (!mounted) return;
                    setState(() => _isLoading = false);
                    AppNotifier.error(context, "Failed to delete user: $e");
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
                  "Delete",
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