import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../orders/orders_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../auth/login_screen.dart';
import '../main/main_screen.dart';
import '../home/widgets/bottom_nav.dart';

import '../../core/tab_controller.dart';
import '../../utils/app_notifier.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:io';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {
  final User? user =
      FirebaseAuth.instance.currentUser;
final TextEditingController nameController =
    TextEditingController();
    final TextEditingController phoneController =
    TextEditingController();

final TextEditingController addressController =
    TextEditingController();
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

  nameController.text =
      data['displayName'] ??
      user?.displayName ??
      "";

  phoneController.text =
      data['phoneNumber'] ?? "";

  addressController.text =
      data['address'] ?? "";
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

    final uploadTask =
        await storageRef.putFile(profileImage!);

    final url = await uploadTask.ref.getDownloadURL();

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .set({
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profile picture updated"),
      ),
    );
  } catch (e) {
    setState(() {
      uploading = false;
    });

    debugPrint(e.toString());

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString()),
      ),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF9F7),

     appBar: AppBar(
  backgroundColor: const Color(0xffFFF9F7),
  elevation: 0,
  centerTitle: true,

  leading: IconButton(
    icon: const Icon(
      Icons.arrow_back_ios_new,
      color: Colors.black,
    ),
    onPressed: () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
         builder: (_) => const MainScreen(),
        ),
      );
    },
  ),

  title: Text(
    "My Profile",
    style: GoogleFonts.dmSerifDisplay(
      fontSize: 30,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
  ),
),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),

        child: Column(
          children: [

            const SizedBox(height: 15),

           GestureDetector(
  onTap: pickProfileImage,
  child: Stack(
    children: [
      CircleAvatar(
        radius: 55,
        backgroundColor: const Color(0xff7F4F4F),
      backgroundImage: profileImage != null
    ? FileImage(profileImage!)
    : photoUrl != null
        ? NetworkImage(photoUrl!)
        : null,
        child: profileImage == null
            ? Text(
                user?.email
                        ?.substring(0, 1)
                        .toUpperCase() ??
                    "U",
                style: GoogleFonts.manrope(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
            : null,
      ),
     if (uploading)
  const Positioned.fill(
    child: Center(
      child: CircularProgressIndicator(),
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
            size: 18,
            color: Colors.white,
          ),
        ),
      ),
    ],
  ),
),

            const SizedBox(height: 22),

           TextField(
  controller: nameController,
  textAlign: TextAlign.center,
  style: GoogleFonts.dmSerifDisplay(
    fontSize: 28,
    fontWeight: FontWeight.bold,
  ),
  decoration: const InputDecoration(
    border: InputBorder.none,
  ),
),

            const SizedBox(height: 8),

            Text(
              user?.email ??
                  "No Email",
              style: GoogleFonts.manrope(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 28),

TextField(
  controller: phoneController,
  keyboardType: TextInputType.phone,
  decoration: InputDecoration(
    labelText: "Phone Number",
    hintText: "03XXXXXXXXX",
    prefixIcon: const Icon(Icons.phone_outlined),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
),

const SizedBox(height: 20),

TextField(
  controller: addressController,
   minLines: 3,
  maxLines: 5,
  decoration: InputDecoration(
    labelText: "Delivery Address",
    hintText: "House, Street, Area, City",
    prefixIcon: const Padding(
      padding: EdgeInsets.only(bottom: 55),
      child: Icon(Icons.location_on_outlined),
    ),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
),
            const SizedBox(height: 35),
            SizedBox(
  width: double.infinity,
  height: 50,
  child: ElevatedButton.icon(
  onPressed: () async {
  final newName = nameController.text.trim();
final phone = phoneController.text.trim();

if (!RegExp(r'^03\d{9}$').hasMatch(phone)) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        "Phone number must be 11 digits (03XXXXXXXXX)",
      ),
      backgroundColor: Colors.red,
    ),
  );
  return;
}

if (addressController.text.trim().isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        "Please enter your address.",
      ),
      backgroundColor: Colors.red,
    ),
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
  'phoneNumber':
      phoneController.text.trim(),
  'address':
      addressController.text.trim(),
}, 
 SetOptions(merge: true));

  if (!mounted) return;
 AppNotifier.success(
  context,
  "Profile Updated Successfully",
);
  FocusScope.of(context).unfocus();
  setState(() {});
},
    icon: const Icon(Icons.save),
    label: Text(
      "Save Profile",
      style: GoogleFonts.manrope(
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
),

const SizedBox(height: 25),
            _buildTile(
  icon: Icons.shopping_bag_outlined,
  title: "My Orders",
 onTap: () {
  previousTab = 3;
  selectedTab.value = 2;
},
),

_buildTile(
  icon: Icons.favorite_outline,
  title: "Wishlist",
  onTap: () {
  previousTab = 3;
  selectedTab.value = 1;
},
),

_buildTile(
  icon: Icons.lock_outline,
  title: "Change Password",
  onTap: () {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        "Coming Soon",
      ),
    ),
  );
},
),

_buildTile(
  icon: Icons.support_agent,
  title: "Contact Us",
 onTap: () {
  showAboutDialog(
    context: context,
    applicationName: "Shop by Tehreem",
    applicationVersion: "1.0.0",
    children: const [
      Text(
        "Need help? Contact us anytime.",
      ),
    ],
  );
},
),

_buildTile(
  icon: Icons.info_outline,
  title: "About App",
 onTap: () {
  showAboutDialog(
    context: context,
    applicationName: "Shop by Tehreem",
    applicationVersion: "1.0.0",
    applicationLegalese:
        "© 2026 Shop by Tehreem",
  );
},
),

const SizedBox(height: 25),
SizedBox(
  width: double.infinity,
  height: 55,
  child: ElevatedButton.icon(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.red,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    ),
    onPressed: () async {
  final shouldLogout = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.logout_rounded,
              color: Color(0xff7F4F4F),
            ),
            SizedBox(width: 10),
            Text(
              "Logout",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          "Are you sure you want to log out of your account?",
          style: TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text(
              "Cancel",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff7F4F4F),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text("Logout"),
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
    icon: const Icon(
      Icons.logout,
      color: Colors.white,
    ),
    label: Text(
      "Logout",
      style: GoogleFonts.manrope(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    ),
  ),
),

const SizedBox(height: 20),

Text(
  "Version 1.0.0",
  style: GoogleFonts.manrope(
    color: Colors.grey,
  ),
),
          ],
        ),
      ),
    );
  }
  Widget _buildTile({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 14),

    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.05),
          blurRadius: 12,
          offset: const Offset(0, 5),
        ),
      ],
    ),

    child: ListTile(
      onTap: onTap,

      leading: Icon(
        icon,
        color: const Color(0xff7F4F4F),
      ),

      title: Text(
        title,
        style: GoogleFonts.manrope(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),

      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 18,
      ),
    ),
  );
}
}