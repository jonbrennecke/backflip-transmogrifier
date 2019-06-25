// @flow
import StyleSheetPropType from 'react-native/Libraries/StyleSheet/StyleSheetPropType';
import ViewStylePropTypes from 'react-native/Libraries/Components/View/ViewStylePropTypes';

import type {
  Element,
  ChildrenArray,
  StatelessFunctionalComponent,
} from 'react';

export type Children = ChildrenArray<?Element<*>> | string;

const stylePropType = StyleSheetPropType(ViewStylePropTypes);

export type Style = stylePropType;

export type SFC<P> = StatelessFunctionalComponent<P>;
