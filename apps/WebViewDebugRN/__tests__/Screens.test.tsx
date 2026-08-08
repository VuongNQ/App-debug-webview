import React from 'react';
import { Alert } from 'react-native';
import ReactTestRenderer from 'react-test-renderer';
import AsyncStorage from '@react-native-async-storage/async-storage';
import Clipboard from '@react-native-clipboard/clipboard';
import ConfigScreen from '../src/screens/ConfigScreen';
import PreviewScreen from '../src/screens/PreviewScreen';
import {
  DEFAULT_CONFIG,
  WEBVIEW_CONFIG_STORAGE_KEY,
} from '../src/config/webViewConfig';

const mockNavigate = jest.fn();
const mockGoBack = jest.fn();
let mockRouteConfig = DEFAULT_CONFIG;

jest.mock('@react-navigation/native', () => ({
  useNavigation: () => ({ navigate: mockNavigate, goBack: mockGoBack }),
  useRoute: () => ({ params: { config: mockRouteConfig } }),
}));

const renderConfig = async () => {
  let renderer: ReactTestRenderer.ReactTestRenderer | undefined;
  await ReactTestRenderer.act(async () => {
    renderer = ReactTestRenderer.create(<ConfigScreen />);
    await new Promise<void>(resolve => setTimeout(resolve, 0));
  });
  return renderer!;
};

const unmount = (renderer: ReactTestRenderer.ReactTestRenderer) => {
  ReactTestRenderer.act(() => renderer.unmount());
};

describe('ConfigScreen', () => {
  beforeEach(async () => {
    jest.clearAllMocks();
    await AsyncStorage.clear();
  });

  it('loads and normalizes partial persisted settings', async () => {
    await AsyncStorage.setItem(
      WEBVIEW_CONFIG_STORAGE_KEY,
      JSON.stringify({
        url: 'http://localhost:3000',
        mixedContentMode: 'compatibility',
      }),
    );

    const renderer = await renderConfig();

    expect(renderer.root.findByProps({ testID: 'url-input' }).props.value).toBe(
      'http://localhost:3000',
    );
    unmount(renderer);
  });

  it('rejects an invalid URL without navigating', async () => {
    const alertSpy = jest.spyOn(Alert, 'alert');
    const renderer = await renderConfig();

    ReactTestRenderer.act(() => {
      renderer.root
        .findByProps({ testID: 'url-input' })
        .props.onChangeText('example.com');
    });
    await ReactTestRenderer.act(async () => {
      await renderer.root
        .findByProps({ testID: 'open-webview-button' })
        .props.onPress();
    });

    expect(alertSpy).toHaveBeenCalledWith(
      'Invalid URL',
      'URL must start with http:// or https://',
    );
    expect(mockNavigate).not.toHaveBeenCalled();
    unmount(renderer);
  });

  it('pastes a valid URL and saves a normalized navigation payload', async () => {
    jest
      .mocked(Clipboard.getString)
      .mockResolvedValueOnce(' http://localhost:8080/debug ');
    const renderer = await renderConfig();

    await ReactTestRenderer.act(async () => {
      await renderer.root
        .findByProps({ testID: 'paste-url-button' })
        .props.onPress();
    });
    await ReactTestRenderer.act(async () => {
      await renderer.root
        .findByProps({ testID: 'open-webview-button' })
        .props.onPress();
    });

    const stored = JSON.parse(
      (await AsyncStorage.getItem(WEBVIEW_CONFIG_STORAGE_KEY)) ?? '{}',
    );
    expect(stored.url).toBe('http://localhost:8080/debug');
    expect(stored.supportZoom).toBe(true);
    expect(mockNavigate).toHaveBeenCalledWith('Preview', {
      config: expect.objectContaining({
        url: 'http://localhost:8080/debug',
        supportZoom: true,
      }),
    });
    unmount(renderer);
  });
});

describe('PreviewScreen', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockRouteConfig = DEFAULT_CONFIG;
  });

  it('maps route config to explicit WebView props', () => {
    let renderer: ReactTestRenderer.ReactTestRenderer | undefined;
    ReactTestRenderer.act(() => {
      renderer = ReactTestRenderer.create(<PreviewScreen />);
    });

    let webView = renderer!.root.findByProps({ testID: 'webview' });
    const initialSource = webView.props.source;
    expect(webView.props.source).toEqual({ uri: DEFAULT_CONFIG.url });
    expect(webView.props.javaScriptEnabled).toBe(true);
    expect(webView.props.mixedContentMode).toBe('never');
    expect(webView.props.setBuiltInZoomControls).toBe(true);
    expect(webView.props.geolocationEnabled).toBe(true);
    expect(webView.props.mediaPlaybackRequiresUserAction).toBe(false);
    expect(webView.props.webviewDebuggingEnabled).toBe(true);
    expect(webView.props.onScroll).toBeUndefined();

    ReactTestRenderer.act(() => {
      webView.props.onLoad();
    });
    webView = renderer!.root.findByProps({ testID: 'webview' });
    expect(webView.props.source).toBe(initialSource);
    unmount(renderer!);
  });

  it('handles in-app bridge navigation and load timeout', () => {
    jest.useFakeTimers();
    const alertSpy = jest.spyOn(Alert, 'alert');
    let renderer: ReactTestRenderer.ReactTestRenderer | undefined;
    ReactTestRenderer.act(() => {
      renderer = ReactTestRenderer.create(<PreviewScreen />);
    });

    let webView = renderer!.root.findByProps({ testID: 'webview' });
    ReactTestRenderer.act(() => {
      webView.props.onMessage({
        nativeEvent: {
          data: JSON.stringify({
            version: 1,
            type: 'openInAppWebView',
            payload: { url: 'https://inside.example' },
          }),
        },
      });
    });
    webView = renderer!.root.findByProps({ testID: 'webview' });
    expect(webView.props.source).toEqual({ uri: 'https://inside.example' });

    ReactTestRenderer.act(() => {
      webView.props.onLoadStart();
      jest.advanceTimersByTime(15000);
    });
    expect(alertSpy).toHaveBeenCalledWith(
      'Page load timed out',
      'Check the URL or network connection and try again.',
    );
    expect(
      renderer!.root.findAllByProps({ children: 'Unable to load the page.' }),
    ).not.toHaveLength(0);

    unmount(renderer!);
    jest.useRealTimers();
  });
});
