import {
  createWebViewBootstrapScript,
  parseWebViewBridgeMessage,
} from '../src/webViewBridge';

describe('WebView message bridge', () => {
  it.each([
    [
      'onBackPressed',
      null,
      { version: 1, type: 'onBackPressed', payload: null },
    ],
    [
      'showLandscapeActions',
      { show: false },
      { version: 1, type: 'showLandscapeActions', payload: { show: false } },
    ],
    [
      'rotate',
      { orientation: 'LANDSCAPE' },
      { version: 1, type: 'rotate', payload: { orientation: 'landscape' } },
    ],
    [
      'openExternalApplication',
      { url: 'mailto:test@example.com' },
      {
        version: 1,
        type: 'openExternalApplication',
        payload: { url: 'mailto:test@example.com' },
      },
    ],
    [
      'openInAppWebView',
      { url: 'https://example.com/path' },
      {
        version: 1,
        type: 'openInAppWebView',
        payload: { url: 'https://example.com/path' },
      },
    ],
  ])('accepts %s messages', (type, payload, expected) => {
    expect(
      parseWebViewBridgeMessage(JSON.stringify({ version: 1, type, payload })),
    ).toEqual(expected);
  });

  it.each([
    'not json',
    JSON.stringify(null),
    JSON.stringify({ version: 2, type: 'onBackPressed', payload: null }),
    JSON.stringify({ version: 1, type: 'unknown', payload: null }),
    JSON.stringify({
      version: 1,
      type: 'showLandscapeActions',
      payload: { show: 'yes' },
    }),
    JSON.stringify({
      version: 1,
      type: 'openInAppWebView',
      // eslint-disable-next-line no-script-url
      payload: { url: 'javascript:alert(1)' },
    }),
    JSON.stringify({
      version: 1,
      type: 'openExternalApplication',
      // eslint-disable-next-line no-script-url
      payload: { url: 'javascript:alert(1)' },
    }),
  ])('rejects malformed or unsupported input', data => {
    expect(parseWebViewBridgeMessage(data)).toBeNull();
  });

  it('builds the Flutter compatibility adapter and page settings script', () => {
    const script = createWebViewBootstrapScript({
      iframeAllow: 'camera; microphone',
      enableViewportScale: true,
      ignoresViewportScaleLimits: false,
    });

    expect(script).toContain('window.flutter_inappwebview.callHandler');
    expect(script).toContain('window.ReactNativeWebView.postMessage');
    expect(script).toContain('camera; microphone');
    expect(script).toContain('maximum-scale=5');
    expect(script).toContain('record.addedNodes');
    expect(script).toContain("root.querySelectorAll('iframe')");
    expect(script).not.toContain("document.querySelectorAll('iframe')");
    expect(script).toContain("window.addEventListener('scroll'");
    expect(script).toContain(
      'window.requestAnimationFrame(updateScrollActions)',
    );
    expect(script).toContain('observer.disconnect()');
  });
});
