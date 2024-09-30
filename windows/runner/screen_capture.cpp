#include <Windows.h>
#include <gdiplus.h>
#include <string>
#include <iostream>

#pragma comment(lib, "gdiplus.lib")

using namespace Gdiplus;

void InitializeGDIPlus() {
    GdiplusStartupInput gdiplusStartupInput;
    ULONG_PTR gdiplusToken;
    GdiplusStartup(&gdiplusToken, &gdiplusStartupInput, NULL);
}

extern "C" __declspec(dllexport) void captureScreen(const char* filePath, int x, int y, int width, int height) {
    // Inicializar GDI+
    InitializeGDIPlus();

    // Obtener el tamaño de la pantalla
    HDC hScreenDC = GetDC(NULL);
    HDC hMemoryDC = CreateCompatibleDC(hScreenDC);
    HBITMAP hBitmap = CreateCompatibleBitmap(hScreenDC, width, height);
    SelectObject(hMemoryDC, hBitmap);

    // Copiar la pantalla en el bitmap
    BitBlt(hMemoryDC, 0, 0, width, height, hScreenDC, x, y, SRCCOPY);

    // Guardar la imagen como PNG
    Bitmap bitmap(hBitmap, NULL);
    CLSID pngClsid;
    GetEncoderClsid(L"image/png", &pngClsid);
    
    std::wstring wsFilePath = std::wstring(filePath, filePath + strlen(filePath));
    bitmap.Save(wsFilePath.c_str(), &pngClsid, NULL);

    // Liberar recursos
    DeleteObject(hBitmap);
    DeleteDC(hMemoryDC);
    ReleaseDC(NULL, hScreenDC);
}

int GetEncoderClsid(const WCHAR* format, CLSID* pClsid) {
    UINT num = 0;          // Número de encoders
    UINT size = 0;         // Tamaño de la información de los encoders
    ImageCodecInfo* pImageCodecInfo = NULL;

    GetImageEncodersSize(&num, &size);
    if (size == 0) return -1;

    pImageCodecInfo = (ImageCodecInfo*)(malloc(size));
    if (pImageCodecInfo == NULL) return -1;

    GetImageEncoders(num, size, pImageCodecInfo);
    for (UINT j = 0; j < num; ++j) {
        if (wcscmp(pImageCodecInfo[j].MimeType, format) == 0) {
            *pClsid = pImageCodecInfo[j].Clsid;
            free(pImageCodecInfo);
            return j;
        }
    }

    free(pImageCodecInfo);
    return -1;
}
