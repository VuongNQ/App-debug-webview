import {
  DEFAULT_CONFIG,
  normalizeWebViewConfig,
  parseStoredWebViewConfig,
} from '../src/config/webViewConfig';

describe('WebView config persistence', () => {
  it('matches the Flutter behavior defaults while preserving RN options', () => {
    expect(DEFAULT_CONFIG).toMatchObject({
      url: 'https://example.com',
      javaScriptEnabled: true,
      domStorageEnabled: true,
      debuggingEnabled: true,
      mixedContentMode: 'never',
      allowFileAccess: false,
      supportZoom: true,
      enableViewportScale: true,
      ignoresViewportScaleLimits: true,
      geolocationEnabled: true,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      transparentBackground: false,
    });
  });

  it('merges a partial stored config with current defaults', () => {
    const config = parseStoredWebViewConfig(
      JSON.stringify({
        url: 'http://localhost:3000',
        javaScriptEnabled: false,
        mixedContentMode: 'compatibility',
      }),
    );

    expect(config.url).toBe('http://localhost:3000');
    expect(config.javaScriptEnabled).toBe(false);
    expect(config.mixedContentMode).toBe('compatibility');
    expect(config.iframeAllow).toBe(DEFAULT_CONFIG.iframeAllow);
    expect(config.supportZoom).toBe(true);
  });

  it('replaces invalid field values without trusting parsed JSON', () => {
    const config = normalizeWebViewConfig({
      url: 42,
      domStorageEnabled: 'yes',
      mixedContentMode: 'unsafe',
      iframeAllow: ['camera'],
      transparentBackground: true,
    });

    expect(config.url).toBe(DEFAULT_CONFIG.url);
    expect(config.domStorageEnabled).toBe(DEFAULT_CONFIG.domStorageEnabled);
    expect(config.mixedContentMode).toBe(DEFAULT_CONFIG.mixedContentMode);
    expect(config.iframeAllow).toBe(DEFAULT_CONFIG.iframeAllow);
    expect(config.transparentBackground).toBe(true);
  });

  it('falls back to defaults for malformed or non-object JSON', () => {
    expect(parseStoredWebViewConfig('{broken')).toEqual(DEFAULT_CONFIG);
    expect(parseStoredWebViewConfig('null')).toEqual(DEFAULT_CONFIG);
    expect(parseStoredWebViewConfig('[]')).toEqual(DEFAULT_CONFIG);
  });
});
