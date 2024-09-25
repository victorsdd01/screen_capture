
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screenshot_playground/bloc/display_bloc.dart';
import 'package:screenshot_playground/helpers/locator.dart';
import 'package:screenshot_playground/helpers/observable.dart';
import 'package:screenshot_playground/pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  Bloc.observer = Observable();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => locator<DisplayBloc>()),
      ],
      child: const MyApp()
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}