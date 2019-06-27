import Foundation

@available(iOS 11.0, *)
@objc
class HSTrainingPipelineRequest: NSObject {
  public let assetIDs: [String]
  public let effects: [HSTrainingPipeline.EffectName]

  internal init(assetIDs: [String], effects: [HSTrainingPipeline.EffectName]) {
    self.assetIDs = assetIDs
    self.effects = effects
  }

  @objc
  public convenience init?(withDict dict: NSDictionary) {
    guard
      let assetIDs = dict["assetIDs"] as? [String],
      let effectNames = dict["effects"] as? [String]
    else {
      return nil
    }
    let optionalEffects = effectNames.map { HSTrainingPipeline.EffectName(rawValue: $0) }
    for case .none in optionalEffects {
      return nil
    }
    let effects = optionalEffects.compactMap { $0 }
    self.init(assetIDs: assetIDs, effects: effects)
  }
}
