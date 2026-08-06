import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'preview_screen.dart';

class WebViewConfig {
  final String url;
  final bool javaScriptEnabled;
  final bool domStorageEnabled;
  final bool debuggingEnabled;
  final String userAgent;
  final bool allowMixedContent;

  const WebViewConfig({
    this.url = 'https://example.com',
    this.javaScriptEnabled = true,
    this.domStorageEnabled = true,
    this.debuggingEnabled = true,
    this.userAgent = '',
    this.allowMixedContent = false,
  });

  WebViewConfig copyWith({
    String? url,
    bool? javaScriptEnabled,
    bool? domStorageEnabled,
    bool? debuggingEnabled,
    String? userAgent,
    bool? allowMixedContent,
  }) =>
      WebViewConfig(
        url: url ?? this.url,
        javaScriptEnabled: javaScriptEnabled ?? this.javaScriptEnabled,
        domStorageEnabled: domStorageEnabled ?? this.domStorageEnabled,
        debuggingEnabled: debuggingEnabled ?? this.debuggingEnabled,
        userAgent: userAgent ?? this.userAgent,
        allowMixedContent: allowMixedContent ?? this.allowMixedContent,
      );

  Map<String, dynamic> toJson() => {
        'url': url,
        'javaScriptEnabled': javaScriptEnabled,
        'domStorageEnabled': domStorageEnabled,
        'debuggingEnabled': debuggingEnabled,
        'userAgent': userAgent,
        'allowMixedContent': allowMixedContent,
      };

  factory WebViewConfig.fromJson(Map<String, dynamic> json) => WebViewConfig(
        url: json['url'] as String? ?? 'https://example.com',
        javaScriptEnabled: json['javaScriptEnabled'] as bool? ?? true,
        domStorageEnabled: json['domStorageEnabled'] as bool? ?? true,
        debuggingEnabled: json['debuggingEnabled'] as bool? ?? true,
        userAgent: json['userAgent'] as String? ?? '',
        allowMixedContent: json['allowMixedContent'] as bool? ?? false,
      );
}

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  static const _storageKey = 'webview_config';

  late TextEditingController _urlController;
  late TextEditingController _userAgentController;
  WebViewConfig _config = const WebViewConfig();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: _config.url);
    _userAgentController = TextEditingController(text: _config.userAgent);
    _loadConfig();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _userAgentController.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_storageKey);
    if (stored != null) {
      try {
        final json = jsonDecode(stored) as Map<String, dynamic>;
        final config = WebViewConfig.fromJson(json);
        setState(() {
          _config = config;
          _urlController.text = config.url;
          _userAgentController.text = config.userAgent;
        });
      } catch (_) {}
    }
    setState(() => _loading = false);
  }

  Future<void> _openWebView() async {
    final url = _urlController.text.trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('URL must start with http:// or https://')),
      );
      return;
    }
    final config = _config.copyWith(
      url: url,
      userAgent: _userAgentController.text.trim(),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(config.toJson()));
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PreviewScreen(config: config)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('WebView Debug Config'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionLabel('URL'),
            const SizedBox(height: 6),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                hintText: 'https://example.com',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: Color(0xFFDDDDDD)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: Color(0xFFDDDDDD)),
                ),
              ),
              keyboardType: TextInputType.url,
              autocorrect: false,
            ),
            const SizedBox(height: 16),
            _SectionLabel('Custom User Agent (optional)'),
            const SizedBox(height: 6),
            TextField(
              controller: _userAgentController,
              decoration: const InputDecoration(
                hintText: 'Leave blank to use default',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: Color(0xFFDDDDDD)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: Color(0xFFDDDDDD)),
                ),
              ),
              autocorrect: false,
            ),
            const SizedBox(height: 24),
            const Text(
              'WebView Settings',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF444444)),
            ),
            const SizedBox(height: 8),
            _SettingRow(
              label: 'JavaScript Enabled',
              value: _config.javaScriptEnabled,
              onChanged: (v) =>
                  setState(() => _config = _config.copyWith(javaScriptEnabled: v)),
            ),
            _SettingRow(
              label: 'DOM Storage Enabled',
              value: _config.domStorageEnabled,
              onChanged: (v) =>
                  setState(() => _config = _config.copyWith(domStorageEnabled: v)),
            ),
            _SettingRow(
              label: 'Allow Mixed Content',
              value: _config.allowMixedContent,
              onChanged: (v) =>
                  setState(() => _config = _config.copyWith(allowMixedContent: v)),
            ),
            _SettingRow(
              label: 'Remote Debugging Enabled',
              value: _config.debuggingEnabled,
              onChanged: (v) =>
                  setState(() => _config = _config.copyWith(debuggingEnabled: v)),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _openWebView,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Open WebView →',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(fontSize: 14, color: Color(0xFF555555)),
      );
}

class _SettingRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: SwitchListTile(
          title: Text(label, style: const TextStyle(fontSize: 15)),
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF4A90E2),
        ),
      );
}
