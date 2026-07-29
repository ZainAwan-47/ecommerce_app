import 'package:flutter/material.dart';
import '../dialogs/change_role_dialog.dart';
import '../../../../models/user_model.dart';
import '../../../../services/user_service.dart';
import '../dialogs/deactivate_user_dialog.dart';
import '../dialogs/delete_user_dialog.dart';
class UserActionButtons extends StatelessWidget {
  const UserActionButtons({
    super.key,
    required this.user,
    required this.userService,
  });

  final UserModel user;
  final UserService userService;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              "Actions",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight:
                        FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(
                  Icons.manage_accounts,
                ),
                label: const Text(
                  "Change Role",
                ),
               onPressed: () {
  showDialog(
    context: context,
    builder: (_) => ChangeRoleDialog(
      user: user,
      userService: userService,
    ),
  );
},
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
  onPressed: () {
    showDialog(
      context: context,
      builder: (_) => DeactivateUserDialog(
        user: user,
        userService: userService,
      ),
    );
  },
  icon: Icon(
    user.isActive
        ? Icons.block
        : Icons.check_circle,
  ),
  label: Text(
    user.isActive
        ? "Deactivate User"
        : "Activate User",
  ),
),
            ),

            const SizedBox(height: 12),

SizedBox(
  width: double.infinity,
  child: FilledButton.tonalIcon(
    style: FilledButton.styleFrom(
      foregroundColor: Colors.red,
    ),
    icon: const Icon(
      Icons.delete_forever,
    ),
    label: const Text("Delete User"),
    onPressed: () {
      showDialog(
        context: context,
        builder: (_) => DeleteUserDialog(
          user: user,
          userService: userService,
        ),
      );
    },
  ),
)
          ],
        ),
      ),
    );
  }
}