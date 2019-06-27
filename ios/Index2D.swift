struct Index2D<T: Numeric> {
  let x: T
  let y: T

  func flatIndex(forWidth width: T) -> T {
    return y * width + x
  }
}
