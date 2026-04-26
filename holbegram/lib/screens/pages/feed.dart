import 'package:flutter/material.dart';

import '../../utils/posts.dart';

class Feed extends StatelessWidget {
  const Feed({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Adilgram', style: TextStyle(fontFamily: 'Billabong', fontSize: 32)),
            const SizedBox(width: 10),
            Image.asset('assets/images/logo.png', height: 40),
            const Spacer(),
            IconButton(icon: const Icon(Icons.add_box_outlined), onPressed: () {}),
            IconButton(icon: const Icon(Icons.messenger_outline), onPressed: () {}),
          ],
        ),
      ),
      body: const Posts(),
    );
  }
}
