import 'package:flutter/material.dart';

class EmptyUsersWidget extends StatelessWidget {
  const EmptyUsersWidget({
    super.key,
    this.message = "No users found",
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 80,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 20),

            Text(
              message,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium,
            ),

            const SizedBox(height: 8),

            Text(
              "Try changing the search or filter.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}