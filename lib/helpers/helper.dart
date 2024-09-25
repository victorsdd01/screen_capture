

import 'dart:developer';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:screen_retriever/screen_retriever.dart';

typedef CaptureScreenNative = Void Function(Pointer<Utf8> filePath, Int32 x, Int32 y, Int32 width, Int32 height);
typedef CaptureScreenDart = void Function(Pointer<Utf8> filePath, int x, int y, int width, int height);

class ScreenCapture {
  final DynamicLibrary? nativeLib = 
  Platform.isMacOS 
    ? DynamicLibrary.process() 
    : Platform.isWindows 
      ? DynamicLibrary.open("screen_capture.dll") 
      : null;

  late final CaptureScreenDart captureScreen;

  ScreenCapture() {
    captureScreen = nativeLib!
        .lookupFunction<CaptureScreenNative, CaptureScreenDart>("captureScreen");
  }

  // Modificar esta función para capturar por display
  void takeScreenshotForDisplay(Display display, String path) {
    final filePath = path.toNativeUtf8();

    // Obtener las dimensiones y coordenadas del monitor
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
