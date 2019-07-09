// @flow
import React from 'react';
import { SafeAreaView, View, Button } from 'react-native';

import { wrapWithInitScreenState } from './initScreenState';

import type { SFC } from '../../types/react';

export type InitScreenProps = {
  onRequestProcessImages: () => void,
};

const styles = {
  flex: {
    flex: 1,
  },
  centerContent: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
};

export const InitScreenComponent: SFC<InitScreenProps> = ({
  isTraining,
  onRequestProcessImages,
}: InitScreenProps) => (
  <SafeAreaView style={styles.flex}>
    <View style={styles.centerContent}>
      <Button title="Process images" onPress={onRequestProcessImages} disabled={isTraining} />
    </View>
  </SafeAreaView>
);

export const InitScreen = wrapWithInitScreenState(InitScreenComponent);
