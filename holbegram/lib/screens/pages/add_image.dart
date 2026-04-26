import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../utils/image_picker.dart' as utils;
import 'methods/post_storage.dart';

class AddImage extends StatefulWidget {
  const AddImage({super.key});

  @override
  State<AddImage> createState() => _AddImageState();
}

class _AddImageState extends State<AddImage> {
  Uint8List? _image;
  final TextEditingController _captionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> selectImageFromGallery() async {
    Uint8List? picked = await utils.pickImage(ImageSource.gallery);
    if (picked != null) setState(() => _image = picked);
  }

  Future<void> selectImageFromCamera() async {
    Uint8List? picked = await utils.pickImage(ImageSource.camera);
    if (picked != null) setState(() => _image = picked);
  }

  Future<void> postImage() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }
    setState(() => _isLoading = true);
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }
    String result = await PostStorage().uploadPost(
      _captionController.text,
      user.uid,
      user.username,
      user.photoUrl,
      _image!,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (result == 'Ok') {
      _captionController.clear();
      setState(() => _image = null);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Posted!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adilgram', style: TextStyle(fontFamily: 'Billabong', fontSize: 32)),
        centerTitle: false,
        actions: [
          if (_image != null)
            TextButton(
              onPressed: _isLoading ? null : postImage,
              child: const Text(
                'Post',
                style: TextStyle(color: Color.fromARGB(218, 226, 37, 24), fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_isLoading) const LinearProgressIndicator(),
          const SizedBox(height: 12),
          if (_image != null)
            Container(
              height: 300,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(image: MemoryImage(_image!), fit: BoxFit.cover),
              ),
            )
          else
            Container(
              height: 300,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
              child: const Center(child: Icon(Icons.image, size: 80, color: Colors.grey)),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: selectImageFromCamera,
                icon: const Icon(Icons.camera_alt, size: 36),
                color: const Color.fromARGB(218, 226, 37, 24),
              ),
              const SizedBox(width: 24),
              IconButton(
                onPressed: selectImageFromGallery,
                icon: const Icon(Icons.photo_library, size: 36),
                color: const Color.fromARGB(218, 226, 37, 24),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _captionController,
              decoration: const InputDecoration(hintText: 'Write a caption...', border: OutlineInputBorder()),
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }
}
