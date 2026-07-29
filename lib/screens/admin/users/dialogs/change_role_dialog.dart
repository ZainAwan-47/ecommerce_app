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
  State<ChangeRoleDialog> createState() => _ChangeRoleDialogState();
}

class _ChangeRoleDialogState extends State<ChangeRoleDialog> {
  late String _selectedRole;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final role = widget.user.role.toLowerCase();
    _selectedRole = (role == 'admin' || role == 'customer') ? role : 'customer';
  }

  Future<void> _save() async {
    if (_selectedRole == widget.user.role.toLowerCase()) {
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 16),
              SizedBox(width: 8),
              Text(
                "Role updated successfully",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF111827),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
          elevation: 0,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to update role: ${e.toString()}",
            style: const TextStyle(fontSize: 13, color: Colors.white),
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
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
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFF3F4F6), width: 1.5),
      ),
      title: const Text(
        "Change Role",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF111827),
          letterSpacing: -0.3,
        ),
      ),
      content: SizedBox(
        width: 280,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select a new permission level for this user.",
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              isExpanded: true,
              dropdownColor: Colors.white,
              decoration: InputDecoration(
                labelText: "Role",
                labelStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF111827), width: 1.5),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: "admin",
                  child: Text(
                    "Admin",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
                  ),
                ),
                DropdownMenuItem(
                  value: "customer",
                  child: Text(
                    "Customer",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
                  ),
                ),
              ],
              onChanged: _loading
                  ? null
                  : (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedRole = value;
                      });
                    },
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _loading ? null : () => Navigator.pop(context),
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF111827),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Save",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}