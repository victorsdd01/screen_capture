import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:screenshot_playground/helpers/helper.dart';
import 'package:screenshot_playground/helpers/locator.dart';

part 'display_event.dart';
part 'display_state.dart';

class DisplayBloc extends Bloc<DisplayEvent, DisplayState> {

  final ScreenCapture _screenCapture = locator<ScreenCapture>();
  DisplayBloc() : super(const DisplayState()) {
    on<AddDisplaysEvent>((event, emit) async {
      try {
        emit(state.copyWith(displayList: await screenRetriever.getAllDisplays()));
      } catch (e) {
        log('Error: ${e.toString()}');
      }
    });
    on<TakeScreenshotEvent>((event, emit) async {
      try {  
        for (var i = 0; i < state.displayList.length; i++) {
          final display = state.displayList[i];
          String path = 'screenshot_$i.${Platform.isWindows ? 'bmp' : 'png'}';

          // Platform.isWindows ? _screenCapture.takeScreenshotForDisplay(display, "") : _screenCapture.takeScreenshotForDisplay(display, path);
          await _screenCapture.takeScreenshotForDisplay(display, path);
          log('Captured screenshot for ${display.name} at $path');
        }
        add(LoadAcreenshotsEvent());
      } catch (e) {
        log('Error capturing screenshots: $e');
      }
    });
    on<LoadAcreenshotsEvent>((event,emit) async {
      try {
        final Directory directory = await getTemporaryDirectory();
        final List<File> screenshots = <File>[];
        for (var i = 0; i < state.displayList.length; i++) {
          final path = '${directory.path}/screenshot_$i.${Platform.isWindows ? 'bmp' : 'png'}';
          final file = File(path);
          if (await file.exists()) {
            screenshots.add(file);
          }
        }
        if (screenshots.isNotEmpty) {
          emit(state.copyWith(
            // screenShots: screenshots
            displayStatus: DisplayStatus.uploading
          ));

          await Future.delayed(const Duration(seconds: 10), () {
            emit(state.copyWith(
              screenShots: screenshots,
              displayStatus: DisplayStatus.uploaded
            ));
            // add(DeleteScreenshotsEvent());
          });
        }
      } catch (e) {
        log('Error loading screenshots: $e');
        throw Exception('Error loading screenshots: $e'); 
      }
    });
    on<DeleteScreenshotsEvent>((event, emit) async {
      try {
        final Directory directory = await getTemporaryDirectory();
        for (var i = 0; i < state.screenShots.length; i++) {
          final path = '${directory.path}/screenshot_$i.${Platform.isWindows ? 'bmp' : 'png'}';
          final file = File(path);
          if (await file.exists()) {
            await file.delete();
            log('screenshots deleted');
          }
        }
      } catch (e) {
        log('Error deleting screenshots: $e');
        throw Exception('Error deleting screenshots: $e'); 
      }
    });
  }
  }
