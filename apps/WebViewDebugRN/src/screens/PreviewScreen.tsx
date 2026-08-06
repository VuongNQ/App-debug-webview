import React, {useRef, useState} from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  ActivityIndicator,
  StyleSheet,
  Platform,
  Alert,
} from 'react-native';
import {WebView} from 'react-native-webview';
import {useNavigation, useRoute} from '@react-navigation/native';
import type {NativeStackNavigationProp} from '@react-navigation/native-stack';
import type {RouteProp} from '@react-navigation/native';
import type {RootStackParamList} from '../types';

type NavProp = NativeStackNavigationProp<RootStackParamList, 'Preview'>;
type RoutePropType = RouteProp<RootStackParamList, 'Preview'>;

const PreviewScreen: React.FC = () => {
  const navigation = useNavigation<NavProp>();
  const route = useRoute<RoutePropType>();
  const {config} = route.params;
  const webViewRef = useRef<WebView>(null);
  const [loading, setLoading] = useState(true);
  const [canGoBack, setCanGoBack] = useState(false);
  const [canGoForward, setCanGoForward] = useState(false);

  return (
    <View style={styles.container}>
      {/* Toolbar */}
      <View style={styles.toolbar}>
        <TouchableOpacity
          style={[styles.navButton, !canGoBack && styles.navButtonDisabled]}
          onPress={() => webViewRef.current?.goBack()}
          disabled={!canGoBack}>
          <Text style={styles.navButtonText}>‹</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={[styles.navButton, !canGoForward && styles.navButtonDisabled]}
          onPress={() => webViewRef.current?.goForward()}
          disabled={!canGoForward}>
          <Text style={styles.navButtonText}>›</Text>
        </TouchableOpacity>
        <Text style={styles.urlText} numberOfLines={1}>
          {config.url}
        </Text>
        <TouchableOpacity
          style={styles.navButton}
          onPress={() => webViewRef.current?.reload()}>
          <Text style={styles.navButtonText}>↻</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={styles.configButton}
          onPress={() => navigation.goBack()}>
          <Text style={styles.configButtonText}>⚙</Text>
        </TouchableOpacity>
      </View>

      {/* WebView */}
      <WebView
        ref={webViewRef}
        source={{uri: config.url}}
        javaScriptEnabled={config.javaScriptEnabled}
        domStorageEnabled={config.domStorageEnabled}
        allowFileAccess={config.allowFileAccess}
        mixedContentMode={config.mixedContentMode}
        userAgent={config.userAgent || undefined}
        // Enable remote debugging (Chrome DevTools)
        webviewDebuggingEnabled={config.debuggingEnabled}
        onLoadStart={() => setLoading(true)}
        onLoadEnd={() => setLoading(false)}
        onNavigationStateChange={navState => {
          setCanGoBack(navState.canGoBack);
          setCanGoForward(navState.canGoForward);
        }}
        onError={syntheticEvent => {
          const {nativeEvent} = syntheticEvent;
          Alert.alert(
            'WebView Error',
            `${nativeEvent.description} (${nativeEvent.code})`,
          );
          setLoading(false);
        }}
        style={styles.webview}
      />

      {loading && (
        <View style={styles.loadingOverlay}>
          <ActivityIndicator size="large" color="#818cf8" />
        </View>
      )}

      {/* Debug hint */}
      {config.debuggingEnabled && Platform.OS === 'android' && (
        <View style={styles.debugBanner}>
          <Text style={styles.debugText}>🔍 Remote debugging: chrome://inspect</Text>
        </View>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {flex: 1, backgroundColor: '#020617'},
  toolbar: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#0f172a',
    paddingHorizontal: 8,
    paddingVertical: 6,
    gap: 4,
  },
  navButton: {
    padding: 6,
    borderRadius: 6,
    minWidth: 32,
    alignItems: 'center',
  },
  navButtonDisabled: {opacity: 0.3},
  navButtonText: {color: '#f8fafc', fontSize: 20, fontWeight: '700'},
  urlText: {
    flex: 1,
    color: '#cbd5e1',
    fontSize: 13,
    paddingHorizontal: 4,
  },
  configButton: {
    padding: 6,
    borderRadius: 6,
    alignItems: 'center',
  },
  configButtonText: {color: '#f8fafc', fontSize: 18},
  webview: {flex: 1, backgroundColor: '#020617'},
  loadingOverlay: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: 'rgba(2, 6, 23, 0.85)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  debugBanner: {
    backgroundColor: '#0f172a',
    paddingHorizontal: 12,
    paddingVertical: 6,
    alignItems: 'center',
  },
  debugText: {color: '#a5b4fc', fontSize: 12},
});

export default PreviewScreen;
