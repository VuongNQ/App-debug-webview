import React, { useEffect, useRef, useState } from 'react';
import {
  ActivityIndicator,
  Alert,
  Modal,
  Platform,
  View,
  Text,
  TextInput,
  Switch,
  TouchableOpacity,
  ScrollView,
  StyleSheet,
  useWindowDimensions,
} from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import Clipboard from '@react-native-clipboard/clipboard';
import { useNavigation } from '@react-navigation/native';
import type { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { Camera, CameraType } from 'react-native-camera-kit';
import { PERMISSIONS, request, RESULTS } from 'react-native-permissions';
import type { RootStackParamList } from '../types';
import {
  DEFAULT_CONFIG,
  normalizeWebViewConfig,
  parseStoredWebViewConfig,
  WEBVIEW_CONFIG_STORAGE_KEY,
} from '../config/webViewConfig';
import type { WebViewConfig } from '../config/webViewConfig';

export type { WebViewConfig } from '../config/webViewConfig';

type NavProp = NativeStackNavigationProp<RootStackParamList, 'Config'>;

const ConfigScreen: React.FC = () => {
  const navigation = useNavigation<NavProp>();
  const { width, height } = useWindowDimensions();
  const [config, setConfig] = useState<WebViewConfig>(DEFAULT_CONFIG);
  const [loadingConfig, setLoadingConfig] = useState(true);
  const [showAdvancedSettings, setShowAdvancedSettings] = useState(false);
  const [scannerVisible, setScannerVisible] = useState(false);
  const activeRef = useRef(true);
  const handledScanRef = useRef(false);
  const useTwoPane = width > height && width >= 760;

  useEffect(() => {
    activeRef.current = true;

    AsyncStorage.getItem(WEBVIEW_CONFIG_STORAGE_KEY)
      .then(stored => {
        if (activeRef.current && stored) {
          setConfig(parseStoredWebViewConfig(stored));
        }
      })
      .catch(() => {
        if (activeRef.current) {
          Alert.alert(
            'Unable to load settings',
            'Default WebView settings will be used.',
          );
        }
      })
      .finally(() => {
        if (activeRef.current) {
          setLoadingConfig(false);
        }
      });

    return () => {
      activeRef.current = false;
    };
  }, []);

  function updateConfig<Key extends keyof WebViewConfig>(
    key: Key,
    value: WebViewConfig[Key],
  ) {
    setConfig(current => ({ ...current, [key]: value }));
  }

  const saveAndNavigate = async () => {
    const nextConfig = normalizeWebViewConfig({
      ...config,
      url: config.url.trim(),
      userAgent: config.userAgent.trim(),
      iframeAllow: config.iframeAllow.trim(),
      applicationNameForUserAgent: config.applicationNameForUserAgent.trim(),
    });

    if (
      !nextConfig.url.startsWith('http://') &&
      !nextConfig.url.startsWith('https://')
    ) {
      Alert.alert('Invalid URL', 'URL must start with http:// or https://');
      return;
    }

    try {
      await AsyncStorage.setItem(
        WEBVIEW_CONFIG_STORAGE_KEY,
        JSON.stringify(nextConfig),
      );
      if (activeRef.current) {
        setConfig(nextConfig);
        navigation.navigate('Preview', { config: nextConfig });
      }
    } catch {
      Alert.alert(
        'Unable to save settings',
        'Check device storage and try again.',
      );
    }
  };

  const pasteUrl = async () => {
    try {
      const value = (await Clipboard.getString()).trim();
      if (!value) {
        Alert.alert('Clipboard is empty', 'Copy a URL and try again.');
        return;
      }
      if (!value.startsWith('http://') && !value.startsWith('https://')) {
        Alert.alert(
          'Invalid clipboard URL',
          'Clipboard text must start with http:// or https://',
        );
        return;
      }
      updateConfig('url', value);
    } catch {
      Alert.alert('Unable to paste', 'Clipboard content could not be read.');
    }
  };

  const openScanner = async () => {
    const permission =
      Platform.OS === 'ios'
        ? PERMISSIONS.IOS.CAMERA
        : PERMISSIONS.ANDROID.CAMERA;

    try {
      const result = await request(permission);
      if (result !== RESULTS.GRANTED) {
        Alert.alert(
          'Camera permission required',
          'Allow camera access to scan a QR URL.',
        );
        return;
      }
      handledScanRef.current = false;
      setScannerVisible(true);
    } catch {
      Alert.alert(
        'Unable to open scanner',
        'Camera permission could not be requested.',
      );
    }
  };

  const handleScannedValue = (rawValue: string) => {
    if (handledScanRef.current) {
      return;
    }
    handledScanRef.current = true;
    setScannerVisible(false);
    const value = rawValue.trim();
    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      Alert.alert(
        'Invalid QR URL',
        'QR content must start with http:// or https://',
      );
      return;
    }
    updateConfig('url', value);
  };

  const inputSection = (
    <View style={[styles.section, useTwoPane && styles.pane]}>
      <View style={styles.labelRow}>
        <Text style={styles.label}>URL</Text>
        <View style={styles.urlActions}>
          <TouchableOpacity
            accessibilityRole="button"
            testID="paste-url-button"
            style={styles.textButton}
            onPress={pasteUrl}
          >
            <Text style={styles.textButtonLabel}>Paste URL</Text>
          </TouchableOpacity>
          <TouchableOpacity
            accessibilityRole="button"
            testID="scan-qr-button"
            style={styles.textButton}
            onPress={openScanner}
          >
            <Text style={styles.textButtonLabel}>Scan QR</Text>
          </TouchableOpacity>
        </View>
      </View>
      <TextInput
        testID="url-input"
        style={styles.input}
        value={config.url}
        onChangeText={value => updateConfig('url', value)}
        autoCapitalize="none"
        autoCorrect={false}
        keyboardType="url"
        placeholder="https://example.com"
        placeholderTextColor="#858585"
      />

      <Text style={styles.label}>Custom User Agent (optional)</Text>
      <TextInput
        style={styles.input}
        value={config.userAgent}
        onChangeText={value => updateConfig('userAgent', value)}
        autoCapitalize="none"
        autoCorrect={false}
        placeholder="Leave blank to use default"
        placeholderTextColor="#858585"
      />
    </View>
  );

  const settingsSection = (
    <View style={[styles.section, useTwoPane && styles.pane]}>
      <Text style={styles.sectionTitle}>WebView Settings</Text>
      <Row
        label="JavaScript Enabled"
        value={config.javaScriptEnabled}
        onToggle={value => updateConfig('javaScriptEnabled', value)}
      />
      <Row
        label="DOM Storage Enabled"
        value={config.domStorageEnabled}
        onToggle={value => updateConfig('domStorageEnabled', value)}
      />
      <Row
        label="Remote Debugging Enabled"
        value={config.debuggingEnabled}
        onToggle={value => updateConfig('debuggingEnabled', value)}
      />

      <Text style={styles.label}>Mixed Content Mode</Text>
      <View style={styles.segmentedControl}>
        {(['never', 'always', 'compatibility'] as const).map(mode => (
          <TouchableOpacity
            accessibilityRole="button"
            key={mode}
            style={[
              styles.segment,
              config.mixedContentMode === mode && styles.segmentSelected,
            ]}
            onPress={() => updateConfig('mixedContentMode', mode)}
          >
            <Text
              style={[
                styles.segmentLabel,
                config.mixedContentMode === mode && styles.segmentLabelSelected,
              ]}
            >
              {mode}
            </Text>
          </TouchableOpacity>
        ))}
      </View>

      <TouchableOpacity
        accessibilityRole="button"
        testID="advanced-settings-button"
        style={styles.advancedHeader}
        onPress={() => setShowAdvancedSettings(current => !current)}
      >
        <Text style={styles.advancedTitle}>Advanced WebView Settings</Text>
        <Text style={styles.disclosure}>
          {showAdvancedSettings ? 'Hide' : 'Show'}
        </Text>
      </TouchableOpacity>

      {showAdvancedSettings && (
        <View style={styles.advancedContent}>
          <Row
            label="Allow File Access"
            value={config.allowFileAccess}
            onToggle={value => updateConfig('allowFileAccess', value)}
          />
          <Row
            label="Support Zoom"
            value={config.supportZoom}
            onToggle={value =>
              setConfig(current => ({
                ...current,
                supportZoom: value,
                enableViewportScale: value,
                ignoresViewportScaleLimits: value,
              }))
            }
          />
          <Row
            label="Display Zoom Controls"
            value={config.displayZoomControls}
            onToggle={value => updateConfig('displayZoomControls', value)}
          />
          <Row
            label="Use Wide ViewPort"
            value={config.useWideViewPort}
            onToggle={value => updateConfig('useWideViewPort', value)}
          />
          <Row
            label="Load With Overview Mode"
            value={config.loadWithOverviewMode}
            onToggle={value => updateConfig('loadWithOverviewMode', value)}
          />
          <Row
            label="Use On Load Resource"
            value={config.useOnLoadResource}
            onToggle={value => updateConfig('useOnLoadResource', value)}
          />
          <Row
            label="Geolocation Enabled"
            value={config.geolocationEnabled}
            onToggle={value => updateConfig('geolocationEnabled', value)}
          />
          <Row
            label="JavaScript Can Open Windows"
            value={config.javaScriptCanOpenWindowsAutomatically}
            onToggle={value =>
              updateConfig('javaScriptCanOpenWindowsAutomatically', value)
            }
          />
          <Row
            label="Allow Universal Access From File URLs"
            value={config.allowUniversalAccessFromFileURLs}
            onToggle={value =>
              updateConfig('allowUniversalAccessFromFileURLs', value)
            }
          />
          <Row
            label="Allow File Access From File URLs"
            value={config.allowFileAccessFromFileURLs}
            onToggle={value =>
              updateConfig('allowFileAccessFromFileURLs', value)
            }
          />
          <Row
            label="Media Playback Requires User Gesture"
            value={config.mediaPlaybackRequiresUserGesture}
            onToggle={value =>
              updateConfig('mediaPlaybackRequiresUserGesture', value)
            }
          />
          <Row
            label="Allows Inline Media Playback"
            value={config.allowsInlineMediaPlayback}
            onToggle={value => updateConfig('allowsInlineMediaPlayback', value)}
          />
          <Row
            label="Transparent Background"
            value={config.transparentBackground}
            onToggle={value => updateConfig('transparentBackground', value)}
          />

          <Text style={styles.label}>Iframe Allow Permissions</Text>
          <TextInput
            style={[styles.input, styles.multilineInput]}
            value={config.iframeAllow}
            onChangeText={value => updateConfig('iframeAllow', value)}
            autoCapitalize="none"
            autoCorrect={false}
            multiline
            placeholder="camera; microphone; geolocation; fullscreen"
            placeholderTextColor="#858585"
          />

          <Text style={styles.label}>
            Application Name For User Agent (optional)
          </Text>
          <TextInput
            style={styles.input}
            value={config.applicationNameForUserAgent}
            onChangeText={value =>
              updateConfig('applicationNameForUserAgent', value)
            }
            autoCapitalize="none"
            autoCorrect={false}
            placeholder="ExampleApp/1.0.0"
            placeholderTextColor="#858585"
          />
        </View>
      )}
    </View>
  );

  if (loadingConfig) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color="#2878c8" />
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <View style={styles.appBar}>
        <Text style={styles.title}>WebView Debug Config</Text>
      </View>
      <View style={styles.openButtonBar}>
        <TouchableOpacity
          accessibilityRole="button"
          testID="open-webview-button"
          style={styles.openButton}
          onPress={saveAndNavigate}
        >
          <Text style={styles.openButtonLabel}>Open WebView</Text>
        </TouchableOpacity>
      </View>
      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={[
          styles.content,
          useTwoPane && styles.twoPaneContent,
        ]}
        keyboardShouldPersistTaps="handled"
      >
        {inputSection}
        {settingsSection}
      </ScrollView>

      <Modal
        visible={scannerVisible}
        animationType="slide"
        onRequestClose={() => setScannerVisible(false)}
      >
        <View style={styles.scannerContainer}>
          <Camera
            style={StyleSheet.absoluteFill}
            cameraType={CameraType.Back}
            scanBarcode
            showFrame
            frameColor="#4a90e2"
            laserColor="#ffffff"
            onReadCode={event =>
              handleScannedValue(event.nativeEvent.codeStringValue)
            }
          />
          <View style={styles.scannerHeader}>
            <Text style={styles.scannerTitle}>Scan QR URL</Text>
            <TouchableOpacity
              accessibilityRole="button"
              style={styles.closeButton}
              onPress={() => setScannerVisible(false)}
            >
              <Text style={styles.closeButtonLabel}>Close</Text>
            </TouchableOpacity>
          </View>
          <View style={styles.scannerHint}>
            <Text style={styles.scannerHintText}>
              Scan a QR code from your PC screen to autofill URL
            </Text>
          </View>
        </View>
      </Modal>
    </View>
  );
};

const Row: React.FC<{
  label: string;
  value: boolean;
  onToggle: (v: boolean) => void;
}> = ({ label, value, onToggle }) => (
  <View style={styles.row}>
    <Text style={styles.rowLabel}>{label}</Text>
    <Switch
      value={value}
      onValueChange={onToggle}
      trackColor={{ false: '#b8b8b8', true: '#73aee8' }}
      thumbColor={value ? '#2878c8' : '#f5f5f5'}
    />
  </View>
);

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f5f5f5' },
  loadingContainer: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#f5f5f5',
  },
  appBar: {
    minHeight: 56,
    justifyContent: 'center',
    paddingHorizontal: 20,
    backgroundColor: '#1a1a2e',
  },
  title: { fontSize: 20, fontWeight: '700', color: '#ffffff' },
  openButtonBar: {
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderBottomWidth: 1,
    borderBottomColor: '#e2e2e2',
  },
  openButton: {
    minHeight: 48,
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 8,
    backgroundColor: '#2878c8',
  },
  openButtonLabel: { fontSize: 16, fontWeight: '700', color: '#ffffff' },
  scrollView: { flex: 1 },
  content: { padding: 16, paddingBottom: 32, gap: 24 },
  twoPaneContent: { flexDirection: 'row', alignItems: 'flex-start', gap: 16 },
  section: { width: '100%' },
  pane: { flex: 1, width: undefined },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#444444',
    marginBottom: 8,
  },
  labelRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    gap: 8,
  },
  label: { fontSize: 14, color: '#555555', marginTop: 14, marginBottom: 6 },
  urlActions: { flexDirection: 'row', alignItems: 'center', gap: 2 },
  textButton: { paddingHorizontal: 10, paddingVertical: 8 },
  textButtonLabel: { fontSize: 14, fontWeight: '600', color: '#2878c8' },
  input: {
    minHeight: 46,
    backgroundColor: '#ffffff',
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#dddddd',
    paddingHorizontal: 12,
    paddingVertical: 10,
    fontSize: 15,
    color: '#202020',
  },
  multilineInput: { minHeight: 76, textAlignVertical: 'top' },
  row: {
    minHeight: 54,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    backgroundColor: '#ffffff',
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#eeeeee',
    paddingHorizontal: 14,
    paddingVertical: 5,
    marginBottom: 8,
  },
  rowLabel: { flex: 1, paddingRight: 12, fontSize: 15, color: '#333333' },
  segmentedControl: { flexDirection: 'row', gap: 8, marginTop: 2 },
  segment: {
    flex: 1,
    minHeight: 40,
    justifyContent: 'center',
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#cccccc',
    alignItems: 'center',
    backgroundColor: '#ffffff',
  },
  segmentSelected: { borderColor: '#2878c8', backgroundColor: '#e9f3fc' },
  segmentLabel: { fontSize: 12, color: '#555555' },
  segmentLabelSelected: { color: '#165b9f', fontWeight: '700' },
  advancedHeader: {
    minHeight: 52,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginTop: 20,
    paddingHorizontal: 14,
    borderWidth: 1,
    borderColor: '#e2e2e2',
    borderRadius: 8,
    backgroundColor: '#ffffff',
  },
  advancedTitle: { fontSize: 15, fontWeight: '600', color: '#444444' },
  disclosure: { fontSize: 13, color: '#2878c8' },
  advancedContent: { paddingTop: 10 },
  scannerContainer: { flex: 1, backgroundColor: '#000000' },
  scannerHeader: {
    minHeight: 58,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 18,
    backgroundColor: 'rgba(26, 26, 46, 0.9)',
  },
  scannerTitle: { fontSize: 18, fontWeight: '700', color: '#ffffff' },
  closeButton: { paddingHorizontal: 12, paddingVertical: 10 },
  closeButtonLabel: { fontSize: 15, fontWeight: '600', color: '#ffffff' },
  scannerHint: {
    position: 'absolute',
    right: 0,
    bottom: 0,
    left: 0,
    padding: 16,
    backgroundColor: 'rgba(0, 0, 0, 0.6)',
  },
  scannerHintText: { fontSize: 14, textAlign: 'center', color: '#ffffff' },
});

export default ConfigScreen;
