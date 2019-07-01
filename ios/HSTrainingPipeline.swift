import Photos
import UIKit

@available(iOS 11.0, *)
@objc
class HSTrainingPipeline: NSObject {
  public enum EffectName: String {
    case faceAwareDepthFilter
  }

  @objc(sharedInstance)
  public static let shared = HSTrainingPipeline()

  // TODO: calls promise.wait so this should be called on a background thread
  @objc
  public func createPipeline(_ request: HSTrainingPipelineRequest) throws {
    if request.assetIDs.count == 0 {
      return
    }

    let images = HSAsyncImageDataIterator(assetIDs: request.assetIDs)
    try images.forEach { promise in
      let data = try promise.wait()

      guard let imageData = HSAuxiliaryImageData(data: data) else {
        return
      }

      // create uniquely named folder for saving images
      guard let folderURL = makeURL(forFolderNamed: makeFolderName()) else {
        return
      }
      try makeFolder(at: folderURL)

      // Generate and save segmentation matte as an image
      let matteImageBuffer = HSImageBuffer(pixelBuffer: imageData.segmentationMatteBuffer)
      if let matteCGImage = matteImageBuffer.makeImage() {
        let image = UIImage(cgImage: matteCGImage)
        try save(image: image, named: "segmentation", in: folderURL)
      }

      // Generate and save depth data as an image
      let depthImageBuffer = HSImageBuffer(pixelBuffer: imageData.depthBuffer)
      if let depthCGImage = depthImageBuffer.makeImage() {
        let image = UIImage(cgImage: depthCGImage)
        try save(image: image, named: "depth", in: folderURL)
      }

      // save original image
      let image = UIImage(cgImage: imageData.image)
      try save(image: image, named: "color", in: folderURL)

//      let buffer = imageData.depthBuffer
//      guard let faceRect = imageData.faceRectangle else {
//        return
//      }
//      let rect = image.toDepthCoords(from: faceRect)
//      let facePixels = buffer.getPixels(in: rect)
//      let averageOfFace = facePixels.reduce(0, +) / Float(facePixels.count)
//      var depthPixels: [Float32] = buffer.getPixels()
//      guard let outputBuffer = createBuffer(
//        with: &depthPixels,
//        size: buffer.size,
//        bufferType: .depthFloat32
//      ) else {
//        return
//      }
//      let imageBuffer = HSImageBuffer(pixelBuffer: HSPixelBuffer<Float32>(pixelBuffer: outputBuffer))
    }
  }
}

fileprivate func makeFolder(at folderURL: URL) throws {
  try? FileManager.default.removeItem(at: folderURL)
  try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: false, attributes: nil)
}

fileprivate func makeURL(forFolderNamed folderName: String) -> URL? {
  guard let folderURL = try? FileManager.default
    .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
    return nil
  }
  return folderURL
    .appendingPathComponent(folderName, isDirectory: true)
}

fileprivate func makeURL(forImageNamed filename: String, in folderURL: URL) -> URL? {
  return folderURL
    .appendingPathComponent(filename)
    .appendingPathExtension("jpg")
}

fileprivate func save(image: UIImage, named fileName: String, in folderURL: URL) throws {
  if let url = makeURL(forImageNamed: fileName, in: folderURL) {
    try image.jpegData(compressionQuality: 1)?.write(to: url)
  }
}

fileprivate func makeFolderName() -> String {
  let random_int = arc4random_uniform(.max)
  return NSString(format: "%x", random_int) as String
}
