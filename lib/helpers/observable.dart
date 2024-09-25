


import 'package:bloc/bloc.dart';
import 'package:screenshot_playground/bloc/display_bloc.dart';

class Observable extends BlocObserver{
  @override
  void onChange(BlocBase bloc, Change change) {
    if(bloc is DisplayBloc){
      final currentState = change.currentState as DisplayState;
      final nextState = change.nextState as DisplayState;
      if(currentState.displayList != nextState.displayList){
        print('Display list: ${nextState.displayList}');
      }
      if(currentState.screenShots != nextState.screenShots){
        print('Screenshots: ${nextState.screenShots}');
      }
    }
    super.onChange(bloc, change);
  }

}