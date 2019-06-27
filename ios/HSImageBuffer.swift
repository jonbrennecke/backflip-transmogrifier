import CoreGraphics

struct HSImageBuffer {
  private let pixelBuffer: HSPixelBuffer

  init(pixelBuffer: HSPixelBuffer) {
    self.pixelBuffer = pixelBuffer
  }

  public var size: Size<Int> {
    return pixelBuffer.size
  }

  // TODO: this currently only works for grayscale images with Float32 components
  public func makeImage() -> CGImage? {
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
      .union(.floatComponents)
      .union(.byteOrder32Little)
    return createCGImage(
      pixelValues: pixelBuffer.getPixels(),
      imageSize: size,
      colorSpace: CGColorSpaceCreateDeviceGray(),
      bitmapInfo: bitmapInfo,
      bytesPerPixel: MemoryLayout<Float32>.size,
      bitsPerComponent: MemoryLayout<Float32>.size * 8
    )
  }
}
