import 'package:flutter/material.dart';

import '../../../../models/user_model.dart';
import '../../../../services/user_service.dart';

class DeactivateUserDialog extends StatefulWidget {
  const DeactivateUserDialog({
    super.key,
    required this.user,
    required this.userService,
  });

  final UserModel user;
  final UserService userService;

  @override
  State<DeactivateUserDialog> createState() =>
      _DeactivateUserDialogState();
}

class _DeactivateUserDialogState
    extends State<DeactivateUserDialog> {
  bool _loading = false;

  Future<void> _toggleStatus() async {
    setState(() => _loading = true);

    try {
    await widget.userService.toggleUserStatus(
  uid: widget.user.uid,
  isActive: !widget.user.isActive,
);

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.user.isActive
                ? "User deactivated successfully"
                : "User activated successfully",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final deactivate = widget.user.isActive;

    return AlertDialog(
      title: Text(
        deactivate
            ? "Deactivate User"
            : "Activate User",
      ),

      content: Text(
        deactivate
            ? "This user won't be able to sign in until activated again."
            : "Allow this user to sign in again?",
      ),

      actions: [
        TextButton(
          onPressed:
              _loading ? null : () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),

        FilledButton(
          onPressed:
              _loading ? null : _toggleStatus,
          child: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  deactivate
                      ? "Deactivate"
                      : "Activate",
                ),
        ),
      ],
    );
  }
}