import Photos
import PromiseKit

struct HSAsyncImageDataIterator {
  enum ImageError: Error {
    case requestImageFailed
  }

  private var assetIDIter: IndexingIterator<[String]>

  init(assetIDs: [String]) {
    assetIDIter = assetIDs.makeIterator()
  }

  private static func fetchPHAsset(with id: String) -> PHAsset? {
    let options = PHFetchOptions()
    options.fetchLimit = 1
    let result = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: options)
    return result.firstObject
  }

  private static func fetchImageData(for asset: PHAsset) -> Promise<Data> {
    return Promise<Data> { seal in
      let options = PHImageRequestOptions()
      options.deliveryMode = .highQualityFormat
      options.isSynchronous = true
      PHImageManager.default()
        .requestImageData(for: asset, options: options) { data, _, _, _ in
          if let data = data {
            seal.fulfill(data)
            return
          }
          seal.reject(ImageError.requestImageFailed)
        }
    }
  }
}

extension HSAsyncImageDataIterator: Sequence, IteratorProtocol {
  mutating func next() -> Promise<Data>? {
    guard
      let assetID = assetIDIter.next(),
      let asset = HSAsyncImageDataIterator.fetchPHAsset(with: assetID)
    else {
      return nil
    }

    return HSAsyncImageDataIterator.fetchImageData(for: asset)
  }
}
