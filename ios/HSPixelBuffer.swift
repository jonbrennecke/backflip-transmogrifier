import AVFoundation

struct HSPixelBuffer {
  private let buffer: CVPixelBuffer

  public let size: Size<Int>

  init(pixelBuffer buffer: CVPixelBuffer) {
    self.buffer = buffer
    size = pixelSizeOf(buffer: buffer)
  }

  public func forEachPixel(_ callback: (Float32, Int, Index2D<Int>) -> Void) {
    return withLockedBaseAddress(buffer) { buffer in
      let bytesPerRow = CVPixelBufferGetBytesPerRow(buffer) / MemoryLayout<Float32>.size
      let ptr = unsafeBitCast(CVPixelBufferGetBaseAddress(buffer), to: UnsafeMutablePointer<Float32>.self)
      size.forEach { i in
        let pixel = ptr[i.flatIndex(forWidth: bytesPerRow)]
        callback(pixel, i.flatIndex(forWidth: size.width), i)
      }
    }
  }

  public func getPixels() -> [Float32] {
    return mapPixels(repeating: 0) { $0 }
  }

  public func mapPixels<T>(repeating: T, _ transform: (Float32) -> T) -> [T] {
    let length = size.width * size.height
    var ret = [T](repeating: repeating, count: length)
    forEachPixel { pixel, i, _ in
      ret[i] = transform(pixel)
    }
    return ret
  }

  public func getBytes() -> [UInt8] {
    let length = size.width * size.height * 4
    var pixelValues = [UInt8](repeating: 0, count: length)
    forEachPixel { pixel, i, _ in
      let index = i * 4
      var pixelValue = pixelValues[index]
      var pixel = pixel
      memcpy(&pixelValue, &pixel, 4)
    }
    return pixelValues
  }
}
