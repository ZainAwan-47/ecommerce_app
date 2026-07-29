import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() =>
      _NotificationScreenState();
}

class _NotificationScreenState
    extends State<NotificationScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final User? user =
      FirebaseAuth.instance.currentUser;

  List<DocumentSnapshot> notifications = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    if (user == null) return;

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
  }

  Future<void> deleteNotification(int index) async {
    final deletedDoc = notifications[index];
    final deletedData =
        deletedDoc.data() as Map<String, dynamic>;

    setState(() {
      notifications.removeAt(index);
    });

    bool undoPressed = false;

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        content: const Text(
          "Notification deleted",
        ),
        action: SnackBarAction(
          label: "UNDO",
          onPressed: () {
            undoPressed = true;

            setState(() {
              notifications.insert(index, deletedDoc);
            });
          },
        ),
      ),
    );

    await Future.delayed(
      const Duration(seconds: 4),
    );

    if (!undoPressed) {
      await _firestore
          .collection("notifications")
          .doc(deletedDoc.id)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("Please sign in."),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffFFF9F7),

      appBar: AppBar(
        backgroundColor: const Color(0xffFFF9F7),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
                      : notifications.isEmpty
              ? const Center(
                  child: Text(
                    "No notifications yet",
                    style: TextStyle(fontSize: 18),
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

                      onDismissed: (_) {
                        deleteNotification(index);
                      },

                      background: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius:
                              BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),

                      secondaryBackground: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius:
                              BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),

                      child: Container(
                        margin:
                            const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.black.withOpacity(.05),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const CircleAvatar(
                              radius: 24,
                              backgroundColor:
                                  Color(0xffF6E8E6),
                              child: Icon(
                                Icons.notifications_none,
                                color:
                                    Color(0xff7F4F4F),
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    data["title"] ?? "",
                                    style:
                                        const TextStyle(
                                      fontSize: 17,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    data["body"] ?? "",
                                    style: TextStyle(
                                      color: Colors
                                          .grey.shade700,
                                      height: 1.4,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  Text(
                                    formattedDate,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors
                                          .grey.shade500,
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