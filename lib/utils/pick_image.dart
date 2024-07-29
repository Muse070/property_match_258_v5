import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

pickImage(ImageSource source) async {
  final ImagePicker imagePicker = ImagePicker();

  XFile? file = await imagePicker.pickImage(source: source);

  if (file != null) {
    return await file.readAsBytes();
  } else {
    print('No image selected');
    return null; // Return null if no image is selected
  }

  print('No image selected');
}

pickMultipleImagesAndVideos() async {
  FilePickerResult? result = await FilePicker.platform
      .pickFiles(type: FileType.image, allowMultiple: true);

  if (result != null) {
    List<Map<String, dynamic>> files =
    await Future.wait(result.files.map((file) async {
      String extension = path.extension(file.path!);
      Uint8List bytes = await File(file.path!).readAsBytes();
      return {'bytes': bytes, 'extension': extension};
    }).toList());
    return files;
  } else {
    print("User cancelled selection");
  }
}

Future<List<Map<String, dynamic>>> pickMultipleImagesAndVideosEdit() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    allowMultiple: true,
  );

  if (result != null) {
    List<Map<String, dynamic>> files = result.files.map((file) {
      String extension = path.extension(file.path!);
      Uint8List? bytes = file.bytes; // Get bytes directly from FilePickerResult

      // Determine imageType based on whether the file is from the network or local
      ImageDataType imageType =
      file.path!.startsWith('http') // Check if it's a URL
          ? ImageDataType.url
          : ImageDataType.uint8List; // Assume local file if not a URL

      return {
        'bytes': bytes,
        'extension': extension,
      };
    }).toList();

    return files;
  } else {
    print("User cancelled selection");
    return []; // Return an empty list if the user cancels
  }
}

pickMultipleDocuments() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom, allowedExtensions: ['pdf'], allowMultiple: true);

  if (result != null) {
    List<Map<String, dynamic>> files =
    await Future.wait(result.files.map((file) async {
      String extension = path.extension(file.path!);
      Uint8List bytes = await File(file.path!).readAsBytes();
      return {'bytes': bytes, 'extension': extension};
    }).toList());
    print("Documents selected are: $files");
    return files;
  } else {
    print("User cancelled selection");
  }
}

Future<File> _writeByteDataToFile(ByteData data, String path) async {
  final buffer = data.buffer;
  return File(path)
      .writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
}

Future<String?> uploadImageToStorageAndGetUrl(
    Uint8List imageBytes, String fileName) async {
  try {
    // Create a reference to the location you want to upload to in firebase
    firebase_storage.Reference ref =
    firebase_storage.FirebaseStorage.instance.ref().child('agentProfileImages/$fileName');

    // Upload the file to firebase
    firebase_storage.UploadTask uploadTask = ref.putData(imageBytes);

    // Wait for the upload to complete and get the download URL
    firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    print('File uploaded successfully. Download URL: $downloadUrl');

    return downloadUrl;
  } catch (e) {
    print('Error uploading image to storage: $e');
    return null;
  }
}

Future<String?> getImageFilePathFromDocByte(Uint8List docBytesFiles) async {
  String filePaths = "";

  final tempDir = await getTemporaryDirectory();
  final fileName =
      '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
  final file =
  await _writeByteDataToFile(ByteData.view(docBytesFiles.buffer), fileName);

  // Upload the file to firebase
  final imageUrl = await uploadImageToStorageAndGetUrl(
      await file.readAsBytes(), fileName);

  return imageUrl;
}

Future<List<String>> getFilePathsFromDocByte(
    List<Uint8List> docBytesFiles) async {
  List<String> filePaths = [];

  for (Uint8List docByte in docBytesFiles) {
    final tempDir = await getTemporaryDirectory();
    final fileName =
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file =
    await _writeByteDataToFile(ByteData.view(docByte.buffer), fileName);
    filePaths.add(file.path);
  }

  return filePaths;
}

enum ImageDataType { uint8List, base64, url }
