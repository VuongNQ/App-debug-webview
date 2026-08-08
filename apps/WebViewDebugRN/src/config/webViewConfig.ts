export const WEBVIEW_CONFIG_STORAGE_KEY = '@webview_config';

export type MixedContentMode = 'never' | 'always' | 'compatibility';

export interface WebViewConfig {
  url: string;
  javaScriptEnabled: boolean;
  domStorageEnabled: boolean;
  debuggingEnabled: boolean;
  userAgent: string;
  allowFileAccess: boolean;
  mixedContentMode: MixedContentMode;
  supportZoom: boolean;
  enableViewportScale: boolean;
  ignoresViewportScaleLimits: boolean;
  displayZoomControls: boolean;
  useWideViewPort: boolean;
  loadWithOverviewMode: boolean;
  useOnLoadResource: boolean;
  geolocationEnabled: boolean;
  javaScriptCanOpenWindowsAutomatically: boolean;
  allowUniversalAccessFromFileURLs: boolean;
  allowFileAccessFromFileURLs: boolean;
  mediaPlaybackRequiresUserGesture: boolean;
  allowsInlineMediaPlayback: boolean;
  iframeAllow: string;
  applicationNameForUserAgent: string;
  transparentBackground: boolean;
}

export const DEFAULT_CONFIG: WebViewConfig = {
  url: 'https://example.com',
  javaScriptEnabled: true,
  domStorageEnabled: true,
  debuggingEnabled: true,
  userAgent: '',
  allowFileAccess: false,
  mixedContentMode: 'never',
  supportZoom: true,
  enableViewportScale: true,
  ignoresViewportScaleLimits: true,
  displayZoomControls: false,
  useWideViewPort: true,
  loadWithOverviewMode: true,
  useOnLoadResource: true,
  geolocationEnabled: true,
  javaScriptCanOpenWindowsAutomatically: true,
  allowUniversalAccessFromFileURLs: true,
  allowFileAccessFromFileURLs: true,
  mediaPlaybackRequiresUserGesture: false,
  allowsInlineMediaPlayback: true,
  iframeAllow:
    'camera; microphone; clipboard-write; geolocation; web-share; fullscreen',
  applicationNameForUserAgent: '',
  transparentBackground: false,
};

const isRecord = (value: unknown): value is Record<string, unknown> =>
  typeof value === 'object' && value !== null && !Array.isArray(value);

export const normalizeWebViewConfig = (value: unknown): WebViewConfig => {
  if (!isRecord(value)) {
    return { ...DEFAULT_CONFIG };
  }

  const stringValue = <Key extends keyof WebViewConfig>(key: Key) =>
    typeof value[key] === 'string'
      ? (value[key] as string)
      : DEFAULT_CONFIG[key];
  const booleanValue = <Key extends keyof WebViewConfig>(key: Key) =>
    typeof value[key] === 'boolean'
      ? (value[key] as boolean)
      : DEFAULT_CONFIG[key];
  const mixedContentMode = value.mixedContentMode;

  return {
    url: stringValue('url'),
    javaScriptEnabled: booleanValue('javaScriptEnabled'),
    domStorageEnabled: booleanValue('domStorageEnabled'),
    debuggingEnabled: booleanValue('debuggingEnabled'),
    userAgent: stringValue('userAgent'),
    allowFileAccess: booleanValue('allowFileAccess'),
    mixedContentMode:
      mixedContentMode === 'never' ||
      mixedContentMode === 'always' ||
      mixedContentMode === 'compatibility'
        ? mixedContentMode
        : DEFAULT_CONFIG.mixedContentMode,
    supportZoom: booleanValue('supportZoom'),
    enableViewportScale: booleanValue('enableViewportScale'),
    ignoresViewportScaleLimits: booleanValue('ignoresViewportScaleLimits'),
    displayZoomControls: booleanValue('displayZoomControls'),
    useWideViewPort: booleanValue('useWideViewPort'),
    loadWithOverviewMode: booleanValue('loadWithOverviewMode'),
    useOnLoadResource: booleanValue('useOnLoadResource'),
    geolocationEnabled: booleanValue('geolocationEnabled'),
    javaScriptCanOpenWindowsAutomatically: booleanValue(
      'javaScriptCanOpenWindowsAutomatically',
    ),
    allowUniversalAccessFromFileURLs: booleanValue(
      'allowUniversalAccessFromFileURLs',
    ),
    allowFileAccessFromFileURLs: booleanValue('allowFileAccessFromFileURLs'),
    mediaPlaybackRequiresUserGesture: booleanValue(
      'mediaPlaybackRequiresUserGesture',
    ),
    allowsInlineMediaPlayback: booleanValue('allowsInlineMediaPlayback'),
    iframeAllow: stringValue('iframeAllow'),
    applicationNameForUserAgent: stringValue('applicationNameForUserAgent'),
    transparentBackground: booleanValue('transparentBackground'),
  };
};

export const parseStoredWebViewConfig = (stored: string): WebViewConfig => {
  try {
    return normalizeWebViewConfig(JSON.parse(stored));
  } catch {
    return { ...DEFAULT_CONFIG };
  }
};
