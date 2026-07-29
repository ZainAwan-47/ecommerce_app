import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../../models/user_model.dart';
import '../../../../services/user_service.dart';

class DeleteUserDialog extends StatefulWidget {
  final UserModel user;
  final UserService userService;

  const DeleteUserDialog({
    super.key,
    required this.user,
    required this.userService,
  });

  @override
  State<DeleteUserDialog> createState() => _DeleteUserDialogState();
}

class _DeleteUserDialogState extends State<DeleteUserDialog> {
  bool _loading = false;

  Future<void> _delete() async {
    setState(() => _loading = true);
    try {
      await widget.userService.deleteUser(widget.user.uid);

      if (!mounted) return;
      Navigator.pop(context); // Close dialog on success
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User deleted successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      // Reset loading state so the dialog remains interactive if an error occurs
      setState(() => _loading = false);

      // Extract precise error message based on exception type
      String errorMessage = "Failed to delete user.";
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
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      icon: const Icon(
        Icons.delete_forever_rounded,
        color: Colors.red,
        size: 45,
      ),
      title: const Text(
        "Delete User",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      content: Text(
        "Delete ${widget.user.name}?\n\nThis action cannot be undone.",
        textAlign: TextAlign.center,
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
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: _loading ? null : _delete,
          child: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  "Delete",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }
}