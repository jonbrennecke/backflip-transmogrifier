import AVFoundation

@available(iOS 11.0, *)
internal func createDepthData(with data: Data) throws -> AVDepthData? {
  guard
    let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
    case .statusComplete = CGImageSourceGetStatus(imageSource),
    CGImageSourceGetCount(imageSource) > 0
  else {
    return nil
  }

  if
    let disparityInfo = CGImageSourceCopyAuxiliaryDataInfoAtIndex(
      imageSource, 0, kCGImageAuxiliaryDataTypeDisparity
    ) as? [AnyHashable: Any],
    let depthData = try? AVDepthData(fromDictionaryRepresentation: disparityInfo) {
    return depthData.converting(toDepthDataType: kCVPixelFormatType_DepthFloat32)
  }

  if
    let depthInfo = CGImageSourceCopyAuxiliaryDataInfoAtIndex(
      imageSource, 0, kCGImageAuxiliaryDataTypeDepth
    ) as? [AnyHashable: Any],
    let depthData = try? AVDepthData(fromDictionaryRepresentation: depthInfo) {
    return depthData
  }

  return nil
}
