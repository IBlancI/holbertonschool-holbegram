import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class StorageMethods {
  final String cloudinaryUrl =
      'https://api.cloudinary.com/v1_1/dnvlprlbs/image/upload';
  final String cloudinaryPreset = 'default';

  Future<String> uploadImageToStorage(
    bool isPost,
    String childName,
    Uint8List file,
  ) async {
    String uniqueId = const Uuid().v1();
    var uri = Uri.parse(cloudinaryUrl);
    var request = http.MultipartRequest('POST', uri);
    request.fields['upload_preset'] = cloudinaryPreset;
    request.fields['folder'] = childName;
    if (isPost) {
      request.fields['public_id'] = uniqueId;
    }

    var multipartFile = http.MultipartFile.fromBytes(
      'file',
      file,
      filename: '$uniqueId.jpg',
    );
    request.files.add(multipartFile);

    dev.log('[Cloudinary] uploading ${file.length} bytes to $cloudinaryUrl preset=$cloudinaryPreset folder=$childName');

    var response = await request.send();
    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);

    dev.log('[Cloudinary] status=${response.statusCode} body=$responseString');

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(responseString);
      return jsonResponse['secure_url'];
    } else {
      throw Exception(
        'Cloudinary upload failed [${response.statusCode}]: $responseString',
      );
    }
  }
}
