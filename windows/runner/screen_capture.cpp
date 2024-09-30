#include <Windows.h>
#include <string>
#include <iostream>
#include <fstream>

extern "C" __declspec(dllexport) void captureScreen(const char* filePath, int x, int y, int width, int height) {
    // Obtener el tamaño de la pantalla
    int screenX = GetSystemMetrics(SM_CXSCREEN);
    int screenY = GetSystemMetrics(SM_CYSCREEN);

    // Crear un bitmap compatible
    HDC hScreenDC = GetDC(NULL);
    HDC hMemoryDC = CreateCompatibleDC(hScreenDC);
    HBITMAP hBitmap = CreateCompatibleBitmap(hScreenDC, screenX, screenY);
    SelectObject(hMemoryDC, hBitmap);

    // Copiar la pantalla en el bitmap
    BitBlt(hMemoryDC, 0, 0, screenX, screenY, hScreenDC, x, y, SRCCOPY);

    // Obtener la información del bitmap
    BITMAP bmp;
    GetObject(hBitmap, sizeof(BITMAP), &bmp);

    // Crear los headers
    BITMAPFILEHEADER bfh;
    BITMAPINFOHEADER bih;

    bfh.bfType = 0x4D42;  // "BM"
    bfh.bfSize = sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER) + bmp.bmWidthBytes * bmp.bmHeight;
    bfh.bfReserved1 = 0;
    bfh.bfReserved2 = 0;
    bfh.bfOffBits = sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER);

    bih.biSize = sizeof(BITMAPINFOHEADER);
    bih.biWidth = width;
    bih.biHeight = height;
    bih.biPlanes = 1;
    bih.biBitCount = 24;  // 24 bits para guardar la imagen en color
    bih.biCompression = BI_RGB;
    bih.biSizeImage = bmp.bmWidthBytes * bmp.bmHeight;

    // Guardar el archivo en el path especificado
    std::ofstream file(filePath, std::ios::out | std::ios::binary);
    if (file.is_open()) {
        // Escribir los headers
        file.write((char*)&bfh, sizeof(bfh));
        file.write((char*)&bih, sizeof(bih));

        // Escribir los datos del bitmap
        int rowSize = ((bmp.bmWidth * 24 + 31) / 32) * 4; // Calcular el tamaño de cada fila en bytes
        char* bmpData = new char[rowSize * bmp.bmHeight];
        GetBitmapBits(hBitmap, bih.biSizeImage, bmpData);
        file.write(bmpData, bih.biSizeImage);

        file.close();
        delete[] bmpData;
        std::cout << "Screenshot saved to " << filePath << std::endl;
    } else {
        std::cerr << "Failed to open file: " << filePath << std::endl;
    }

    // Liberar recursos
    DeleteObject(hBitmap);
    DeleteDC(hMemoryDC);
    ReleaseDC(NULL, hScreenDC);
}
