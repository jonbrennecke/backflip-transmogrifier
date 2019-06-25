// @flow
import React from 'react';
import { Text, SafeAreaView } from 'react-native';

import type { SFC } from '../../types/react';

export type MediaExplorerProps = {};

const styles = {
  flex: {
    flex: 1,
  },
};

export const MediaExplorer: SFC<MediaExplorerProps> = () => (
  <SafeAreaView style={styles.flex}>
    <Text>Hello world</Text>
  </SafeAreaView>
);
