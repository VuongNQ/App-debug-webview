import React, {useState, useEffect} from 'react';
import {
  View,
  Text,
  TextInput,
  Switch,
  TouchableOpacity,
  ScrollView,
  StyleSheet,
  Alert,
} from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import {useNavigation} from '@react-navigation/native';
import type {NativeStackNavigationProp} from '@react-navigation/native-stack';
import type {RootStackParamList} from '../types';

const STORAGE_KEY = '@webview_config';

export interface WebViewConfig {
  url: string;
  javaScriptEnabled: boolean;
  domStorageEnabled: boolean;
  allowFileAccess: boolean;
  mixedContentMode: 'never' | 'always' | 'compatibility';
  userAgent: string;
  debuggingEnabled: boolean;
}

const DEFAULT_CONFIG: WebViewConfig = {
  url: 'https://example.com',
  javaScriptEnabled: true,
  domStorageEnabled: true,
  allowFileAccess: false,
  mixedContentMode: 'never',
  userAgent: '',
  debuggingEnabled: true,
};

type NavProp = NativeStackNavigationProp<RootStackParamList, 'Config'>;

const ConfigScreen: React.FC = () => {
  const navigation = useNavigation<NavProp>();
  const [config, setConfig] = useState<WebViewConfig>(DEFAULT_CONFIG);

  useEffect(() => {
    AsyncStorage.getItem(STORAGE_KEY).then(stored => {
      if (stored) {
        try {
          setConfig(JSON.parse(stored));
        } catch {}
      }
    });
  }, []);

  const saveAndNavigate = async () => {
    if (!config.url.startsWith('http://') && !config.url.startsWith('https://')) {
      Alert.alert('Invalid URL', 'URL must start with http:// or https://');
      return;
    }
    await AsyncStorage.setItem(STORAGE_KEY, JSON.stringify(config));
    navigation.navigate('Preview', {config});
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <Text style={styles.title}>WebView Debug Config</Text>

      <Text style={styles.label}>URL</Text>
      <TextInput
        style={styles.input}
        value={config.url}
        onChangeText={url => setConfig(c => ({...c, url}))}
        autoCapitalize="none"
        autoCorrect={false}
        keyboardType="url"
        placeholder="https://example.com"
        placeholderTextColor="#94a3b8"
      />

      <Text style={styles.label}>Custom User Agent (optional)</Text>
      <TextInput
        style={styles.input}
        value={config.userAgent}
        onChangeText={userAgent => setConfig(c => ({...c, userAgent}))}
        autoCapitalize="none"
        autoCorrect={false}
        placeholder="Leave blank to use default"
        placeholderTextColor="#94a3b8"
      />

      <Text style={styles.sectionTitle}>WebView Settings</Text>

      <Row
        label="JavaScript Enabled"
        value={config.javaScriptEnabled}
        onToggle={v => setConfig(c => ({...c, javaScriptEnabled: v}))}
      />
      <Row
        label="DOM Storage Enabled"
        value={config.domStorageEnabled}
        onToggle={v => setConfig(c => ({...c, domStorageEnabled: v}))}
      />
      <Row
        label="Allow File Access"
        value={config.allowFileAccess}
        onToggle={v => setConfig(c => ({...c, allowFileAccess: v}))}
      />
      <Row
        label="Remote Debugging Enabled"
        value={config.debuggingEnabled}
        onToggle={v => setConfig(c => ({...c, debuggingEnabled: v}))}
      />

      <Text style={styles.label}>Mixed Content Mode</Text>
      <View style={styles.radioGroup}>
        {(['never', 'always', 'compatibility'] as const).map(mode => (
          <TouchableOpacity
            key={mode}
            style={[
              styles.radioOption,
              config.mixedContentMode === mode && styles.radioOptionSelected,
            ]}
            onPress={() => setConfig(c => ({...c, mixedContentMode: mode}))}>
            <Text
              style={[
                styles.radioText,
                config.mixedContentMode === mode && styles.radioTextSelected,
              ]}>
              {mode}
            </Text>
          </TouchableOpacity>
        ))}
      </View>

      <TouchableOpacity style={styles.button} onPress={saveAndNavigate}>
        <Text style={styles.buttonText}>Open WebView →</Text>
      </TouchableOpacity>
    </ScrollView>
  );
};

const Row: React.FC<{
  label: string;
  value: boolean;
  onToggle: (v: boolean) => void;
}> = ({label, value, onToggle}) => (
  <View style={styles.row}>
    <Text style={styles.rowLabel}>{label}</Text>
    <Switch value={value} onValueChange={onToggle} trackColor={{false: '#64748b', true: '#4f46e5'}} thumbColor={value ? '#eef2ff' : '#f8fafc'} />
  </View>
);

const styles = StyleSheet.create({
  container: {flex: 1, backgroundColor: '#020617'},
  content: {padding: 20, paddingBottom: 40},
  title: {fontSize: 22, fontWeight: '700', marginBottom: 24, color: '#f8fafc'},
  sectionTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#cbd5e1',
    marginTop: 20,
    marginBottom: 8,
  },
  label: {fontSize: 14, color: '#94a3b8', marginTop: 16, marginBottom: 6},
  input: {
    backgroundColor: '#0f172a',
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#334155',
    paddingHorizontal: 12,
    paddingVertical: 10,
    fontSize: 15,
    color: '#f8fafc',
  },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    backgroundColor: '#0f172a',
    borderRadius: 8,
    paddingHorizontal: 14,
    paddingVertical: 12,
    marginBottom: 8,
  },
  rowLabel: {fontSize: 15, color: '#e2e8f0'},
  radioGroup: {flexDirection: 'row', gap: 8, marginTop: 4},
  radioOption: {
    flex: 1,
    paddingVertical: 8,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#334155',
    alignItems: 'center',
    backgroundColor: '#0f172a',
  },
  radioOptionSelected: {borderColor: '#818cf8', backgroundColor: '#312e81'},
  radioText: {fontSize: 13, color: '#cbd5e1'},
  radioTextSelected: {color: '#e0e7ff', fontWeight: '600'},
  button: {
    marginTop: 32,
    backgroundColor: '#4f46e5',
    borderRadius: 10,
    paddingVertical: 14,
    alignItems: 'center',
  },
  buttonText: {color: '#f8fafc', fontSize: 16, fontWeight: '700'},
});

export default ConfigScreen;
