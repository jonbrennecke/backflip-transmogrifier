import CoreVideo
import UIKit

internal func withLockedBaseAddress<T>(
  _ buffer: CVPixelBuffer,
  flags: CVPixelBufferLockFlags = .readOnly,
  _ callback: (CVPixelBuffer) -> T
) -> T {
  CVPixelBufferLockBaseAddress(buffer, flags)
  let ret = callback(buffer)
  CVPixelBufferUnlockBaseAddress(buffer, flags)
  return ret
}

internal func pixelSizeOf<T: Numeric>(buffer: CVPixelBuffer) -> Size<T> {
  return withLockedBaseAddress(buffer) { buffer in
    let width = CVPixelBufferGetWidth(buffer)
    let height = CVPixelBufferGetHeight(buffer)
    return Size<T>(width: T(exactly: width)!, height: T(exactly: height)!)
  }
}

// From https://gist.github.com/cieslak/743f9321834c5a40597afa1634a48343
fileprivate func createBuffer(with image: UIImage) -> CVPixelBuffer? {
  let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
  var pixelBuffer: CVPixelBuffer?
  let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
  guard status == kCVReturnSuccess else {
    return nil
  }

  CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
  let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

  let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
  let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

  context?.translateBy(x: 0, y: image.size.height)
  context?.scaleBy(x: 1.0, y: -1.0)

  UIGraphicsPushContext(context!)
  image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
  UIGraphicsPopContext()
  CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
  return pixelBuffer
}

internal func createBuffer<T>(with _: [T], size: Size<Int>, pixelFormat: OSType) -> CVPixelBuffer? {
  let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
  var buffer: CVPixelBuffer!
  let status = CVPixelBufferCreate(
    kCFAllocatorDefault, size.width, size.height, pixelFormat, attrs, &buffer
  )
  guard status == kCVReturnSuccess else {
    return nil
  }

  return withLockedBaseAddress(buffer, flags: CVPixelBufferLockFlags(rawValue: 0)) { buffer -> CVPixelBuffer? in
    let pixelData = CVPixelBufferGetBaseAddress(buffer)
    return nil
  }
}
