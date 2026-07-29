import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../../models/user_model.dart';
import '../../../../services/user_service.dart';

class DeactivateUserDialog extends StatefulWidget {
  final UserModel user;
  final UserService userService;

  const DeactivateUserDialog({
    super.key,
    required this.user,
    required this.userService,
  });

  @override
  State<DeactivateUserDialog> createState() => _DeactivateUserDialogState();
}

class _DeactivateUserDialogState extends State<DeactivateUserDialog> {
  bool _loading = false;

  Future<void> _toggleStatus() async {
    setState(() => _loading = true);
    try {
      final bool willBeActive = !widget.user.isActive;
      await widget.userService.toggleUserStatus(
        uid: widget.user.uid,
        isActive: willBeActive,
      );

      if (!mounted) return;
      Navigator.pop(context); // Close dialog on success

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            willBeActive
                ? "User activated successfully"
                : "User deactivated successfully",
          ),
          backgroundColor: willBeActive ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // Reset loading state safely if an exception occurs
      setState(() => _loading = false);

      // Extract precise error message
      String errorMessage = "Failed to update user status.";
      if (e is FirebaseException) {
        errorMessage = e.message ?? errorMessage;
      } else {
        errorMessage = e.toString().replaceAll("Exception: ", "");
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool deactivate = widget.user.isActive;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        deactivate ? "Deactivate User" : "Activate User",
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      content: Text(
        deactivate
            ? "This user won't be able to sign in until activated again."
            : "Allow this user to sign in again?",
        style: const TextStyle(fontSize: 15, color: Colors.black87),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: deactivate ? Colors.orange : Colors.green,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: _loading ? null : _toggleStatus,
          child: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  deactivate ? "Deactivate" : "Activate",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }
}