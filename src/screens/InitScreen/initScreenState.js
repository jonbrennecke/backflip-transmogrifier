// @flow
import React, { PureComponent } from 'react';
import { Alert } from 'react-native';
import { autobind } from 'core-decorators';
import {
  createMediaStateHOC,
  authorizeMediaLibrary,
} from '@jonbrennecke/react-native-media';

import { Albums } from '../../constants';
import { createTrainingPipeline, TrainingPipelineEffects } from '../../utils';

import type { ComponentType } from 'react';
import type { MediaStateHOCProps } from '@jonbrennecke/react-native-media';

export type InitScreenExtraProps = {
  onRequestProcessImages: () => void,
};

export type InitScreenState = {};

export function wrapWithInitScreenState<
  PassThroughProps: Object,
  C: ComponentType<InitScreenExtraProps & MediaStateHOCProps & PassThroughProps>
>(WrappedComponent: C): ComponentType<PassThroughProps> {
  // $FlowFixMe
  @autobind
  class InitScreenStateProvider extends PureComponent<
    MediaStateHOCProps & PassThroughProps,
    InitScreenState
  > {
    state = {};

    async componentDidMount() {
      await authorizeMediaLibrary();
    }

    async processImages() {
      const success = await this.loadImagesForProcessing();
      if (!success) {
        Alert.alert('No images', 'No images could be found for training');
      }
      const assetIDs = this.props.albumAssets
        .valueSeq()
        .flatMap(a => a.assetIDs)
        .toArray();
      await createTrainingPipeline({
        assetIDs,
        effects: [TrainingPipelineEffects.faceAwareDepthFilter],
      });
    }

    async loadImagesForProcessing(): Promise<boolean> {
      await this.props.queryAlbums({
        titleQuery: {
          title: Albums.TrainingQueue,
          equation: 'eq',
        },
      });
      const queueAlbum = this.props.albums.find(
        album => album.title === Albums.TrainingQueue
      );
      if (!queueAlbum) {
        return false;
      }
      await this.props.queryMedia({
        albumID: queueAlbum.albumID,
      });
      return true;
    }

    render() {
      return (
        <WrappedComponent
          {...this.props}
          {...this.state}
          onRequestProcessImages={this.processImages}
        />
      );
    }
  }

  const withMediaState = createMediaStateHOC(state => state.media);

  const Component = withMediaState(InitScreenStateProvider);

  const WrappedWithMediaState = props => <Component {...props} />;

  return WrappedWithMediaState;
}
