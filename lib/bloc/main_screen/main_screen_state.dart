part of 'main_screen_cubit.dart';

class MainScreenState extends Equatable {
  const MainScreenState();

  @override
  List<Object> get props => [];
}

class MainScreenInitial extends MainScreenState {
  const MainScreenInitial();
}

class MainScreenUploading extends MainScreenState {
  const MainScreenUploading();
}

class MainScreenUploadedSuccess extends MainScreenState {
  const MainScreenUploadedSuccess();
}

class MainScreenUploadedFailure extends MainScreenState {
  final String? error;
  const MainScreenUploadedFailure({required this.error});
}
