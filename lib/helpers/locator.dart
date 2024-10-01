


import 'package:get_it/get_it.dart';
import 'package:screenshot_playground/bloc/display_bloc.dart';
import 'package:screenshot_playground/helpers/helper.dart';

GetIt locator = GetIt.instance;


void setupLocator() {
  // locator.registerLazySingleton(() => ScreenCapture());
  locator.registerLazySingleton(() => DisplayBloc());
}