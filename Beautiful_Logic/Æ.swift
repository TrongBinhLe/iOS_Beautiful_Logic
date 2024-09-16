
import Foundation
import Photos

struct FileFormatConverter {
    
    private func validatePath(path: String) -> String {
        guard path.hasPrefix("file://") else {
            return "file://" + path
        }
        return path
    }
    
    private func getImage(path: URL) -> UIImage? {
        let getData: (URL) -> Data? = { path in
            do {
                return try Data(contentsOf: path)
            } catch {
                OALogError(error.localizedDescription)
                return nil
            }
        }
        
        guard
            let data = getData(path),
            let image = UIImage(data: data)
        else {
            return nil
        }
        
        return image
    }
    
    func getImageSize(path: String) throws -> CGSize {
        guard
            let srcUrl = URL(string: path),
            let srcImg = getImage(path: srcUrl)
        else {
            throw TraceError(message: "failed to get image")
        }
        
        return CGSize(width: srcImg.width, height: srcImg.height)
    }
        
    func convertToJPG(path: String, targetSize: CGSize) throws -> String {
        guard
            let srcUrl = URL(string: path),
            var srcImg = getImage(path: srcUrl)
        else {
            throw TraceError(message: "failed to get image")
        }
        
        if targetSize.width != 0 && targetSize.height != 0 {
            srcImg = srcImg.resizeImage(targetSize: targetSize)
            OALogDebug("resized to \(targetSize)")
        } else {
            srcImg = srcImg.recreateImage() ?? srcImg
        }
        
        guard
            let jpgData = srcImg.jpegData(compressionQuality: 0.8)
        else {
            throw TraceError(message: "failed to convert to JPG")
        }
//        printImageMetaData(forImage: jpgData)
        do {
            let tgtPath = srcUrl.deletingPathExtension().appendingPathExtension("converted.JPG")
            try jpgData.write(to: tgtPath)
            return tgtPath.absoluteString
        } catch {
            throw TraceError(message: error.localizedDescription)
        }
    }
    
// printImageMetaData
    func printImageMetaData(forImage imageData: Data) {
        let data = imageData
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return}

        if let type = CGImageSourceGetType(source) {
            OALogDebug("type: \(type)")
        }

        if let properties = CGImageSourceCopyProperties(source, nil) {
            OALogDebug("properties - \(properties)")
        }

        let count = CGImageSourceGetCount(source)
        OALogDebug("count: \(count)")

        for index in 0..<count {
            if let metaData = CGImageSourceCopyMetadataAtIndex(source, index, nil) {
                OALogDebug("all metaData[\(index)]: \(metaData)")

                let typeId = CGImageMetadataGetTypeID()
                OALogDebug("metadata typeId[\(index)]: \(typeId)")


                if let tags = CGImageMetadataCopyTags(metaData) as? [CGImageMetadataTag] {

                    OALogDebug("number of tags - \(tags.count)")

                    for tag in tags {

                        let tagType = CGImageMetadataTagGetTypeID()
                        if let name = CGImageMetadataTagCopyName(tag) {
                            OALogDebug("name: \(name)")
                            OALogDebug("name: \(tagType)")
                        }
                        if let value = CGImageMetadataTagCopyValue(tag) {
                            OALogDebug("value: \(value)")
                        }
                        if let prefix = CGImageMetadataTagCopyPrefix(tag) {
                            OALogDebug("prefix: \(prefix)")
                        }
                        OALogDebug("-------")
                    }
                }
            }

            if let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) {
                OALogDebug("properties[\(index)]: \(properties)")
            }
        }
    }
    
    func convertToPNG(path: String, targetSize: CGSize) throws -> String {
        guard
            let srcUrl = URL(string: path),
            var srcImg = getImage(path: srcUrl)
        else {
            throw TraceError(message: "failed to get image")
        }
        
        if targetSize.width != 0 && targetSize.height != 0 {
            srcImg = srcImg.resizeImage(targetSize: targetSize)
            OALogDebug("resized to \(targetSize)")
        }
        
        guard
            let pngData = srcImg.pngData()
        else {
            throw TraceError(message: "failed to convert to JPG")
        }
        
        do {
            let tgtPath = srcUrl.deletingPathExtension().appendingPathExtension("converted.PNG")
            try pngData.write(to: tgtPath)
            return tgtPath.absoluteString
        } catch {
            throw TraceError(message: error.localizedDescription)
        }
    }
    
}
