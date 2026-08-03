import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecommerce_app/screens/auth/login_screen.dart';
import '../../../utils/app_notifier.dart';
import '../../profile/change_password_screen.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  // Store Profile Controllers
  final TextEditingController storeNameController = TextEditingController();
  final TextEditingController supportEmailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // Operational Toggles
  bool maintenanceMode = false;
  bool orderAlerts = true;
  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('settings')
          .doc('general')
          .get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (!mounted) return;
        setState(() {
          storeNameController.text = data['storeName'] ?? "Shop by Tehreem";
          supportEmailController.text =
              data['supportEmail'] ?? "support@shopbytehreem.com";
          phoneController.text = data['supportPhone'] ?? "03475614133";
          maintenanceMode = data['maintenanceMode'] ?? false;
          orderAlerts = data['orderAlerts'] ?? true;
          loading = false;
        });
      } else {
        storeNameController.text = "Shop by Tehreem";
        supportEmailController.text = "support@shopbytehreem.com";
        phoneController.text = "03475614133";
        if (!mounted) return;
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> _saveSettings() async {
    setState(() {
      saving = true;
    });
    try {
      await FirebaseFirestore.instance
          .collection('settings')
          .doc('general')
          .set({
        'storeName': storeNameController.text.trim(),
        'supportEmail': supportEmailController.text.trim(),
        'supportPhone': phoneController.text.trim(),
        'maintenanceMode': maintenanceMode,
        'orderAlerts': orderAlerts,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (!mounted) return;
      AppNotifier.success(context, "Store settings updated successfully.");
    } catch (e) {
      if (!mounted) return;
      AppNotifier.error(context, "Error saving settings: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    storeNameController.dispose();
    supportEmailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminEmail =
        FirebaseAuth.instance.currentUser?.email ?? "admin@shopbytehreem.com";
    return Scaffold(
      backgroundColor: const Color(0xffFFF9F7),
      appBar: AppBar(
        backgroundColor: const Color(0xffFFF9F7),
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xff2D2323)),
        title: Text(
          "Store Settings",
          style: GoogleFonts.manrope(
            color: const Color(0xff2D2323),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xff7F4F4F)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Admin Profile Header Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: Color(0xff7F4F4F),
                          child: Icon(
                            Icons.admin_panel_settings_outlined,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Store Administrator",
                                style: GoogleFonts.manrope(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xff2D2323),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                adminEmail,
                                style: GoogleFonts.manrope(
                                  fontSize: 13,
                                  color: const Color(0xff8D7B7B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // SECTION 1: Store Branding & Profile
                  Text(
                    "Store Profile & Branding",
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff7F4F4F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: storeNameController,
                          style: GoogleFonts.manrope(
                              fontSize: 14, color: const Color(0xff2D2323)),
                          decoration: InputDecoration(
                            labelText: "Store Name",
                            labelStyle: GoogleFonts.manrope(
                                color: const Color(0xff8D7B7B), fontSize: 13),
                            prefixIcon: const Icon(Icons.storefront_outlined,
                                color: Color(0xff7F4F4F), size: 20),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: supportEmailController,
                          style: GoogleFonts.manrope(
                              fontSize: 14, color: const Color(0xff2D2323)),
                          decoration: InputDecoration(
                            labelText: "Support Email",
                            labelStyle: GoogleFonts.manrope(
                                color: const Color(0xff8D7B7B), fontSize: 13),
                            prefixIcon: const Icon(Icons.email_outlined,
                                color: Color(0xff7F4F4F), size: 20),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          style: GoogleFonts.manrope(
                              fontSize: 14, color: const Color(0xff2D2323)),
                          decoration: InputDecoration(
                            labelText: "Customer Support Phone",
                            labelStyle: GoogleFonts.manrope(
                                color: const Color(0xff8D7B7B), fontSize: 13),
                            prefixIcon: const Icon(Icons.phone_outlined,
                                color: Color(0xff7F4F4F), size: 20),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // SECTION 2: Operations Control
                  Text(
                    "Operations Control",
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff7F4F4F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SwitchListTile(
                      title: Text(
                        "Store Maintenance Mode",
                        style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff2D2323)),
                      ),
                      subtitle: Text(
                        "Temporarily disable checkouts for store updates",
                        style: GoogleFonts.manrope(
                            fontSize: 12, color: const Color(0xff8D7B7B)),
                      ),
                      activeColor: Colors.redAccent,
                      activeTrackColor: Colors.redAccent.withOpacity(0.3),
                      value: maintenanceMode,
                      onChanged: (val) {
                        setState(() {
                          maintenanceMode = val;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  // SECTION 3: Security & Notifications
                  Text(
                    "Security & Alerts",
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff7F4F4F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.lock_reset_outlined,
                              color: Color(0xff7F4F4F)),
                          title: Text(
                            "Change Password",
                            style: GoogleFonts.manrope(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xff2D2323)),
                          ),
                          subtitle: Text(
                            "Update your admin account password",
                            style: GoogleFonts.manrope(
                                fontSize: 12, color: const Color(0xff8D7B7B)),
                          ),
                          trailing: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: Colors.grey),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ChangePasswordScreen()),
                            );
                          },
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        SwitchListTile(
                          title: Text(
                            "New Order Alerts",
                            style: GoogleFonts.manrope(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xff2D2323)),
                          ),
                          subtitle: Text(
                            "Get notified instantly when an order is placed",
                            style: GoogleFonts.manrope(
                                fontSize: 12, color: const Color(0xff8D7B7B)),
                          ),
                          activeColor: const Color(0xff7F4F4F),
                          activeTrackColor:
                              const Color(0xff7F4F4F).withOpacity(0.3),
                          value: orderAlerts,
                          onChanged: (val) {
                            setState(() {
                              orderAlerts = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Save Changes Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff7F4F4F),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: saving ? null : _saveSettings,
                      child: saving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              "Save Changes",
                              style: GoogleFonts.manrope(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Logout Button with Modern Confirmation Dialog
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Colors.redAccent, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () async {
                        final shouldLogout = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              surfaceTintColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              contentPadding:
                                  const EdgeInsets.fromLTRB(24, 24, 24, 24),
                              title: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xff7F4F4F)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(
                                      Icons.logout_rounded,
                                      color: Color(0xff7F4F4F),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Text(
                                    "Sign Out",
                                    style: GoogleFonts.manrope(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                      color: const Color(0xff2D2323),
                                    ),
                                  ),
                                ],
                              ),
                              content: Text(
                                "Are you sure you want to log out of your account?",
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  color: const Color(0xff8D7B7B),
                                  height: 1.4,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              actionsPadding:
                                  const EdgeInsets.fromLTRB(24, 0, 24, 24),
                              actions: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context, false);
                                        },
                                        child: Text(
                                          "Cancel",
                                          style: GoogleFonts.manrope(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: const Color(0xff8D7B7B),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xff7F4F4F),
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context, true);
                                        },
                                        child: Text(
                                          "Logout",
                                          style: GoogleFonts.manrope(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        );
                        if (shouldLogout == true) {
                          await FirebaseAuth.instance.signOut();
                          if (!context.mounted) return;
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                          AppNotifier.success(
                              context, "Logged out successfully.");
                        }
                      },
                      child: Text(
                        "Log Out",
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}