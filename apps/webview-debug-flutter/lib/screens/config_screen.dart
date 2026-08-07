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
  final bool supportZoom;
  final bool enableViewportScale;
  final bool ignoresViewportScaleLimits;
  final bool displayZoomControls;
  final bool useWideViewPort;
  final bool loadWithOverviewMode;
  final bool useOnLoadResource;
  final bool geolocationEnabled;
  final bool javaScriptCanOpenWindowsAutomatically;
  final bool allowUniversalAccessFromFileURLs;
  final bool allowFileAccessFromFileURLs;
  final bool mediaPlaybackRequiresUserGesture;
  final bool allowsInlineMediaPlayback;
  final String iframeAllow;
  final String applicationNameForUserAgent;
  final bool transparentBackground;

  const WebViewConfig({
    this.url = 'https://example.com',
    this.javaScriptEnabled = true,
    this.domStorageEnabled = true,
    this.debuggingEnabled = true,
    this.userAgent = '',
    this.allowMixedContent = false,
    this.supportZoom = true,
    this.enableViewportScale = true,
    this.ignoresViewportScaleLimits = true,
    this.displayZoomControls = false,
    this.useWideViewPort = true,
    this.loadWithOverviewMode = true,
    this.useOnLoadResource = true,
    this.geolocationEnabled = true,
    this.javaScriptCanOpenWindowsAutomatically = true,
    this.allowUniversalAccessFromFileURLs = true,
    this.allowFileAccessFromFileURLs = true,
    this.mediaPlaybackRequiresUserGesture = false,
    this.allowsInlineMediaPlayback = true,
    this.iframeAllow =
        'camera; microphone; clipboard-write; geolocation; web-share; fullscreen',
    this.applicationNameForUserAgent = '',
    this.transparentBackground = false,
  });

  WebViewConfig copyWith({
    String? url,
    bool? javaScriptEnabled,
    bool? domStorageEnabled,
    bool? debuggingEnabled,
    String? userAgent,
    bool? allowMixedContent,
    bool? supportZoom,
    bool? enableViewportScale,
    bool? ignoresViewportScaleLimits,
    bool? displayZoomControls,
    bool? useWideViewPort,
    bool? loadWithOverviewMode,
    bool? useOnLoadResource,
    bool? geolocationEnabled,
    bool? javaScriptCanOpenWindowsAutomatically,
    bool? allowUniversalAccessFromFileURLs,
    bool? allowFileAccessFromFileURLs,
    bool? mediaPlaybackRequiresUserGesture,
    bool? allowsInlineMediaPlayback,
    String? iframeAllow,
    String? applicationNameForUserAgent,
    bool? transparentBackground,
  }) =>
      WebViewConfig(
        url: url ?? this.url,
        javaScriptEnabled: javaScriptEnabled ?? this.javaScriptEnabled,
        domStorageEnabled: domStorageEnabled ?? this.domStorageEnabled,
        debuggingEnabled: debuggingEnabled ?? this.debuggingEnabled,
        userAgent: userAgent ?? this.userAgent,
        allowMixedContent: allowMixedContent ?? this.allowMixedContent,
        supportZoom: supportZoom ?? this.supportZoom,
        enableViewportScale: enableViewportScale ?? this.enableViewportScale,
        ignoresViewportScaleLimits:
            ignoresViewportScaleLimits ?? this.ignoresViewportScaleLimits,
        displayZoomControls: displayZoomControls ?? this.displayZoomControls,
        useWideViewPort: useWideViewPort ?? this.useWideViewPort,
        loadWithOverviewMode: loadWithOverviewMode ?? this.loadWithOverviewMode,
        useOnLoadResource: useOnLoadResource ?? this.useOnLoadResource,
        geolocationEnabled: geolocationEnabled ?? this.geolocationEnabled,
        javaScriptCanOpenWindowsAutomatically:
            javaScriptCanOpenWindowsAutomatically ??
                this.javaScriptCanOpenWindowsAutomatically,
        allowUniversalAccessFromFileURLs: allowUniversalAccessFromFileURLs ??
            this.allowUniversalAccessFromFileURLs,
        allowFileAccessFromFileURLs:
            allowFileAccessFromFileURLs ?? this.allowFileAccessFromFileURLs,
        mediaPlaybackRequiresUserGesture: mediaPlaybackRequiresUserGesture ??
            this.mediaPlaybackRequiresUserGesture,
        allowsInlineMediaPlayback:
            allowsInlineMediaPlayback ?? this.allowsInlineMediaPlayback,
        iframeAllow: iframeAllow ?? this.iframeAllow,
        applicationNameForUserAgent:
            applicationNameForUserAgent ?? this.applicationNameForUserAgent,
        transparentBackground:
            transparentBackground ?? this.transparentBackground,
      );

  Map<String, dynamic> toJson() => {
        'url': url,
        'javaScriptEnabled': javaScriptEnabled,
        'domStorageEnabled': domStorageEnabled,
        'debuggingEnabled': debuggingEnabled,
        'userAgent': userAgent,
        'allowMixedContent': allowMixedContent,
        'supportZoom': supportZoom,
        'enableViewportScale': enableViewportScale,
        'ignoresViewportScaleLimits': ignoresViewportScaleLimits,
        'displayZoomControls': displayZoomControls,
        'useWideViewPort': useWideViewPort,
        'loadWithOverviewMode': loadWithOverviewMode,
        'useOnLoadResource': useOnLoadResource,
        'geolocationEnabled': geolocationEnabled,
        'javaScriptCanOpenWindowsAutomatically':
            javaScriptCanOpenWindowsAutomatically,
        'allowUniversalAccessFromFileURLs': allowUniversalAccessFromFileURLs,
        'allowFileAccessFromFileURLs': allowFileAccessFromFileURLs,
        'mediaPlaybackRequiresUserGesture': mediaPlaybackRequiresUserGesture,
        'allowsInlineMediaPlayback': allowsInlineMediaPlayback,
        'iframeAllow': iframeAllow,
        'applicationNameForUserAgent': applicationNameForUserAgent,
        'transparentBackground': transparentBackground,
      };

  factory WebViewConfig.fromJson(Map<String, dynamic> json) => WebViewConfig(
        url: json['url'] as String? ?? 'https://example.com',
        javaScriptEnabled: json['javaScriptEnabled'] as bool? ?? true,
        domStorageEnabled: json['domStorageEnabled'] as bool? ?? true,
        debuggingEnabled: json['debuggingEnabled'] as bool? ?? true,
        userAgent: json['userAgent'] as String? ?? '',
        allowMixedContent: json['allowMixedContent'] as bool? ?? false,
        supportZoom: json['supportZoom'] as bool? ?? true,
        enableViewportScale: json['enableViewportScale'] as bool? ?? true,
        ignoresViewportScaleLimits:
            json['ignoresViewportScaleLimits'] as bool? ?? true,
        displayZoomControls: json['displayZoomControls'] as bool? ?? false,
        useWideViewPort: json['useWideViewPort'] as bool? ?? true,
        loadWithOverviewMode: json['loadWithOverviewMode'] as bool? ?? true,
        useOnLoadResource: json['useOnLoadResource'] as bool? ?? true,
        geolocationEnabled: json['geolocationEnabled'] as bool? ?? true,
        javaScriptCanOpenWindowsAutomatically:
            json['javaScriptCanOpenWindowsAutomatically'] as bool? ?? true,
        allowUniversalAccessFromFileURLs:
            json['allowUniversalAccessFromFileURLs'] as bool? ?? true,
        allowFileAccessFromFileURLs:
            json['allowFileAccessFromFileURLs'] as bool? ?? true,
        mediaPlaybackRequiresUserGesture:
            json['mediaPlaybackRequiresUserGesture'] as bool? ?? false,
        allowsInlineMediaPlayback:
            json['allowsInlineMediaPlayback'] as bool? ?? true,
        iframeAllow: json['iframeAllow'] as String? ??
            'camera; microphone; clipboard-write; geolocation; web-share; fullscreen',
        applicationNameForUserAgent:
            json['applicationNameForUserAgent'] as String? ?? '',
        transparentBackground: json['transparentBackground'] as bool? ?? false,
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
  late TextEditingController _iframeAllowController;
  late TextEditingController _applicationNameForUserAgentController;
  WebViewConfig _config = const WebViewConfig();
  bool _loading = true;
  bool _showAdvancedSettings = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: _config.url);
    _userAgentController = TextEditingController(text: _config.userAgent);
    _iframeAllowController = TextEditingController(text: _config.iframeAllow);
    _applicationNameForUserAgentController =
        TextEditingController(text: _config.applicationNameForUserAgent);
    _loadConfig();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _userAgentController.dispose();
    _iframeAllowController.dispose();
    _applicationNameForUserAgentController.dispose();
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
          _iframeAllowController.text = config.iframeAllow;
          _applicationNameForUserAgentController.text =
              config.applicationNameForUserAgent;
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
      iframeAllow: _iframeAllowController.text.trim(),
      applicationNameForUserAgent:
          _applicationNameForUserAgentController.text.trim(),
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

    final media = MediaQuery.of(context);
    final isLandscape = media.orientation == Orientation.landscape;
    final screenWidth = media.size.width;
    final screenHeight = media.size.height;
    final isCompactLandscape = isLandscape && screenHeight < 430;
    final useTwoPaneLandscape = isLandscape && screenWidth >= 760;
    final leftPaneRatio = screenWidth >= 1200
        ? 0.34
        : screenWidth >= 900
            ? 0.38
            : 0.42;
    final leftPaneWidth = useTwoPaneLandscape
        ? (screenWidth * leftPaneRatio).clamp(300.0, 460.0)
        : screenWidth;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('WebView Debug Config'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: useTwoPaneLandscape
          ? Row(
              children: [
                SizedBox(
                  width: leftPaneWidth,
                  child: Column(
                    children: [
                      _buildOpenButton(
                        isLandscape: true,
                        compactHeight: isCompactLandscape,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            16,
                            isCompactLandscape ? 8 : 12,
                            16,
                            16,
                          ),
                          child: _buildInputSection(
                            compactSpacing: true,
                            compactHeight: isCompactLandscape,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      isCompactLandscape ? 8 : 12,
                      16,
                      16,
                    ),
                    child: _buildSettingsSection(
                      compactSpacing: true,
                      compactHeight: isCompactLandscape,
                    ),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                _buildOpenButton(
                  isLandscape: false,
                  compactHeight: isCompactLandscape,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      isCompactLandscape ? 12 : 16,
                      20,
                      20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputSection(
                          compactSpacing: false,
                          compactHeight: isCompactLandscape,
                        ),
                        const SizedBox(height: 24),
                        _buildSettingsSection(
                          compactSpacing: false,
                          compactHeight: isCompactLandscape,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildOpenButton({
    required bool isLandscape,
    required bool compactHeight,
  }) =>
      Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          16,
          isLandscape ? (compactHeight ? 8 : 10) : 14,
          16,
          compactHeight ? 8 : 10,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFFF5F5F5),
          border: Border(
            bottom: BorderSide(color: Color(0xFFE6E6E6)),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _openWebView,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: compactHeight ? 10 : (isLandscape ? 12 : 14),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Open WebView →',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      );

  Widget _buildInputSection({
    required bool compactSpacing,
    required bool compactHeight,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('URL'),
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
          SizedBox(height: compactSpacing || compactHeight ? 12 : 16),
          const _SectionLabel('Custom User Agent (optional)'),
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
        ],
      );

  Widget _buildSettingsSection({
    required bool compactSpacing,
    required bool compactHeight,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            onChanged: (v) => setState(
                () => _config = _config.copyWith(javaScriptEnabled: v)),
          ),
          _SettingRow(
            label: 'DOM Storage Enabled',
            value: _config.domStorageEnabled,
            onChanged: (v) => setState(
                () => _config = _config.copyWith(domStorageEnabled: v)),
          ),
          _SettingRow(
            label: 'Allow Mixed Content',
            value: _config.allowMixedContent,
            onChanged: (v) => setState(
                () => _config = _config.copyWith(allowMixedContent: v)),
          ),
          _SettingRow(
            label: 'Remote Debugging Enabled',
            value: _config.debuggingEnabled,
            onChanged: (v) =>
                setState(() => _config = _config.copyWith(debuggingEnabled: v)),
          ),
          SizedBox(height: compactSpacing || compactHeight ? 16 : 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: ExpansionTile(
              initiallyExpanded: _showAdvancedSettings,
              onExpansionChanged: (expanded) {
                setState(() {
                  _showAdvancedSettings = expanded;
                });
              },
              title: const Text(
                'Advanced InAppWebView Settings',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF444444)),
              ),
              childrenPadding: const EdgeInsets.fromLTRB(10, 4, 10, 14),
              children: [
                _SettingRow(
                  label: 'Support Zoom',
                  value: _config.supportZoom,
                  onChanged: (v) => setState(() => _config = _config.copyWith(
                        supportZoom: v,
                        enableViewportScale: v,
                        ignoresViewportScaleLimits: v,
                      )),
                ),
                _SettingRow(
                  label: 'Display Zoom Controls',
                  value: _config.displayZoomControls,
                  onChanged: (v) => setState(
                      () => _config = _config.copyWith(displayZoomControls: v)),
                ),
                _SettingRow(
                  label: 'Use Wide ViewPort',
                  value: _config.useWideViewPort,
                  onChanged: (v) => setState(
                      () => _config = _config.copyWith(useWideViewPort: v)),
                ),
                _SettingRow(
                  label: 'Load With Overview Mode',
                  value: _config.loadWithOverviewMode,
                  onChanged: (v) => setState(() =>
                      _config = _config.copyWith(loadWithOverviewMode: v)),
                ),
                _SettingRow(
                  label: 'Use On Load Resource',
                  value: _config.useOnLoadResource,
                  onChanged: (v) => setState(
                      () => _config = _config.copyWith(useOnLoadResource: v)),
                ),
                _SettingRow(
                  label: 'Geolocation Enabled',
                  value: _config.geolocationEnabled,
                  onChanged: (v) => setState(
                      () => _config = _config.copyWith(geolocationEnabled: v)),
                ),
                _SettingRow(
                  label: 'JavaScript Can Open Windows',
                  value: _config.javaScriptCanOpenWindowsAutomatically,
                  onChanged: (v) => setState(() => _config = _config.copyWith(
                      javaScriptCanOpenWindowsAutomatically: v)),
                ),
                _SettingRow(
                  label: 'Allow Universal Access From File URLs',
                  value: _config.allowUniversalAccessFromFileURLs,
                  onChanged: (v) => setState(() => _config =
                      _config.copyWith(allowUniversalAccessFromFileURLs: v)),
                ),
                _SettingRow(
                  label: 'Allow File Access From File URLs',
                  value: _config.allowFileAccessFromFileURLs,
                  onChanged: (v) => setState(() => _config =
                      _config.copyWith(allowFileAccessFromFileURLs: v)),
                ),
                _SettingRow(
                  label: 'Media Playback Requires User Gesture',
                  value: _config.mediaPlaybackRequiresUserGesture,
                  onChanged: (v) => setState(() => _config =
                      _config.copyWith(mediaPlaybackRequiresUserGesture: v)),
                ),
                _SettingRow(
                  label: 'Allows Inline Media Playback',
                  value: _config.allowsInlineMediaPlayback,
                  onChanged: (v) => setState(() =>
                      _config = _config.copyWith(allowsInlineMediaPlayback: v)),
                ),
                _SettingRow(
                  label: 'Transparent Background',
                  value: _config.transparentBackground,
                  onChanged: (v) => setState(() =>
                      _config = _config.copyWith(transparentBackground: v)),
                ),
                const SizedBox(height: 12),
                const _SectionLabel('Iframe Allow Permissions'),
                const SizedBox(height: 6),
                TextField(
                  controller: _iframeAllowController,
                  decoration: const InputDecoration(
                    hintText: 'camera; microphone; geolocation; fullscreen',
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
                  minLines: 2,
                  maxLines: 4,
                  autocorrect: false,
                ),
                const SizedBox(height: 12),
                const _SectionLabel(
                    'Application Name For User Agent (optional)'),
                const SizedBox(height: 6),
                TextField(
                  controller: _applicationNameForUserAgentController,
                  decoration: const InputDecoration(
                    hintText: 'ExampleApp/1.0.0',
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
              ],
            ),
          ),
        ],
      );
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
        child: Material(
          color: Colors.transparent,
          child: SwitchListTile(
            title: Text(label, style: const TextStyle(fontSize: 15)),
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF4A90E2),
          ),
        ),
      );
}
