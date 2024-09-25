

#include <Windows.h>
#include <string>
#include <iostream>

extern "C" __declspec(dllexport) void captureScreen(const char* filePath) {
    // Obtener el tamaño de la pantalla
    int screenX = GetSystemMetrics(SM_CXSCREEN);
    int screenY = GetSystemMetrics(SM_CYSCREEN);

    // Crear un bitmap compatible
    HDC hScreenDC = GetDC(NULL);
    HDC hMemoryDC = CreateCompatibleDC(hScreenDC);
    HBITMAP hBitmap = CreateCompatibleBitmap(hScreenDC, screenX, screenY);
    SelectObject(hMemoryDC, hBitmap);

    // Copiar la pantalla en el bitmap
    BitBlt(hMemoryDC, 0, 0, screenX, screenY, hScreenDC, 0, 0, SRCCOPY);

    // Guardar la imagen como archivo
    BITMAPFILEHEADER bfHeader;
    BITMAPINFOHEADER biHeader;
    BITMAPINFO bInfo;
    bInfo.bmiHeader = biHeader;
    
    // Inicializar el contenido del bitmap
    biHeader.biSize = sizeof(BITMAPINFOHEADER);
    biHeader.biWidth = screenX;
    biHeader.biHeight = screenY;
    biHeader.biPlanes = 1;
    biHeader.biBitCount = 24; // Para guardar la imagen en 24 bits
    biHeader.biCompression = BI_RGB;
    biHeader.biSizeImage = 0;
    biHeader.biXPelsPerMeter = 0;
    biHeader.biYPelsPerMeter = 0;
    biHeader.biClrUsed = 0;
    biHeader.biClrImportant = 0;

    // Guardar el archivo en el path especificado
    FILE* file;
    fopen_s(&file, filePath, "wb");

    if (file != NULL) {
        fwrite(&bfHeader, sizeof(BITMAPFILEHEADER), 1, file);
        fwrite(&biHeader, sizeof(BITMAPINFOHEADER), 1, file);
        
        // Escribir los datos del bitmap
        for (int y = 0; y < screenY; y++) {
            fwrite(&hBitmap, 3 * screenX, 1, file);
        }
        fclose(file);
    }

    // Liberar recursos
    DeleteObject(hBitmap);
    DeleteDC(hMemoryDC);
    ReleaseDC(NULL, hScreenDC);
}
