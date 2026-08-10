/* eslint-env jest */

jest.mock('@react-native-async-storage/async-storage', () =>
  require('@react-native-async-storage/async-storage/jest/async-storage-mock'),
);

jest.mock('@react-native-clipboard/clipboard', () => ({
  __esModule: true,
  default: {
    getString: jest.fn(async () => ''),
  },
}));

jest.mock('react-native-permissions', () => ({
  PERMISSIONS: {
    ANDROID: { CAMERA: 'android.permission.CAMERA' },
    IOS: { CAMERA: 'ios.permission.CAMERA' },
  },
  RESULTS: { GRANTED: 'granted' },
  request: jest.fn(async () => 'granted'),
}));

jest.mock('react-native-camera-kit', () => {
  const React = require('react');
  const { View } = require('react-native');
  return {
    Camera: props =>
      React.createElement(View, { ...props, testID: 'qr-camera' }),
    CameraType: { Back: 'back', Front: 'front' },
  };
});

jest.mock('react-native-webview', () => {
  const React = require('react');
  const { View } = require('react-native');
  const MockWebView = React.forwardRef((props, ref) => {
    React.useImperativeHandle(ref, () => ({
      goBack: jest.fn(),
      goForward: jest.fn(),
      reload: jest.fn(),
    }));
    return React.createElement(View, { ...props, testID: 'webview' });
  });

  return {
    __esModule: true,
    default: MockWebView,
    WebView: MockWebView,
  };
});
