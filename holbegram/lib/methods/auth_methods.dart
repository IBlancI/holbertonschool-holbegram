import 'dart:developer' as dev;
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user.dart';
import '../screens/auth/methods/user_storage.dart';

class AuthMethode {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> login({
    required String email,
    required String password,
  }) async {
    String result = 'Some error occurred';
    try {
      if (email.isEmpty || password.isEmpty) {
        return 'Please fill all the fields';
      }
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      result = 'success';
    } catch (err) {
      result = err.toString();
    }
    return result;
  }

  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    Uint8List? file,
  }) async {
    String result = 'Some error occurred';
    try {
      if (email.isEmpty || password.isEmpty || username.isEmpty) {
        return 'Please fill all the fields';
      }
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User user = userCredential.user!;
      dev.log('[Auth] Firebase user created uid=${user.uid}');

      String photoUrl = '';
      if (file != null) {
        try {
          photoUrl = await StorageMethods().uploadImageToStorage(
            false,
            'profilePics',
            file,
          );
          dev.log('[Auth] Cloudinary photo uploaded: $photoUrl');
        } catch (cloudinaryErr) {
          dev.log('[Auth] Cloudinary upload FAILED: $cloudinaryErr');
        }
      }

      Users users = Users(
        uid: user.uid,
        email: email,
        username: username,
        bio: '',
        photoUrl: photoUrl,
        followers: [],
        following: [],
        posts: [],
        saved: [],
        searchKey: username.isNotEmpty ? username[0].toLowerCase() : '',
      );

      await _firestore.collection('users').doc(user.uid).set(users.toJson());
      dev.log('[Auth] Firestore user doc created');

      result = 'success';
    } catch (err) {
      result = err.toString();
    }
    return result;
  }

  Future<Users> getUserDetails() async {
    User currentUser = _auth.currentUser!;
    DocumentSnapshot snap =
        await _firestore.collection('users').doc(currentUser.uid).get();
    return Users.fromSnap(snap);
  }
}
