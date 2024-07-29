import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:property_match_258_v5/utils/pick_image.dart';

import '../../model/user_models//user_model.dart';
import '../authentication_repository/authentication_repository.dart';
import '../user_repository/user_repository.dart';



class ImageRepository extends GetxController {
  static ImageRepository get instance => Get.find();


  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;


  Future<String> uploadProfileImageToFirebaseStorage(String childName, Uint8List file, bool isPost) async {
    String fileDate = DateTime.now().microsecondsSinceEpoch.toString();

    try {
      Reference ref = _storage.ref().child(childName).child(_auth.currentUser!.uid).child(fileDate);
      UploadTask uploadTask = ref.putData(file); //
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }


}