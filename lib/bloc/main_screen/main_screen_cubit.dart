import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/repositories/upload_repository.dart';
import '../../models/user_profile.dart';

part 'main_screen_state.dart';

class MainScreenCubit extends Cubit<MainScreenState> {
  final UploadRepository _uploadRepository;
  MainScreenCubit(this._uploadRepository) : super(const MainScreenInitial());

  Future<bool> postImageToLocket(UserProfile userProfile, File image, String caption) async {
    try {
      emit(const MainScreenUploading());
      await _uploadRepository.postImageToLocket(userProfile, image, caption);
      emit(const MainScreenUploadedSuccess());
      return true;
    } catch (e) {
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
}
