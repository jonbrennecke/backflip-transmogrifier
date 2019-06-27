import CoreGraphics

struct HSImageBuffer<T: Numeric> {
  typealias PixelValueType = T
  
  private let pixelBuffer: HSPixelBuffer<T>

  init(pixelBuffer: HSPixelBuffer<T>) {
    self.pixelBuffer = pixelBuffer
  }

  public var size: Size<Int> {
    return pixelBuffer.size
  }

  public func makeImage() -> CGImage? {
    return createCGImage(
      pixelValues: pixelBuffer.getBytes(),
      imageSize: size,
      colorSpace: CGColorSpaceCreateDeviceGray(),
      bitmapInfo: bitmapInfo,
      bytesPerPixel: MemoryLayout<T>.size,
      bitsPerComponent: MemoryLayout<T>.size * 8
    )
  }
  
  private var bitmapInfo: CGBitmapInfo {
    switch MemoryLayout<T>.size {
    case 4:
      return CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        .union(.floatComponents)
        .union(.byteOrder32Little)
    case 1:
      fallthrough
    default:
      return CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
    }
  }
}
