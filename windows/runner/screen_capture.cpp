#include "pch.h"
#include <Windows.h>
#include <iostream>
#include <stdio.h>

extern "C" __declspec(dllexport) void captureScreen(const char* filePath) {
    // Obtener el tamaño de la pantalla
    int screenX = GetSystemMetrics(SM_CXSCREEN);
    int screenY = GetSystemMetrics(SM_CYSCREEN);

    // Crear un dispositivo compatible con el DC de la pantalla
    HDC hScreenDC = GetDC(NULL);
    HDC hMemoryDC = CreateCompatibleDC(hScreenDC);
    HBITMAP hBitmap = CreateCompatibleBitmap(hScreenDC, screenX, screenY);
    SelectObject(hMemoryDC, hBitmap);

    // Inicializar los encabezados BMP
    BITMAPFILEHEADER bfHeader;
    BITMAPINFOHEADER biHeader;

    // Inicializar el contenido del bitmap
    biHeader.biSize = sizeof(BITMAPINFOHEADER);
    biHeader.biWidth = screenX;
    biHeader.biHeight = -screenY; // Altura negativa para evitar imagen invertida
    biHeader.biPlanes = 1;
    biHeader.biBitCount = 24; // Guardar la imagen en 24 bits (RGB)
    biHeader.biCompression = BI_RGB;
    biHeader.biSizeImage = 0;
    biHeader.biXPelsPerMeter = 0;
    biHeader.biYPelsPerMeter = 0;
    biHeader.biClrUsed = 0;
    biHeader.biClrImportant = 0;

    // Establecer el tipo de archivo BMP
    bfHeader.bfType = 0x4D42;  // "BM"
    bfHeader.bfOffBits = sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER);
    bfHeader.bfSize = bfHeader.bfOffBits + (screenX * screenY * 3); // Tamaño total del archivo
    bfHeader.bfReserved1 = 0;
    bfHeader.bfReserved2 = 0;

    // Obtener los datos del bitmap
    BYTE* pPixels = new BYTE[screenX * screenY * 3]; // Buffer para los píxeles
    if (GetDIBits(hMemoryDC, hBitmap, 0, screenY, pPixels, (BITMAPINFO*)&biHeader, DIB_RGB_COLORS) == 0) {
        std::cerr << "Error al obtener los bits del bitmap." << std::endl;
        delete[] pPixels;
        return;
    }

    // Guardar el archivo en el path especificado
    FILE* file;
    fopen_s(&file, filePath, "wb");

    if (file != NULL) {
        // Escribir el encabezado del archivo BMP
        fwrite(&bfHeader, sizeof(BITMAPFILEHEADER), 1, file);
        fwrite(&biHeader, sizeof(BITMAPINFOHEADER), 1, file);

        // Escribir los datos de la imagen (píxeles)
        fwrite(pPixels, screenX * screenY * 3, 1, file);

        // Cerrar el archivo
        fclose(file);
    } else {
        std::cerr << "Error al abrir el archivo para escritura." << std::endl;
    }

    // Liberar recursos
    delete[] pPixels;
    DeleteObject(hBitmap);
    DeleteDC(hMemoryDC);
    ReleaseDC(NULL, hScreenDC);

    std::cout << "BMP capturado y guardado correctamente en: " << filePath << std::endl;
}
