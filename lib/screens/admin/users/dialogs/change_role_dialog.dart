import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../utils/app_notifier.dart';
import '../../../../models/user_model.dart';
import '../../../../services/user_service.dart';

class ChangeRoleDialog extends StatefulWidget {
  final UserModel user;
  const ChangeRoleDialog({super.key, required this.user});

  @override
  State<ChangeRoleDialog> createState() => _ChangeRoleDialogState();
}

class _ChangeRoleDialogState extends State<ChangeRoleDialog> {
  bool _isLoading = false;
  late String _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.user.role.toLowerCase();
    if (_selectedRole != 'admin' && _selectedRole != 'customer') {
      _selectedRole = 'customer';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Icon & Subtitle
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xff7F4F4F).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    color: Color(0xff7F4F4F),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Change User Role",
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: const Color(0xff2D2323),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.user.name,
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff8D7B7B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Dropdown Field
            Text(
              "Select Permission Level",
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xff8D7B7B),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              dropdownColor: Colors.white,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xff7F4F4F)),
              items: [
                DropdownMenuItem(
                  value: 'customer',
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline_rounded, size: 18, color: Color(0xff8D7B7B)),
                      const SizedBox(width: 10),
                      Text("Customer", style: GoogleFonts.manrope(fontWeight: FontWeight.w600, color: const Color(0xff2D2323))),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'admin',
                  child: Row(
                    children: [
                      const Icon(Icons.verified_user_outlined, size: 18, color: Color(0xff7F4F4F)),
                      const SizedBox(width: 10),
                      Text("Admin", style: GoogleFonts.manrope(fontWeight: FontWeight.w600, color: const Color(0xff2D2323))),
                    ],
                  ),
                ),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedRole = val);
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xffFFF9F7),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xff7F4F4F), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: const Color(0xff8D7B7B),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff7F4F4F),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoading
                        ? null
                        : () async {
                            setState(() => _isLoading = true);
                            try {
                              await UserService().updateUserRole(widget.user.uid, _selectedRole);
                              if (!mounted) return;
                              Navigator.pop(context);
                              AppNotifier.success(context, "User role updated successfully.");
                            } catch (e) {
                              if (!mounted) return;
                              setState(() => _isLoading = false);
                              AppNotifier.error(context, "Failed to update role: $e");
                            }
                          },
                    child: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            "Save Changes",
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Colors.white,
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