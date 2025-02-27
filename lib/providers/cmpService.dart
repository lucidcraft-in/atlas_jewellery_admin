import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firbase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;

class CompanyService with ChangeNotifier {
  final firbase_storage.FirebaseStorage storage =
      firbase_storage.FirebaseStorage.instance;

  CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('QRdetails');

  late FirebaseFirestore firestore;
  initiliase() {
    firestore = FirebaseFirestore.instance;
  }

  Future createQrcode(String id, File compressImage, String fileName,
      String UPIiD, oldName, String acNo, String ifsc) async {
    try {
      // Reference storageRef =
      //     FirebaseStorage.instance.ref().child('QRCODE/$oldName');

      // // Delete the file
      // await storageRef.delete();
      final Directory systemTempDir = Directory.systemTemp;

      firbase_storage.TaskSnapshot taskSnapshot =
          await storage.ref('QRCODE/$fileName').putFile(compressImage);
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      await collectionReference.doc(id).update({
        "upiId": UPIiD,
        "qrcode": downloadUrl,
        "qrname": fileName,
        "timestamp": FieldValue.serverTimestamp(),
        "acNo": acNo,
        "ifsc": ifsc,
      });
      return 200;
    } on firebase_core.FirebaseException catch (e) {
      print(e);
    }
  }

  readQr() async {
    try {
      List qrData = [];
      QuerySnapshot querySnapshot = await collectionReference.get();
      for (var doc in querySnapshot.docs.toList()) {
        Map a = {
          "id": doc.id,
          "upiId": doc["upiId"],
          "qrcode": doc["qrcode"],
          "qrname": doc["qrname"],
          "acNo": doc["ac_no"],
          "ifsc": doc["ifsc"],
          "timestamp": FieldValue.serverTimestamp(),
        };
        qrData.add(a);
      }
      // print(qrData);
      return qrData;
    } catch (e) {}
  }
}
