import 'dart:io';

import 'package:firebase/src/storage/fire_storage_exception.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class FbStorageController {
  FbStorageController(this._firebaseStorage, this._storageBucketUrl);

  final FirebaseStorage _firebaseStorage;
  final String _storageBucketUrl;

  Future<String> uploadRawDocument(String fileName, Uint8List data) async {
    try {
      final storageRef = _firebaseStorage
          .refFromURL(_storageBucketUrl)
          .child(fileName);
      final uploadTask = await storageRef.putData(data);
      final exception = mapFailureToException(uploadTask.state);
      if (exception == null) {
        return await storageRef.getDownloadURL();
      }
      throw exception;
    } catch (error, st) {
      throw StorageUploadFailedException(error, st);
    }
  }

  Future<String> uploadStringUrlDocument(
    String fileName,
    String dataUrl,
  ) async {
    try {
      final storageRef = _firebaseStorage
          .refFromURL(_storageBucketUrl)
          .child(fileName);
      final uploadTask = await storageRef.putString(
        dataUrl,
        format: PutStringFormat.dataUrl,
      );
      final exception = mapFailureToException(uploadTask.state);
      if (exception == null) {
        return await storageRef.getDownloadURL();
      }
      throw exception;
    } catch (error, st) {
      throw StorageUploadFailedException(error, st);
    }
  }

  Future<String> uploadFileDocument(String fileName, File file) async {
    try {
      final storageRef = _firebaseStorage
          .refFromURL(_storageBucketUrl)
          .child(fileName);
      final uploadTask = await storageRef.putFile(file);
      final exception = mapFailureToException(uploadTask.state);
      if (exception == null) {
        return await storageRef.getDownloadURL();
      }
      throw exception;
    } catch (error, st) {
      throw StorageUploadFailedException(error, st);
    }
  }

  Future<File> downloadFileDocument({
    required String fileName,
    required String? storageFolder,
  }) async {
    if (kIsWeb) {
      throw StorageDownloadErrorException(
        'This method is not supported on web',
        StackTrace.current,
      );
    }
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final tempFile = File('${appDocDir.path}/$fileName');

      final storageRef = _firebaseStorage.ref('$storageFolder/$fileName');
      await storageRef.writeToFile(tempFile);

      return tempFile;
    } catch (error, st) {
      throw StorageDownloadErrorException(error, st);
    }
  }

  Future<void> deleteFileDocument(String fileName) async {
    try {
      final storageRef = _firebaseStorage
          .refFromURL(_storageBucketUrl)
          .child(fileName);

      await storageRef.delete();
    } catch (error, st) {
      throw StorageDeleteErrorException(error, st);
    }
  }
}
