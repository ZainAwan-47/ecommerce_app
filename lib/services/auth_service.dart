import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signInWithGoogle() async {
    try {
      await _googleSignIn.initialize();

      final GoogleSignInAccount googleUser =
          await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(
        credential,
      );

      final user = userCredential.user;
      final String? fcmToken = await FirebaseMessaging.instance.getToken();

      print("FCM TOKEN: $fcmToken");

      if (user != null) {
        final userDocRef = _firestore.collection("users").doc(user.uid);
        final docSnapshot = await userDocRef.get();

        String existingRole = "customer";
        bool existingIsActive = true;

        if (docSnapshot.exists && docSnapshot.data() != null) {
          existingRole = docSnapshot.data()?["role"] ?? "customer";
          existingIsActive = docSnapshot.data()?["isActive"] ?? true;
        }

        // CRITICAL: Block sign-in immediately if account is deactivated
        if (!existingIsActive) {
          await _googleSignIn.signOut();
          await _auth.signOut();
          throw Exception("This account has been deactivated by an administrator.");
        }

        await userDocRef.set(
          {
            "uid": user.uid,
            "name": user.displayName ?? "",
            "email": user.email ?? "",
            "photo": user.photoURL ?? "",
            "role": existingRole, // Preserves admin/customer role
            "fcmToken": fcmToken ?? "",
            "isActive": existingIsActive, // Preserves deactivation state instead of resetting to true!
            if (!docSnapshot.exists) "createdAt": FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  bool get isLoggedIn => _auth.currentUser != null;

  String? get uid => _auth.currentUser?.uid;

  String? get name => _auth.currentUser?.displayName;

  String? get email => _auth.currentUser?.email;

  String? get photo => _auth.currentUser?.photoURL;
}