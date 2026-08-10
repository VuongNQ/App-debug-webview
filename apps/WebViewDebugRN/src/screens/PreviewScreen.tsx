import React, {
  useCallback,
  useEffect,
  useMemo,
  useRef,
  useState,
} from 'react';
import {
  ActivityIndicator,
  Alert,
  Animated,
  BackHandler,
  Linking,
  Platform,
  StatusBar,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';
import WebView from 'react-native-webview';
import { useNavigation, useRoute } from '@react-navigation/native';
import type { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RouteProp } from '@react-navigation/native';
import type {
  WebViewErrorEvent,
  WebViewMessageEvent,
  WebViewNavigation,
  WebViewSharedProps,
} from 'react-native-webview/lib/WebViewTypes';
import type { RootStackParamList } from '../types';
import {
  createWebViewBootstrapScript,
  parseWebViewBridgeMessage,
} from '../webViewBridge';

type NavProp = NativeStackNavigationProp<RootStackParamList, 'Preview'>;
type RoutePropType = RouteProp<RootStackParamList, 'Preview'>;

type WebViewHandle = {
  goBack: () => void;
  goForward: () => void;
  reload: () => void;
};

type PreviewWebViewProps = WebViewSharedProps & {
  ref?: React.Ref<WebViewHandle>;
  allowFileAccess?: boolean;
  allowFileAccessFromFileURLs?: boolean;
  allowUniversalAccessFromFileURLs?: boolean;
  allowsInlineMediaPlayback?: boolean;
  domStorageEnabled?: boolean;
  geolocationEnabled?: boolean;
  mixedContentMode?: 'never' | 'always' | 'compatibility';
  scalesPageToFit?: boolean;
  setBuiltInZoomControls?: boolean;
  setDisplayZoomControls?: boolean;
  userAgent?: string;
};

const TypedWebView =
  WebView as unknown as React.ComponentType<PreviewWebViewProps>;
const MemoizedWebView = React.memo(TypedWebView);

const PreviewScreen: React.FC = () => {
  const navigation = useNavigation<NavProp>();
  const route = useRoute<RoutePropType>();
  const { config } = route.params;
  const webViewRef = useRef<WebViewHandle>(null);
  const loadTimeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const controlsAnimation = useRef(new Animated.Value(1)).current;
  const [sourceUrl, setSourceUrl] = useState(config.url);
  const [currentUrl, setCurrentUrl] = useState(config.url);
  const [loading, setLoading] = useState(true);
  const [loadFailed, setLoadFailed] = useState(false);
  const [canGoBack, setCanGoBack] = useState(false);
  const [canGoForward, setCanGoForward] = useState(false);
  const [showFloatingActions, setShowFloatingActions] = useState(true);

  const clearLoadTimeout = useCallback(() => {
    if (loadTimeoutRef.current) {
      clearTimeout(loadTimeoutRef.current);
      loadTimeoutRef.current = null;
    }
  }, []);

  const handleBackAction = useCallback(() => {
    if (canGoBack) {
      webViewRef.current?.goBack();
      return;
    }
    navigation.goBack();
  }, [canGoBack, navigation]);

  useEffect(() => {
    StatusBar.setHidden(true, 'fade');

    return () => {
      clearLoadTimeout();
      StatusBar.setHidden(false, 'fade');
    };
  }, [clearLoadTimeout]);

  useEffect(() => {
    const subscription = BackHandler.addEventListener(
      'hardwareBackPress',
      () => {
        handleBackAction();
        return true;
      },
    );

    return () => {
      subscription.remove();
    };
  }, [handleBackAction]);

  useEffect(() => {
    Animated.timing(controlsAnimation, {
      toValue: showFloatingActions ? 1 : 0,
      duration: 220,
      useNativeDriver: true,
    }).start();
  }, [controlsAnimation, showFloatingActions]);

  const startLoadTimeout = useCallback(() => {
    clearLoadTimeout();
    loadTimeoutRef.current = setTimeout(() => {
      setLoading(false);
      setLoadFailed(true);
      Alert.alert(
        'Page load timed out',
        'Check the URL or network connection and try again.',
      );
    }, 15000);
  }, [clearLoadTimeout]);

  const handleLoadStart = useCallback(() => {
    setLoading(true);
    setLoadFailed(false);
    startLoadTimeout();
  }, [startLoadTimeout]);

  const handleLoadSuccess = useCallback(() => {
    clearLoadTimeout();
    setLoading(false);
    setLoadFailed(false);
  }, [clearLoadTimeout]);

  const handleLoadError = useCallback(
    (event: WebViewErrorEvent) => {
      clearLoadTimeout();
      setLoading(false);
      setLoadFailed(true);
      Alert.alert(
        'WebView Error',
        `${event.nativeEvent.description} (${event.nativeEvent.code})`,
      );
    },
    [clearLoadTimeout],
  );

  const handleNavigationChange = useCallback((navState: WebViewNavigation) => {
    setCanGoBack(navState.canGoBack);
    setCanGoForward(navState.canGoForward);
    setCurrentUrl(navState.url);
  }, []);

  const openExternalUrl = useCallback(async (url: string) => {
    try {
      if (await Linking.canOpenURL(url)) {
        await Linking.openURL(url);
      } else {
        Alert.alert('Unable to open link', `No application can open ${url}`);
      }
    } catch {
      Alert.alert(
        'Unable to open link',
        'The external URL could not be opened.',
      );
    }
  }, []);

  const handleMessage = useCallback(
    (event: WebViewMessageEvent) => {
      const message = parseWebViewBridgeMessage(event.nativeEvent.data);
      if (!message) {
        return;
      }

      switch (message.type) {
        case 'onBackPressed':
          navigation.goBack();
          break;
        case 'showLandscapeActions':
          setShowFloatingActions(message.payload.show);
          break;
        case 'rotate':
          break;
        case 'openExternalApplication':
          openExternalUrl(message.payload.url);
          break;
        case 'openInAppWebView':
          setSourceUrl(message.payload.url);
          setCurrentUrl(message.payload.url);
          break;
      }
    },
    [navigation, openExternalUrl],
  );

  const retry = useCallback(() => {
    setLoading(true);
    setLoadFailed(false);
    startLoadTimeout();
    webViewRef.current?.reload();
  }, [startLoadTimeout]);

  const transparentStyle = config.transparentBackground
    ? styles.transparentWebView
    : styles.webview;
  const webViewSource = useMemo(() => ({ uri: sourceUrl }), [sourceUrl]);
  const bootstrapScript = useMemo(
    () =>
      createWebViewBootstrapScript({
        enableViewportScale: config.enableViewportScale,
        iframeAllow: config.iframeAllow,
        ignoresViewportScaleLimits: config.ignoresViewportScaleLimits,
      }),
    [
      config.enableViewportScale,
      config.iframeAllow,
      config.ignoresViewportScaleLimits,
    ],
  );

  return (
    <View style={styles.container}>
      <MemoizedWebView
        ref={webViewRef}
        source={webViewSource}
        javaScriptEnabled={config.javaScriptEnabled}
        domStorageEnabled={config.domStorageEnabled}
        allowFileAccess={config.allowFileAccess}
        allowFileAccessFromFileURLs={config.allowFileAccessFromFileURLs}
        allowUniversalAccessFromFileURLs={
          config.allowUniversalAccessFromFileURLs
        }
        mixedContentMode={config.mixedContentMode}
        userAgent={config.userAgent || undefined}
        applicationNameForUserAgent={
          config.applicationNameForUserAgent || undefined
        }
        webviewDebuggingEnabled={config.debuggingEnabled}
        javaScriptCanOpenWindowsAutomatically={
          config.javaScriptCanOpenWindowsAutomatically
        }
        setBuiltInZoomControls={config.supportZoom}
        setDisplayZoomControls={
          config.supportZoom && config.displayZoomControls
        }
        scalesPageToFit={
          config.supportZoom &&
          config.useWideViewPort &&
          config.loadWithOverviewMode
        }
        geolocationEnabled={config.geolocationEnabled}
        mediaPlaybackRequiresUserAction={
          config.mediaPlaybackRequiresUserGesture
        }
        allowsInlineMediaPlayback={config.allowsInlineMediaPlayback}
        injectedJavaScriptBeforeContentLoaded={bootstrapScript}
        onLoadStart={handleLoadStart}
        onLoad={handleLoadSuccess}
        onNavigationStateChange={handleNavigationChange}
        onMessage={handleMessage}
        onError={handleLoadError}
        style={transparentStyle}
      />

      <Animated.View
        pointerEvents={showFloatingActions ? 'auto' : 'none'}
        style={[
          styles.floatingActions,
          {
            opacity: controlsAnimation,
            transform: [
              {
                translateY: controlsAnimation.interpolate({
                  inputRange: [0, 1],
                  outputRange: [72, 0],
                }),
              },
            ],
          },
        ]}
      >
        <TouchableOpacity
          accessibilityLabel="Go back"
          accessibilityRole="button"
          style={styles.actionButton}
          onPress={handleBackAction}
        >
          <Text style={styles.actionIcon}>{'<'}</Text>
        </TouchableOpacity>
        <TouchableOpacity
          accessibilityLabel="Go forward"
          accessibilityRole="button"
          style={[
            styles.actionButton,
            !canGoForward && styles.actionButtonDisabled,
          ]}
          onPress={() => webViewRef.current?.goForward()}
          disabled={!canGoForward}
        >
          <Text style={styles.actionIcon}>{'>'}</Text>
        </TouchableOpacity>
        <TouchableOpacity
          accessibilityLabel="Reload"
          accessibilityRole="button"
          style={styles.actionButton}
          onPress={() => webViewRef.current?.reload()}
        >
          <Text style={styles.reloadIcon}>R</Text>
        </TouchableOpacity>
      </Animated.View>

      {loading && (
        <View style={styles.loadingOverlay}>
          <ActivityIndicator size="large" color="#2878c8" />
        </View>
      )}

      {loadFailed && (
        <View style={styles.failureOverlay}>
          <Text style={styles.failureTitle}>Unable to load the page.</Text>
          <Text style={styles.failureMessage} numberOfLines={3}>
            {currentUrl}
          </Text>
          <Text style={styles.failureMessage}>
            Check the URL or your network connection.
          </Text>
          <TouchableOpacity
            accessibilityRole="button"
            style={styles.retryButton}
            onPress={retry}
          >
            <Text style={styles.retryButtonLabel}>Retry</Text>
          </TouchableOpacity>
        </View>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#ffffff' },
  webview: { flex: 1, backgroundColor: '#ffffff' },
  transparentWebView: { flex: 1, backgroundColor: 'transparent' },
  floatingActions: {
    position: 'absolute',
    right: 16,
    bottom: Platform.OS === 'ios' ? 28 : 18,
    gap: 10,
  },
  actionButton: {
    width: 44,
    height: 44,
    borderRadius: 22,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'rgba(26, 26, 46, 0.85)',
  },
  actionButtonDisabled: { opacity: 0.45 },
  actionIcon: { fontSize: 24, fontWeight: '700', color: '#ffffff' },
  reloadIcon: { fontSize: 16, fontWeight: '800', color: '#ffffff' },
  loadingOverlay: {
    position: 'absolute',
    top: 0,
    right: 0,
    bottom: 0,
    left: 0,
    backgroundColor: 'rgba(255, 255, 255, 0.82)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  failureOverlay: {
    position: 'absolute',
    top: 0,
    right: 0,
    bottom: 0,
    left: 0,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 24,
    backgroundColor: 'rgba(255, 255, 255, 0.96)',
  },
  failureTitle: { fontSize: 17, fontWeight: '700', color: '#222222' },
  failureMessage: {
    maxWidth: 440,
    marginTop: 8,
    textAlign: 'center',
    fontSize: 14,
    color: '#666666',
  },
  retryButton: {
    minWidth: 112,
    minHeight: 44,
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: 18,
    borderRadius: 8,
    backgroundColor: '#2878c8',
  },
  retryButtonLabel: { fontSize: 15, fontWeight: '700', color: '#ffffff' },
});

export default PreviewScreen;
