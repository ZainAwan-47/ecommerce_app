import 'package:flutter/material.dart';

import '../../../../models/user_model.dart';
import '../../../../services/user_service.dart';

class ChangeRoleDialog extends StatefulWidget {
  const ChangeRoleDialog({
    super.key,
    required this.user,
    required this.userService,
  });

  final UserModel user;
  final UserService userService;

  @override
  State<ChangeRoleDialog> createState() =>
      _ChangeRoleDialogState();
}

class _ChangeRoleDialogState
    extends State<ChangeRoleDialog> {

  late String _selectedRole;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.user.role;
  }

  Future<void> _save() async {
    if (_selectedRole == widget.user.role) {
      Navigator.pop(context);
      return;
    }

    setState(() => _loading = true);

    try {
      await widget.userService.updateUserRole(
        widget.user.uid,
        _selectedRole,
      );

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text("Role updated successfully"),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Change Role"),

      content: DropdownButtonFormField<String>(
        value: _selectedRole,
        decoration: const InputDecoration(
          labelText: "Role",
        ),
        items: const [
          DropdownMenuItem(
            value: "admin",
            child: Text("Admin"),
          ),
          DropdownMenuItem(
            value: "customer",
            child: Text("Customer"),
          ),
        ],
        onChanged: (value) {
          if (value == null) return;

          setState(() {
            _selectedRole = value;
          });
        },
      ),

      actions: [
        TextButton(
          onPressed: _loading
              ? null
              : () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),

        FilledButton(
          onPressed:
              _loading ? null : _save,
          child: _loading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text("Save"),
        ),
      ],
    );
  }
}