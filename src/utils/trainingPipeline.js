// @flow
import Bluebird from 'bluebird';
import { NativeModules } from 'react-native';

const { HSTrainingPipeline: NativeTrainingPipeline } = NativeModules;
const TrainingPipeline = Bluebird.promisifyAll(NativeTrainingPipeline);

export const TrainingPipelineEffects = {
  faceAwareDepthFilter: 'faceAwareDepthFilter',
};

export type TrainingPipelineRequest = {
  assetIDs: string[],
  effects: $Keys<typeof TrainingPipelineEffects>[],
};

export const createTrainingPipeline = async ({
  assetIDs,
  effects,
}: TrainingPipelineRequest) => {
  const success = await TrainingPipeline.createPipelineAsync({
    assetIDs,
    effects,
  });
  console.log('training pipeline success: ', success);
};
