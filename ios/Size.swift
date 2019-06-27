struct Size<T: Numeric> {
  let width: T
  let height: T
}

extension Size where T: Comparable & SignedInteger {
  internal func forEach(_ callback: (Index2D<T>) -> Void) {
    for x in stride(from: 0, to: width, by: 1) {
      for y in stride(from: 0, to: height, by: 1) {
        callback(Index2D(x: x, y: y))
      }
    }
  }
}
