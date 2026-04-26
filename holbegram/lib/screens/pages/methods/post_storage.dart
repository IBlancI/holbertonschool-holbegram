import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../auth/methods/user_storage.dart';

class PostStorage {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPost(
    String caption,
    String uid,
    String username,
    String profImage,
    Uint8List image,
  ) async {
    String result = 'Some error occurred';
    try {
      String postUrl = await StorageMethods().uploadImageToStorage(true, 'posts', image);
      String postId = const Uuid().v1();

      await _firestore.collection('posts').doc(postId).set({
        'caption': caption,
        'uid': uid,
        'username': username,
        'profImage': profImage,
        'postUrl': postUrl,
        'postId': postId,
        'datePublished': FieldValue.serverTimestamp(),
        'likes': [],
      });

      result = 'Ok';
    } catch (err) {
      result = err.toString();
    }
    return result;
  }

  Future<void> deletePost(String postId, String publicId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (err) {
      throw Exception(err.toString());
    }
  }
}
