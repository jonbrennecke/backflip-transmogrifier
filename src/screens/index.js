// @flow
import { Navigation } from 'react-native-navigation';

import { MediaExplorer } from './MediaExplorer';

import type { Element } from 'react';

export const Screens = {
  MediaExplorer: 'MediaExplorer'
};

export const screenConfig: { [key: $Keys<typeof Screens>]: Object } = {
  [Screens.MediaExplorer]: {
    component: {
      name: Screens.MediaExplorer,
      id: Screens.MediaExplorer,
      passProps: {},
      options: {
        statusBar: {
          style: 'light',
        },
        topBar: {
          visible: false,
          animate: false,
        }
      },
    },
  }
};

export const registerScreens = (reduxStore: any, ReduxProvider: Element<*>) => {
  Navigation.registerComponentWithRedux(
    Screens.MediaExplorer,
    () => MediaExplorer,
    ReduxProvider,
    reduxStore
  );
};

export const setRoot = () => {
  Navigation.setRoot({
    root: screenConfig[Screens.MediaExplorer]
  });
}
