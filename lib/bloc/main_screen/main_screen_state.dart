part of 'main_screen_cubit.dart';

sealed class MainScreenState extends Equatable {
  const MainScreenState();
}

final class MainScreenInitial extends MainScreenState {
  @override
  List<Object> get props => [];
}
