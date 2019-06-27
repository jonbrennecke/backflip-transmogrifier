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
      
      let buffer = HSPixelBuffer<UInt8>(pixelBuffer: imageData.segmentationMatte.mattingImage)
      let imageBuffer = HSImageBuffer(pixelBuffer: buffer)
      
//      if let image = CIImage(portaitEffectsMatte: imageData.segmentationMatte) {
//        let debugImage = UIImage(ciImage: image)
//        try PHPhotoLibrary.shared().performChangesAndWait {
//          PHAssetChangeRequest.creationRequestForAsset(from: debugImage)
//          UIImageWriteToSavedPhotosAlbum(debugImage, nil, nil, nil)
//        }
//      }
      
//      let buffer = imageData.depthBuffer
      
//      guard let faceRect = imageData.faceRectangle else {
//        return
//      }
//      let rect = image.toDepthCoords(from: faceRect)
//      let facePixels = buffer.getPixels(in: rect)
//      let averageOfFace = facePixels.reduce(0, +) / Float(facePixels.count)
      
//      var depthPixels: [Float32] = buffer.getPixels()
//
//      guard let outputBuffer = createBuffer(
//        with: &depthPixels,
//        size: buffer.size,
//        bufferType: .depthFloat32
//      ) else {
//        return
//      }
//
//      let imageBuffer = HSImageBuffer(pixelBuffer: HSPixelBuffer<Float32>(pixelBuffer: outputBuffer))
      guard let outputCGImage = imageBuffer.makeImage() else {
        return
      }

      // convert to UIImage and save to Photos
      let debugImage = UIImage(cgImage: outputCGImage)
      try PHPhotoLibrary.shared().performChangesAndWait {
        PHAssetChangeRequest.creationRequestForAsset(from: debugImage)
      }
    }
  }
}

// MARK: unused
func guassian(_ x: Float, height a: Float, average b: Float, standardDeviation c: Float) -> Float {
  return a * exp(-pow(x - b, 2) / (2 * pow(c, 2)))
}

// MARK: unused
fileprivate func depthToUInt8(
  depth: Float32, min minDepth: Float32, max maxDepth: Float32
  ) -> UInt8 {
  let normalizedDepth = normalize(depth, min: minDepth, max: maxDepth)
  return UInt8(exactly: (normalizedDepth * 255).rounded())!
}
