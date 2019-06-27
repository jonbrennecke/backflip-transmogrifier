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
      
      let buffer = HSPixelBuffer<Float32>(pixelBuffer: depthData.depthDataMap)
      let rawDepthPixels: [Float32] = buffer.getPixels(repeating: 0)
      let maxDepth = rawDepthPixels.max() ?? Float32.greatestFiniteMagnitude
      let minDepth = rawDepthPixels.min() ?? Float32.leastNonzeroMagnitude
      
      var depthPixels: [Float32] = buffer.mapPixels(repeating: 0) { pixel -> Float32 in
        return transform(depth: pixel, min: minDepth, max: maxDepth)
      }
      
      guard let outputBuffer = createBuffer(
        with: &depthPixels,
        size: buffer.size,
        bufferType: .depthFloat32
      ) else {
        return
      }

      let imageBuffer = HSImageBuffer(pixelBuffer: HSPixelBuffer<Float32>(pixelBuffer: outputBuffer))
//      let imageBuffer = HSImageBuffer(pixelBuffer: buffer)
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

fileprivate func depthToUInt8(
  depth: Float32, min minDepth: Float32, max maxDepth: Float32
  ) -> UInt8 {
  let normalizedDepth = normalize(depth, min: minDepth, max: maxDepth)
  return UInt8(exactly: (normalizedDepth * 255).rounded())!
}

fileprivate func transform(
  depth: Float32, min minDepth: Float32, max maxDepth: Float32
) -> Float32 {
  if depth.isNaN {
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
    return 0
  }
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
  return depth
}
