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

int GetEncoderClsid(const WCHAR* format, CLSID* pClsid) {
    UINT num = 0;          // Número de encoders
    UINT size = 0;         // Tamaño de la información de los encoders

    GetImageEncodersSize(&num, &size);
    if (size == 0) return -1; // Error: No hay encoders

    ImageCodecInfo* pImageCodecInfo = (ImageCodecInfo*)(malloc(size));
    if (pImageCodecInfo == NULL) return -1; // Error: Memoria no disponible

    GetImageEncoders(num, size, pImageCodecInfo);

    for (UINT j = 0; j < num; ++j) {
        if (wcscmp(pImageCodecInfo[j].MimeType, format) == 0) {
            *pClsid = pImageCodecInfo[j].Clsid;
            free(pImageCodecInfo);
            return j; // Retorna el índice del encoder
        }
    }

    free(pImageCodecInfo);
    return -1; // Error: No se encontró el encoder
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

    // Convertir el char* a wstring para usar con GDI+
    std::wstring wsFilePath = std::wstring(filePath, filePath + strlen(filePath));

    // Guardar la imagen como PNG usando GDI+
    Bitmap bitmap(hBitmap, NULL);
    CLSID pngClsid;
    if (GetEncoderClsid(L"image/png", &pngClsid) != -1) {
        // Aquí, pasamos NULL en los parámetros del encoder si no necesitamos configuración específica
        Status stat = bitmap.Save(wsFilePath.c_str(), &pngClsid, NULL);

        if (stat != Ok) {
            std::cerr << "Error al guardar la imagen: " << stat << std::endl;
        }
    } else {
        std::cerr << "Error: No se encontró el encoder PNG." << std::endl;
    }

    // Liberar recursos
    DeleteObject(hBitmap);
    DeleteDC(hMemoryDC);
    ReleaseDC(NULL, hScreenDC);
}
