import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;
  
  List<DocumentSnapshot> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    if (user == null) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      return;
    }

    try {
      final snapshot = await _firestore
          .collection("notifications")
          .where("userId", isEqualTo: user!.uid)
          .orderBy("createdAt", descending: true)
          .get();

      if (!mounted) return;
      setState(() {
        notifications = snapshot.docs;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteNotification(int index) async {
    final deletedDoc = notifications[index];
    
    setState(() {
      notifications.removeAt(index);
    });

    bool undoPressed = false;
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        content: Text(
          "Notification deleted",
          style: GoogleFonts.manrope(fontSize: 14),
        ),
        action: SnackBarAction(
          label: "UNDO",
          textColor: const Color(0xff7F4F4F),
          onPressed: () {
            undoPressed = true;
            setState(() {
              notifications.insert(index, deletedDoc);
            });
          },
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 4));

    if (!undoPressed) {
      try {
        await _firestore
            .collection("notifications")
            .doc(deletedDoc.id)
            .delete();
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xffFFF9F7),
        appBar: AppBar(
          backgroundColor: const Color(0xffFFF9F7),
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Color(0xff2D2323)),
          title: Text(
            "Notifications",
            style: GoogleFonts.manrope(
              color: const Color(0xff2D2323),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Center(
          child: Text(
            "Please sign in.",
            style: GoogleFonts.manrope(
              fontSize: 16,
              color: const Color(0xff8D7B7B),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffFFF9F7),
      appBar: AppBar(
        backgroundColor: const Color(0xffFFF9F7),
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xff2D2323)),
        title: Text(
          "Notifications",
          style: GoogleFonts.manrope(
            color: const Color(0xff2D2323),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xff7F4F4F),
              ),
            )
          : notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off_outlined,
                        size: 70,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No notifications yet",
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff2D2323),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final data = notifications[index].data()
                        as Map<String, dynamic>;
                    final Timestamp? timestamp =
                        data["createdAt"] as Timestamp?;
                    final formattedDate = timestamp == null
                        ? ""
                        : DateFormat(
                            "dd MMM yyyy • hh:mm a",
                          ).format(timestamp.toDate());

                    return Dismissible(
                      key: Key(notifications[index].id),
                      direction: DismissDirection.horizontal,
                      onDismissed: (direction) {
                        deleteNotification(index);
                      },
                      background: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      secondaryBackground: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CircleAvatar(
                              radius: 22,
                              backgroundColor: Color(0xffF6E8E6),
                              child: Icon(
                                Icons.notifications_none_rounded,
                                color: Color(0xff7F4F4F),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data["title"] ?? "",
                                    style: GoogleFonts.manrope(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xff2D2323),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    data["body"] ?? "",
                                    style: GoogleFonts.manrope(
                                      color: Colors.grey.shade700,
                                      fontSize: 13.5,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    formattedDate,
                                    style: GoogleFonts.manrope(
                                      fontSize: 11.5,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}