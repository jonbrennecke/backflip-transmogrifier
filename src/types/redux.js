/* @flow */
export type State = {};

export type Action<T> = {
  type: string,
  payload?: T,
};

export type Dispatch = any => any;

export type GetState = () => State;

export type AppState = {};
