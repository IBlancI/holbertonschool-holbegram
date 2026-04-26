import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../methods/auth_methods.dart';
import '../utils/image_picker.dart' as utils;

class AddPicture extends StatefulWidget {
  final String email;
  final String password;
  final String username;

  const AddPicture({
    super.key,
    required this.email,
    required this.password,
    required this.username,
  });

  @override
  State<AddPicture> createState() => _AddPictureState();
}

class _AddPictureState extends State<AddPicture> {
  Uint8List? _image;
  bool _isLoading = false;

  void selectImageFromGallery() async {
    Uint8List? picked = await utils.pickImage(ImageSource.gallery);
    if (picked != null) setState(() => _image = picked);
  }

  void selectImageFromCamera() async {
    Uint8List? picked = await utils.pickImage(ImageSource.camera);
    if (picked != null) setState(() => _image = picked);
  }

  Future<void> _signUp() async {
    setState(() => _isLoading = true);
    String result = await AuthMethode().signUpUser(
      email: widget.email,
      password: widget.password,
      username: widget.username,
      file: _image,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (result == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Success'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adilgram', style: TextStyle(fontFamily: 'Billabong', fontSize: 32)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Hello', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(widget.username, style: const TextStyle(fontSize: 24, color: Colors.grey)),
                const SizedBox(height: 28),
                const Text(
                  'Welcome to Holbegram, choose a picture for your profile.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 28),
                CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _image != null ? MemoryImage(_image!) : null,
                  child: _image == null ? Icon(Icons.person, size: 80, color: Colors.grey[700]) : null,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(children: [
                      IconButton(
                        onPressed: selectImageFromCamera,
                        icon: const Icon(Icons.camera_alt, size: 50, color: Color.fromARGB(218, 226, 37, 24)),
                      ),
                      const SizedBox(height: 8),
                      const Text('Camera'),
                    ]),
                    const SizedBox(width: 60),
                    Column(children: [
                      IconButton(
                        onPressed: selectImageFromGallery,
                        icon: const Icon(Icons.photo_library, size: 50, color: Color.fromARGB(218, 226, 37, 24)),
                      ),
                      const SizedBox(height: 8),
                      const Text('Gallery'),
                    ]),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(const Color.fromARGB(218, 226, 37, 24)),
                    ),
                    onPressed: _isLoading ? null : _signUp,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Next', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
