import Routing
import Vapor
import Foundation
import Leaf
import SwiftGD

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    let rootDirectory = DirectoryConfig.detect().workDir
    let uploadDirectory = URL(fileURLWithPath: "\(rootDirectory)Public/uploads")
    let originalsDirectory = uploadDirectory.appendingPathComponent("originals")
    let thumbsDirectory = uploadDirectory.appendingPathComponent("thumbs")
    
    router.get { req -> Future<View> in
        let fileManager = FileManager()
        guard let files = try? fileManager.contentsOfDirectory(
            at: originalsDirectory,
            includingPropertiesForKeys: nil)
        else {
            throw Abort(.internalServerError)
        }
        
        let validFileNames = files
            .map({ $0.lastPathComponent })
            .filter({ !$0.hasPrefix(".")})
        
        let context = ["files": validFileNames]
        
        return try req.view().render("home", context)
    }
    
    router.post("upload") { req -> Future<Response> in
        struct UserFile: Content {
            var upload: [File]
        }
        
        return try req.content.decode(UserFile.self).map(to: Response.self) { uploadedImages in
            let acceptedTypes = [
                MediaType.png,
                MediaType.jpeg
            ]
            
            for uploadedImage in uploadedImages.upload {
                guard let mimeType = uploadedImage.contentType else { continue }
                guard acceptedTypes.contains(mimeType) else { continue }
                
                let cleanedFilename = uploadedImage.filename.replacingOccurrences(of: " ", with: "-")
                
                //convert to URL
                let originalPath = originalsDirectory.appendingPathComponent(cleanedFilename)
                let _ = try uploadedImage.data.write(to: originalPath)
                
                let thumbPath = thumbsDirectory.appendingPathComponent(cleanedFilename)
                if let image = Image(url: originalPath) {
                    if let resized = image.resizedTo(width: 300) {
                        let _ = resized.write(to: thumbPath)
                    }
                }
            }
            return req.redirect(to: "/")
        }
    }
    
    router.post("delete") { req -> Future<Response> in
        struct FileToDelete: Content {
            var fileName: String
        }
        
        return try req.content.decode(FileToDelete.self).map(to: Response.self) { fileToDelete in
            let fileManager = FileManager()
            
            let originalPath = originalsDirectory.appendingPathComponent(fileToDelete.fileName)
            let thumbsPath = thumbsDirectory.appendingPathComponent(fileToDelete.fileName)
            
            try fileManager.removeItem(at: originalPath)
            try fileManager.removeItem(at: thumbsPath)

            return req.redirect(to: "/")
        }
    }
}
