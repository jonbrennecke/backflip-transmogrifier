// @flow
import { Navigation } from 'react-native-navigation';

import { InitScreen } from './InitScreen';

import type { Element } from 'react';

export const Screens = {
  InitScreen: 'InitScreen',
};

export const screenConfig: { [key: $Keys<typeof Screens>]: Object } = {
  [Screens.InitScreen]: {
    component: {
      name: Screens.InitScreen,
      id: Screens.InitScreen,
      passProps: {},
      options: {
        statusBar: {
          style: 'light',
        },
        topBar: {
          visible: false,
          animate: false,
        },
      },
    },
  },
};

export const registerScreens = (reduxStore: any, ReduxProvider: Element<*>) => {
  Navigation.registerComponentWithRedux(
    Screens.InitScreen,
    () => InitScreen,
    ReduxProvider,
    reduxStore
  );
};

export const setRoot = () => {
  Navigation.setRoot({
    root: screenConfig[Screens.InitScreen],
  });
};
