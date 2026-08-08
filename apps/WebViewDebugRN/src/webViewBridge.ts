import type { WebViewConfig } from './config/webViewConfig';

export type WebViewBridgeMessage =
  | { version: 1; type: 'onBackPressed'; payload: null }
  | { version: 1; type: 'showLandscapeActions'; payload: { show: boolean } }
  | { version: 1; type: 'rotate'; payload: { orientation: string } }
  | { version: 1; type: 'openExternalApplication'; payload: { url: string } }
  | { version: 1; type: 'openInAppWebView'; payload: { url: string } };

const isRecord = (value: unknown): value is Record<string, unknown> =>
  typeof value === 'object' && value !== null && !Array.isArray(value);

const hasUrlPayload = (value: unknown): value is { url: string } =>
  isRecord(value) && typeof value.url === 'string';

const isExternalUrl = (url: string) =>
  /^[a-z][a-z\d+.-]*:/i.test(url) && !/^(javascript|data|file):/i.test(url);

export const parseWebViewBridgeMessage = (
  data: string,
): WebViewBridgeMessage | null => {
  let message: unknown;
  try {
    message = JSON.parse(data);
  } catch {
    return null;
  }

  if (!isRecord(message) || message.version !== 1) {
    return null;
  }

  switch (message.type) {
    case 'onBackPressed':
      return { version: 1, type: message.type, payload: null };
    case 'showLandscapeActions':
      return isRecord(message.payload) &&
        typeof message.payload.show === 'boolean'
        ? {
            version: 1,
            type: message.type,
            payload: { show: message.payload.show },
          }
        : null;
    case 'rotate':
      return isRecord(message.payload) &&
        typeof message.payload.orientation === 'string'
        ? {
            version: 1,
            type: message.type,
            payload: { orientation: message.payload.orientation.toLowerCase() },
          }
        : null;
    case 'openExternalApplication':
      return hasUrlPayload(message.payload) &&
        isExternalUrl(message.payload.url)
        ? {
            version: 1,
            type: message.type,
            payload: { url: message.payload.url },
          }
        : null;
    case 'openInAppWebView':
      return hasUrlPayload(message.payload) &&
        /^https?:\/\//i.test(message.payload.url)
        ? {
            version: 1,
            type: message.type,
            payload: { url: message.payload.url },
          }
        : null;
    default:
      return null;
  }
};

export const createWebViewBootstrapScript = (
  config: Pick<
    WebViewConfig,
    'iframeAllow' | 'enableViewportScale' | 'ignoresViewportScaleLimits'
  >,
) => `
(function () {
  var iframeAllow = ${JSON.stringify(config.iframeAllow)};
  var applyIframeSettings = function (root) {
    if (!root || root.nodeType !== 1) return;
    if (root.tagName === 'IFRAME') root.setAttribute('allow', iframeAllow);
    if (!root.querySelectorAll) return;
    Array.prototype.forEach.call(root.querySelectorAll('iframe'), function (frame) {
      frame.setAttribute('allow', iframeAllow);
    });
  };
  var applyInitialSettings = function () {
    var viewport = document.querySelector('meta[name="viewport"]');
    if (!viewport) {
      viewport = document.createElement('meta');
      viewport.setAttribute('name', 'viewport');
      document.head && document.head.appendChild(viewport);
    }
    if (viewport) {
      viewport.setAttribute(
        'content',
        ${JSON.stringify(
          config.enableViewportScale
            ? `width=device-width, initial-scale=1, user-scalable=yes, maximum-scale=${
                config.ignoresViewportScaleLimits ? '10' : '5'
              }`
            : 'width=device-width, initial-scale=1, user-scalable=no',
        )}
      );
    }
    applyIframeSettings(document.documentElement);
  };
  var postMessage = function (type, payload) {
    window.ReactNativeWebView.postMessage(JSON.stringify({
      version: 1,
      type: type,
      payload: payload
    }));
  };

  window.flutter_inappwebview = window.flutter_inappwebview || {};
  window.flutter_inappwebview.callHandler = function (handlerName) {
    var args = Array.prototype.slice.call(arguments, 1);
    var payload = null;
    if (handlerName === 'showLandscapeActions') payload = { show: Boolean(args[0]) };
    if (handlerName === 'rotate') payload = { orientation: String(args[0] || '') };
    if (handlerName === 'openExternalApplication' || handlerName === 'openInAppWebView') {
      payload = { url: String(args[0] || '') };
    }
    postMessage(handlerName, payload);
    return Promise.resolve(null);
  };

  var actionsVisible = true;
  var lastScrollY = window.scrollY || 0;
  var scrollFramePending = false;
  var updateScrollActions = function () {
    scrollFramePending = false;
    var currentY = window.scrollY || document.documentElement.scrollTop || 0;
    var delta = currentY - lastScrollY;
    var shouldShow = actionsVisible;
    if (currentY <= 0 || delta < -10) shouldShow = true;
    else if (delta > 10) shouldShow = false;
    if (shouldShow !== actionsVisible) {
      actionsVisible = shouldShow;
      postMessage('showLandscapeActions', { show: shouldShow });
    }
    if (Math.abs(delta) > 10 || currentY <= 0) lastScrollY = currentY;
  };
  window.addEventListener('scroll', function () {
    if (scrollFramePending) return;
    scrollFramePending = true;
    window.requestAnimationFrame(updateScrollActions);
  }, { passive: true });

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', applyInitialSettings, { once: true });
  } else {
    applyInitialSettings();
  }
  var observer = new MutationObserver(function (records) {
    Array.prototype.forEach.call(records, function (record) {
      Array.prototype.forEach.call(record.addedNodes, applyIframeSettings);
    });
  });
  observer.observe(document.documentElement, {
    childList: true,
    subtree: true
  });
  window.addEventListener('pagehide', function () {
    observer.disconnect();
  }, { once: true });
})();
true;
`;
