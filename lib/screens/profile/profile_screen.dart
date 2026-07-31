import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'change_password_screen.dart';
import '../orders/orders_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../auth/login_screen.dart';
import '../main/main_screen.dart';
import '../home/widgets/bottom_nav.dart';
import '../../core/page_controller_holder.dart';
import '../../core/tab_controller.dart';
import '../../utils/app_notifier.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? profileImage;
  String? photoUrl;
  bool uploading = false;

  @override
  void initState() {
    super.initState();
    nameController.text = user?.displayName ?? "";
    loadProfile();
  }

  Future<void> loadProfile() async {
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    if (!doc.exists) return;
    final data = doc.data()!;
    setState(() {
      photoUrl = data['photoUrl'];
      nameController.text = data['displayName'] ?? user?.displayName ?? "";
      phoneController.text = data['phoneNumber'] ?? "";
      addressController.text = data['address'] ?? "";
    });
  }

  Future<void> pickProfileImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked == null) return;
      setState(() {
        uploading = true;
        profileImage = File(picked.path);
      });
      final storageRef = FirebaseStorage.instance
          .ref()
          .child("profile_images")
          .child("${user!.uid}.jpg");
      final uploadTask = await storageRef.putFile(profileImage!);
      final url = await uploadTask.ref.getDownloadURL();
      await FirebaseFirestore.instance.collection("users").doc(user!.uid).set({
        "photoUrl": url,
        "displayName": nameController.text.trim(),
        "email": user!.email,
        "phoneNumber": phoneController.text.trim(),
        "address": addressController.text.trim(),
      }, SetOptions(merge: true));
      setState(() {
        photoUrl = url;
        uploading = false;
      });
      if (!mounted) return;
      AppNotifier.success(context, "Profile picture updated successfully.");
    } catch (e) {
      setState(() {
        uploading = false;
      });
      if (!mounted) return;
      AppNotifier.error(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isEmailUser = user?.providerData.any(
          (provider) => provider.providerId == "password",
        ) ??
        false;

    return Scaffold(
      backgroundColor: const Color(0xffFFF9F7),
      appBar: AppBar(
        backgroundColor: const Color(0xffFFF9F7),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xff2D2323),
          ),
          onPressed: () {
            goToTab(0);
          },
        ),
        title: Text(
          "My Profile",
          style: GoogleFonts.manrope(
            fontSize: width * 0.055,
            fontWeight: FontWeight.bold,
            color: const Color(0xff2D2323),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(width * 0.05),
        child: Column(
          children: [
            const SizedBox(height: 8),
            GestureDetector(
              onTap: pickProfileImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: width * 0.11,
                    backgroundColor: const Color(0xff7F4F4F),
                    backgroundImage: profileImage != null
                        ? FileImage(profileImage!)
                        : photoUrl != null
                            ? NetworkImage(photoUrl!)
                            : null,
                    child: profileImage == null && photoUrl == null
                        ? Text(
                            user?.email?.substring(0, 1).toUpperCase() ?? "U",
                            style: GoogleFonts.manrope(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  if (uploading)
                    const Positioned.fill(
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xff7F4F4F),
                        ),
                      ),
                    ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xff7F4F4F),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: width * 0.055,
                fontWeight: FontWeight.bold,
                color: const Color(0xff2D2323),
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Your Name",
                hintStyle: GoogleFonts.manrope(
                  color: Colors.grey,
                  fontSize: width * 0.045,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              user?.email ?? "No Email",
              style: GoogleFonts.manrope(
                color: const Color(0xff8D7B7B),
                fontSize: width * 0.038,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              style: GoogleFonts.manrope(color: const Color(0xff2D2323)),
              decoration: InputDecoration(
                labelText: "Phone Number",
                labelStyle: GoogleFonts.manrope(color: const Color(0xff8D7B7B)),
                hintText: "03XXXXXXXXX",
                hintStyle: GoogleFonts.manrope(color: Colors.grey.shade400),
                prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xff7F4F4F)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xff7F4F4F), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: addressController,
              minLines: 2,
              maxLines: 3,
              style: GoogleFonts.manrope(color: const Color(0xff2D2323)),
              decoration: InputDecoration(
                labelText: "Delivery Address",
                labelStyle: GoogleFonts.manrope(color: const Color(0xff8D7B7B)),
                hintText: "House, Street, Area, City",
                hintStyle: GoogleFonts.manrope(color: Colors.grey.shade400),
                prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xff7F4F4F)),
                alignLabelWithHint: true,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xff7F4F4F), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff7F4F4F),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () async {
                  final newName = nameController.text.trim();
                  final phone = phoneController.text.trim();
                  final address = addressController.text.trim();
                  if (phone.isNotEmpty &&
                      !RegExp(r'^03\d{9}$').hasMatch(phone)) {
                    AppNotifier.error(
                      context,
                      "Enter a valid phone number (03XXXXXXXXX).",
                    );
                    return;
                  }
                  if (address.isNotEmpty && address.length < 10) {
                    AppNotifier.error(
                      context,
                      "Please enter a complete address.",
                    );
                    return;
                  }
                  await user?.updateDisplayName(newName);
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user!.uid)
                      .set({
                    'displayName': newName,
                    'email': user!.email,
                    'phoneNumber': phoneController.text.trim(),
                    'address': addressController.text.trim(),
                  }, SetOptions(merge: true));
                  if (!mounted) return;
                  AppNotifier.success(
                    context,
                    "Profile Updated Successfully",
                  );
                  FocusScope.of(context).unfocus();
                  setState(() {});
                },
                icon: const Icon(Icons.save_outlined, size: 18),
                label: Text(
                  "Save Profile",
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildTile(
              context: context,
              icon: Icons.shopping_bag_outlined,
              title: "My Orders",
              onTap: () {
                goToTab(3);
              },
            ),
            _buildTile(
              context: context,
              icon: Icons.favorite_outline,
              title: "Wishlist",
              onTap: () {
                goToTab(2);
              },
            ),
            if (isEmailUser)
              _buildTile(
                context: context,
                icon: Icons.lock_outline,
                title: "Change Password",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen(),
                    ),
                  );
                },
              ),
            _buildTile(
              context: context,
              icon: Icons.support_agent,
              title: "Contact Us",
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: "Shop by Tehreem",
                  applicationVersion: "1.0.0",
                  children: const [
                    Text("Need help? Contact us anytime."),
                  ],
                );
              },
            ),
            _buildTile(
              context: context,
              icon: Icons.info_outline,
              title: "About App",
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: "Shop by Tehreem",
                  applicationVersion: "1.0.0",
                  applicationLegalese: "© 2026 Shop by Tehreem",
                );
              },
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xff7F4F4F),
                  elevation: 0,
                  side: BorderSide(color: const Color(0xff7F4F4F).withOpacity(0.3), width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
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
                        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                        title: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xff7F4F4F).withOpacity(0.1),
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
                        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        actions: [
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
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
                                    backgroundColor: const Color(0xff7F4F4F),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
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
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  }
                },
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: Text(
                  "Logout",
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Version 1.0.0",
              style: GoogleFonts.manrope(
                color: const Color(0xff8D7B7B),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(width * 0.04),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        dense: true,
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: 2,
        ),
        leading: Icon(
          icon,
          size: width * 0.055,
          color: const Color(0xff7F4F4F),
        ),
        title: Text(
          title,
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w600,
            fontSize: width * 0.038,
            color: const Color(0xff2D2323),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: width * 0.04,
          color: const Color(0xff8D7B7B),
        ),
      ),
    );
  }
}