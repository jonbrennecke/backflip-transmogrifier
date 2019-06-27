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
      guard let depthData = try createDepthData(withImageData: data) else {
        return
      }
      let buffer = HSPixelBuffer(pixelBuffer: depthData.depthDataMap)
//      let depthPixels: [UInt8] = buffer.mapPixels(repeating: 0) { pixel -> UInt8 in
//        return transformDepth(for: pixel)
//      }
//      let outputBuffer = createBuffer(with: depthPixels, size: buffer.size, pixelFormat: kCVPixelFormatType_OneComponent8)
//      let image = createImage(withPixelBuffer: outputBuffer)

//      createPixelBuffer(with: depthPixels)

      let imageBuffer = HSImageBuffer(pixelBuffer: buffer)
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

// TODO:
fileprivate func transformDepth(for depthValue: Float32) -> UInt8 {
  return UInt8(exactly: depthValue.rounded())!
//  if depthValue.isNaN {
//    // handle unknown values; this is due to the distance between the infrared sensor and receiver
//    for i in stride(from: x, to: x - 25, by: -1) {
//      let depthValue = depthAtIndex(i, y)
//      if depthValue.isNaN {
//        continue;
//      }
//      let depth = normalize(depthValue, min: minDepth, max: maxDepth)
//      if depth < regionRange.lowerBound {
//        setPixel(x, y, 0)
//        return
//      }
//      let adjustedDepth = normalize(depth, min: regionRange.lowerBound, max: regionRange.upperBound)
//      let depthPixelValue = UInt8(adjustedDepth * 255)
//      setPixel(x, y, depthPixelValue)
//      return
//    }
//
//    setPixel(x, y, 0)
//    return
//  }
//  let depth = normalize(depthValue, min: minDepth, max: maxDepth)
//  if depth < regionRange.lowerBound {
//    setPixel(x, y, 0)
//    return
//  }
//  if depth > regionRange.upperBound {
//    setPixel(x, y, 255)
//    return
//  }
//  let adjustedDepth = normalize(depth, min: regionRange.lowerBound, max: regionRange.upperBound)
//  let depthPixelValue = UInt8(adjustedDepth * 255)
//  setPixel(x, y, depthPixelValue)
}
