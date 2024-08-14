import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/repositories/upload_repository.dart';
import '../../models/user_profile.dart';

part 'main_screen_state.dart';

class MainScreenCubit extends Cubit<MainScreenState> {
  final UploadRepository _uploadRepository;
  MainScreenCubit(this._uploadRepository) : super(const MainScreenInitial());

  Future<bool> postImageToLocket(UserProfile userProfile, File image, String caption) async {
    try {
      emit(const MainScreenUploading());
      debugPrint("Before: ${image.lengthSync()}");
      await _uploadRepository.postImageToLocket(userProfile, await _resizeImage(image), caption);
      emit(const MainScreenUploadedSuccess());
      return true;
    } catch (e) {
      print("error: $e");
      emit(MainScreenUploadedFailure(error: e.toString()));
      return false;
    }
  }

  Future<bool> postVideoToLocket(UserProfile userProfile, File video, String caption) async {
    try {
      emit(const MainScreenUploading());
      await _uploadRepository.postVideoToLocket(userProfile, video, caption);
      emit(const MainScreenUploadedSuccess());
      return true;
    } catch (e) {
      emit(MainScreenUploadedFailure(error: e.toString()));
      return false;
    }
  }

  Future<File> _resizeImage(File file) async {
    final imageSize = file.lengthSync();
    const bitPerMB = 1000000;
    // Resize image to 1MB
    if (imageSize < bitPerMB) {
      return file;
    }

    final newQuality = 100 - (bitPerMB / imageSize * 100).round();

    var result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: newQuality,
    );

    debugPrint("Before: ${file.lengthSync()}");
    debugPrint("After: ${result!.length}");

    final tempDir = await getTemporaryDirectory();
    File newFile = await File('${tempDir.path}/image.png').create();
    newFile.writeAsBytesSync(result);
    return newFile;
  }
}
