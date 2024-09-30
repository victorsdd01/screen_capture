// import Cocoa
// import QuartzCore

// @_cdecl("captureScreen")
// public func captureScreen(_ filePath: UnsafePointer<CChar>, _ x: Int32, _ y: Int32, _ width: Int32, _ height: Int32) {
//     let pathString = String(cString: filePath)

//     // Obtener la carpeta de Application Support para la app
//     if let appSupportPath = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
        
//         // Crear una carpeta personalizada para tu app si no existe
//         let folderPath = appSupportPath.appendingPathComponent("com.example.screenshotPlayground")
//         try? FileManager.default.createDirectory(at: folderPath, withIntermediateDirectories: true, attributes: nil)
        
//         // Ruta completa con el nombre de archivo
//         let fullPath = folderPath.appendingPathComponent(pathString)
        
//         print("Full path for screenshot: \(fullPath.path)")

//         // Definir la región específica para capturar
//         let captureRect = CGRect(x: Int(x), y: Int(y), width: Int(width), height: Int(height))

//         // Captura la imagen de la región definida
//         if let screenshot = CGWindowListCreateImage(captureRect, .optionOnScreenOnly, kCGNullWindowID, .bestResolution) {
//             let bitmapRep = NSBitmapImageRep(cgImage: screenshot)
//             let pngData = bitmapRep.representation(using: .png, properties: [:])
            
//             // Escribir la imagen a un archivo
//             do {
//                 try pngData?.write(to: fullPath)
//                 print("Screenshot saved to \(fullPath.path)")
//             } catch {
//                 print("Failed to save screenshot: \(error)")
//             }
//         }
//     }
// }

import Cocoa
import QuartzCore

@_cdecl("captureScreen")
public func captureScreen(_ filePath: UnsafePointer<CChar>, _ x: Int32, _ y: Int32, _ width: Int32, _ height: Int32) {
    // Convertir el puntero a cadena de caracteres
    let pathString = String(cString: filePath)

    // Solo debes concatenar la parte relativa al directorio temporal
    let fullPath = URL(fileURLWithPath: pathString)

    print("Full path for screenshot (temp directory): \(fullPath.path)")

    // Definir la región específica para capturar
    let captureRect = CGRect(x: Int(x), y: Int(y), width: Int(width), height: Int(height))

    // Captura la imagen de la región definida
    if let screenshot = CGWindowListCreateImage(captureRect, .optionOnScreenOnly, kCGNullWindowID, .bestResolution) {
        let bitmapRep = NSBitmapImageRep(cgImage: screenshot)
        let pngData = bitmapRep.representation(using: .png, properties: [:])

        // Escribir la imagen a un archivo en el directorio temporal
        do {
            try pngData?.write(to: fullPath)
            print("Screenshot saved to \(fullPath.path)")
        } catch {
            print("Failed to save screenshot: \(error)")
        }
    }
}
