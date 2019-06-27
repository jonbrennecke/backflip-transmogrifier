import AVFoundation

struct HSPixelBuffer<T> {
  internal typealias PixelValueType = T
  
  private let buffer: CVPixelBuffer

  public let size: Size<Int>

  init(pixelBuffer buffer: CVPixelBuffer) {
    self.buffer = buffer
    size = pixelSizeOf(buffer: buffer)
  }

  public func forEachPixel(_ callback: (T, Int, Index2D<Int>) -> Void) {
    return withLockedBaseAddress(buffer) { buffer in
      let bytesPerRow = CVPixelBufferGetBytesPerRow(buffer) / MemoryLayout<T>.size
      let ptr = unsafeBitCast(CVPixelBufferGetBaseAddress(buffer), to: UnsafeMutablePointer<T>.self)
      size.forEach { i in
        let pixel = ptr[i.flatIndex(forWidth: bytesPerRow)]
        callback(pixel, i.flatIndex(forWidth: size.width), i)
      }
    }
  }

  public func mapPixels<R>(repeating: R, _ transform: (T) -> R) -> [R] {
    let length = size.width * size.height
    var ret = [R](repeating: repeating, count: length)
    forEachPixel { pixel, i, _ in
      ret[i] = transform(pixel)
    }
    return ret
  }
  
  public func getBytes() -> [UInt8] {
    let length = size.width * size.height * MemoryLayout<T>.size
    var ret = [UInt8](repeating: 0, count: length)
    forEachPixel { pixel, i, _ in
      let index = i * MemoryLayout<T>.size
      var pixel = pixel
      memcpy(&ret[index], &pixel, MemoryLayout<T>.size)
    }
    return ret
  }
  
  public func getPixels(repeating: T) -> [T] {
    return mapPixels(repeating: repeating) { $0 }
  }
}
