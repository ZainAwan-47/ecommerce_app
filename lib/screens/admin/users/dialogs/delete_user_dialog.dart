import 'package:flutter/material.dart';

import '../../../../models/user_model.dart';
import '../../../../services/user_service.dart';

class DeleteUserDialog extends StatefulWidget {
  const DeleteUserDialog({
    super.key,
    required this.user,
    required this.userService,
  });

  final UserModel user;
  final UserService userService;

  @override
  State<DeleteUserDialog> createState() =>
      _DeleteUserDialogState();
}

class _DeleteUserDialogState
    extends State<DeleteUserDialog> {
  bool _loading = false;

  Future<void> _delete() async {
    setState(() => _loading = true);

    try {
      await widget.userService.deleteUser(
        widget.user.uid,
      );

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "User deleted successfully",
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
    return AlertDialog(
      icon: const Icon(
        Icons.delete_forever,
        color: Colors.red,
        size: 40,
      ),

      title: const Text("Delete User"),

      content: Text(
        "Delete ${widget.user.name}?\n\n"
        "This action cannot be undone.",
      ),

      actions: [
        TextButton(
          onPressed: _loading
              ? null
              : () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),

        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red,
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
              : const Text("Delete"),
        ),
      ],
    );
  }
}