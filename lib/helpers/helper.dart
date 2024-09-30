

import 'dart:developer';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screen_retriever/screen_retriever.dart';

typedef CaptureScreenNative = Void Function(Pointer<Utf8> filePath, Int32 x, Int32 y, Int32 width, Int32 height);
typedef CaptureScreenDart = void Function(Pointer<Utf8> filePath, int x, int y, int width, int height);

class ScreenCapture {
  final DynamicLibrary? nativeLib = 
  Platform.isMacOS 
    ? DynamicLibrary.process() 
    : Platform.isWindows 
      ? DynamicLibrary.open("assets//Dll_1.dll") 
      : null;

  late final CaptureScreenDart captureScreen;

  ScreenCapture() {
    captureScreen = nativeLib!
        .lookupFunction<CaptureScreenNative, CaptureScreenDart>("captureScreen");
  }

  Future<void> takeScreenshotForDisplay(Display display, String fileName) async {
    final directory = await getTemporaryDirectory();
    
    final filePathString = '${directory.path}/$fileName';
    final filePath = filePathString.toNativeUtf8();

    log('filepath: $filePath');

    int x = display.visiblePosition!.dx.toInt();
    int y = display.visiblePosition!.dy.toInt();
    int width = display.size.width.toInt();
    int height = display.size.height.toInt();

    // Capturar la región de pantalla específica
    captureScreen(filePath, x, y, width, height);
    calloc.free(filePath);
    log('Captured screenshot for display at $x, $y, $width, $height');
  }
}
