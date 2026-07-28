import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CustomerInfoCard extends StatelessWidget {
  final dynamic order; // Accepts OrderModel, Map, or DocumentSnapshot

  const CustomerInfoCard({super.key, required this.order});

  /// Helper to convert OrderModel / DocumentSnapshot / Map into a unified Map
  Map<String, dynamic> _getMapData() {
    if (order == null) return {};

    if (order is Map<String, dynamic>) {
      return order as Map<String, dynamic>;
    }

    if (order is DocumentSnapshot) {
      final data = (order as DocumentSnapshot).data();
      return (data is Map<String, dynamic>) ? data : {};
    }

    // Handle OrderModel object via dynamic property reading / toMap
    try {
      final dyn = order as dynamic;
      
      // Try toMap() if it exists on OrderModel
      try {
        final map = dyn.toMap();
        if (map is Map<String, dynamic>) return map;
      } catch (_) {}

      // Fallback: Read OrderModel properties directly
      return {
        'userName': dyn.userName ?? dyn.name ?? dyn.customerName,
        'userEmail': dyn.userEmail ?? dyn.email ?? dyn.customerEmail,
        'phone': dyn.phone ?? dyn.phoneNumber,
        'userId': dyn.userId ?? dyn.user_id,
      };
    } catch (_) {
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderData = _getMapData();

    final String? directName = orderData['userName'] ??
        orderData['name'] ??
        orderData['customerName'];
    final String? directEmail = orderData['userEmail'] ??
        orderData['email'] ??
        orderData['customerEmail'];
    final String phone =
        orderData['phone'] ?? orderData['phoneNumber'] ?? 'N/A';
    final String userId = orderData['userId'] ?? orderData['user_id'] ?? '';

    final bool hasName = directName != null && directName.trim().isNotEmpty;
    final bool hasEmail = directEmail != null && directEmail.trim().isNotEmpty;

    // 1. If name & email exist directly on the order, display immediately
    if (hasName && hasEmail) {
      return _buildCardContent(
        name: directName!,
        email: directEmail!,
        phone: phone,
      );
    }

    // 2. If missing and no userId available to query
    if (userId.isEmpty) {
      return _buildCardContent(
        name: directName ?? 'Guest User',
        email: directEmail ?? 'No email available',
        phone: phone,
      );
    }

    // 3. Fallback: Query users collection for missing name/email
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        String resolvedName = directName ?? '';
        String resolvedEmail = directEmail ?? '';

        if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
          final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};

          if (resolvedName.isEmpty) {
            resolvedName = userData['name'] ??
                userData['userName'] ??
                userData['fullName'] ??
                '';
          }

          if (resolvedEmail.isEmpty) {
            resolvedEmail =
                userData['email'] ?? userData['userEmail'] ?? '';
          }
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          if (resolvedName.isEmpty) resolvedName = 'Loading...';
          if (resolvedEmail.isEmpty) resolvedEmail = 'Loading...';
        }

        if (resolvedName.isEmpty) resolvedName = 'N/A';
        if (resolvedEmail.isEmpty) resolvedEmail = 'N/A';

        return _buildCardContent(
          name: resolvedName,
          email: resolvedEmail,
          phone: phone,
        );
      },
    );
  }

  Widget _buildCardContent({
    required String name,
    required String email,
    required String phone,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE4E6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Customer Information",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.person_outline_rounded,
            label: "Name",
            value: name,
          ),
          const Divider(height: 20, color: Color(0xFFFFE4E6)),
          _buildInfoRow(
            icon: Icons.email_outlined,
            label: "Email",
            value: email,
          ),
          const Divider(height: 20, color: Color(0xFFFFE4E6)),
          _buildInfoRow(
            icon: Icons.phone_outlined,
            label: "Phone",
            value: phone,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF64748B)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: value == 'Loading...'
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}