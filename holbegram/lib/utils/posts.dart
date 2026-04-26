import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../screens/pages/methods/post_storage.dart';

class Posts extends StatefulWidget {
  const Posts({super.key});

  @override
  State<Posts> createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  Future<void> toggleSave(String postId, String userId, List saved) async {
    try {
      if (saved.contains(postId)) {
        await FirebaseFirestore.instance.collection('users').doc(userId).update({'saved': FieldValue.arrayRemove([postId])});
      } else {
        await FirebaseFirestore.instance.collection('users').doc(userId).update({'saved': FieldValue.arrayUnion([postId])});
      }
    } catch (err) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $err')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('posts').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasData) {
          final data = snapshot.data!.docs;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              var post = data[index].data() as Map<String, dynamic>;
              return SingleChildScrollView(
                child: Container(
                  margin: EdgeInsetsGeometry.lerp(const EdgeInsets.all(8), const EdgeInsets.all(8), 10),
                  height: 540,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(image: NetworkImage(post['profImage']), fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(post['username'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.more_horiz),
                              onPressed: () async {
                                try {
                                  await PostStorage().deletePost(post['postId'], post['postId']);
                                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post Deleted')));
                                } catch (err) {
                                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $err')));
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Align(alignment: Alignment.centerLeft, child: Text(post['caption'] ?? '')),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: 350,
                        height: 350,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          image: DecorationImage(image: NetworkImage(post['postUrl']), fit: BoxFit.cover),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
                          IconButton(icon: const Icon(Icons.chat_bubble_outline), onPressed: () {}),
                          IconButton(icon: const Icon(Icons.send), onPressed: () {}),
                          const Spacer(),
                          IconButton(
                            icon: Icon(
                              userProvider.user != null && userProvider.user!.saved.contains(post['postId'])
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                            ),
                            onPressed: () async {
                              if (userProvider.user == null) return;
                              await toggleSave(post['postId'], userProvider.user!.uid, userProvider.user!.saved);
                              await userProvider.refreshUser();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
