import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../utils/enums/authentication_status.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(const AppState());
}
