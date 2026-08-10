import 'dart:async';
import 'dart:io';
import 'dart:math' show min;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/network_entry.dart';
import 'config_screen.dart';
import 'network_panel.dart';

class PreviewScreen extends StatefulWidget {
  final WebViewConfig config;
  const PreviewScreen({super.key, required this.config});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  InAppWebViewController? _controller;
  bool _loading = true;
  bool _canGoBack = false;
  bool _canGoForward = false;
  bool _showFloatingActions = true;
  bool _loadFailed = false;
  String _currentUrl = '';
  Timer? _loadTimeout;
  double _lastScrollY = 0;
  late final ValueNotifier<List<NetworkEntry>> _networkLogNotifier;
  int _nextEntryId = 0;

  @override
  void initState() {
    super.initState();
    _networkLogNotifier = ValueNotifier([]);
    // rebuild badge count whenever the log changes
    _networkLogNotifier.addListener(() {
      if (mounted) setState(() {});
    });
    _currentUrl = widget.config.url;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _loadTimeout?.cancel();
    _networkLogNotifier.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _handleBackAction() async {
    final controller = _controller;
    if (controller == null) {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      return;
    }

    final canBack = await controller.canGoBack();
    if (canBack) {
      await controller.goBack();
      return;
    }

    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _startLoadTimeout() {
    _loadTimeout?.cancel();
    _loadTimeout = Timer(const Duration(seconds: 15), () {
      if (!mounted || !_loading) {
        return;
      }
      setState(() {
        _loading = false;
        _loadFailed = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The page did not load in time. Check the URL or network connection.',
          ),
        ),
      );
    });
  }

  Future<void> _openExternalUrl(String link) async {
    final uri = Uri.tryParse(link);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Map<String, String> _toStringMap(Map<String, dynamic>? map) =>
      map?.map((k, v) => MapEntry(k, v.toString())) ?? {};

  void _openNetworkPanel() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NetworkPanel(
        logNotifier: _networkLogNotifier,
        onClear: () => _networkLogNotifier.value = [],
      ),
    );
  }

  void _handleWebScroll(int y) {
    final currentY = y.toDouble();
    const delta = 10.0;
    final scrolledDown = currentY - _lastScrollY > delta;
    final scrolledUp = _lastScrollY - currentY > delta;

    if (scrolledDown && _showFloatingActions) {
      setState(() {
        _showFloatingActions = false;
      });
    } else if ((scrolledUp || currentY <= 0) && !_showFloatingActions) {
      setState(() {
        _showFloatingActions = true;
      });
    }

    _lastScrollY = currentY;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.config.url)),
            initialSettings: InAppWebViewSettings(
              supportZoom: widget.config.supportZoom,
              builtInZoomControls: widget.config.supportZoom,
              enableViewportScale: widget.config.enableViewportScale,
              ignoresViewportScaleLimits:
                  widget.config.ignoresViewportScaleLimits,
              displayZoomControls: widget.config.displayZoomControls,
              useWideViewPort: widget.config.useWideViewPort,
              loadWithOverviewMode: widget.config.loadWithOverviewMode,
              isInspectable:
                  widget.config.debuggingEnabled && Platform.isAndroid,
              javaScriptEnabled: widget.config.javaScriptEnabled,
              domStorageEnabled: widget.config.domStorageEnabled,
              useOnLoadResource: widget.config.useOnLoadResource,
              geolocationEnabled: widget.config.geolocationEnabled,
              javaScriptCanOpenWindowsAutomatically:
                  widget.config.javaScriptCanOpenWindowsAutomatically,
              allowUniversalAccessFromFileURLs:
                  widget.config.allowUniversalAccessFromFileURLs,
              allowFileAccessFromFileURLs:
                  widget.config.allowFileAccessFromFileURLs,
              mediaPlaybackRequiresUserGesture:
                  widget.config.mediaPlaybackRequiresUserGesture,
              allowsInlineMediaPlayback:
                  widget.config.allowsInlineMediaPlayback,
              iframeAllow: widget.config.iframeAllow,
              applicationNameForUserAgent:
                  widget.config.applicationNameForUserAgent,
              transparentBackground: widget.config.transparentBackground,
              userAgent: widget.config.userAgent.isEmpty
                  ? null
                  : widget.config.userAgent,
              mixedContentMode: widget.config.allowMixedContent
                  ? MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW
                  : MixedContentMode.MIXED_CONTENT_NEVER_ALLOW,
              useShouldInterceptAjaxRequest: true,
              useShouldInterceptFetchRequest: true,
            ),
            onWebViewCreated: (controller) {
              _controller = controller;
              controller.addJavaScriptHandler(
                handlerName: 'onBackPressed',
                callback: (args) {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              );
              controller.addJavaScriptHandler(
                handlerName: 'showLandscapeActions',
                callback: (args) async {
                  if (args.isNotEmpty) {
                    final show = args.first as bool? ?? true;
                    debugPrint('showLandscapeActions: $show');
                  }
                },
              );
              controller.addJavaScriptHandler(
                handlerName: 'rotate',
                callback: (args) async {
                  if (args.isNotEmpty) {
                    final orientation = args.first.toString().toLowerCase();
                    debugPrint('rotate: $orientation');
                  }
                },
              );
              controller.addJavaScriptHandler(
                handlerName: 'openExternalApplication',
                callback: (args) async {
                  if (args.isNotEmpty) {
                    final link = args.first.toString();
                    await _openExternalUrl(link);
                  }
                },
              );
              controller.addJavaScriptHandler(
                handlerName: 'openInAppWebView',
                callback: (args) async {
                  if (args.isNotEmpty) {
                    final link = args.first.toString();
                    if (link.isNotEmpty) {
                      await _controller?.loadUrl(
                        urlRequest: URLRequest(url: WebUri(link)),
                      );
                    }
                  }
                },
              );
            },
            onLoadStart: (controller, url) {
              _loadTimeout?.cancel();
              setState(() {
                _loading = true;
                _loadFailed = false;
                _currentUrl = url?.toString() ?? _currentUrl;
              });
              _startLoadTimeout();
            },
            onLoadStop: (controller, url) async {
              _loadTimeout?.cancel();
              final canBack = await controller.canGoBack();
              final canForward = await controller.canGoForward();
              setState(() {
                _loading = false;
                _loadFailed = false;
                _currentUrl = url?.toString() ?? _currentUrl;
                _canGoBack = canBack;
                _canGoForward = canForward;
              });
            },
            onReceivedError: (controller, request, error) {
              if (!(request.isForMainFrame ?? true)) return;
              _loadTimeout?.cancel();
              setState(() {
                _loading = false;
                _loadFailed = true;
              });
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${error.description}'),
                  ),
                );
              }
            },
            onScrollChanged: (controller, x, y) {
              _handleWebScroll(y);
            },
            shouldInterceptAjaxRequest: (controller, ajaxRequest) async {
              if (!mounted) return ajaxRequest;
              final entry = NetworkEntry(
                id: _nextEntryId++,
                url: ajaxRequest.url?.toString() ?? '',
                method: ajaxRequest.method ?? 'GET',
                requestHeaders: _toStringMap(ajaxRequest.headers?.getHeaders()),
                requestBody: ajaxRequest.data?.toString(),
                startTime: DateTime.now(),
                type: NetworkEntryType.xhr,
              );
              _networkLogNotifier.value = [..._networkLogNotifier.value, entry];
              return ajaxRequest;
            },
            onAjaxReadyStateChange: (controller, ajaxRequest) async {
              if (!mounted) return AjaxRequestAction.PROCEED;
              if (ajaxRequest.readyState != AjaxRequestReadyState.DONE) {
                return AjaxRequestAction.PROCEED;
              }
              final url = ajaxRequest.url?.toString() ?? '';
              final entries = _networkLogNotifier.value;
              final idx = entries.lastIndexWhere(
                (e) =>
                    e.url == url &&
                    e.type == NetworkEntryType.xhr &&
                    e.statusCode == null,
              );
              if (idx != -1) {
                final preview = ajaxRequest.responseText;
                final updated = entries[idx].copyWith(
                  statusCode: ajaxRequest.status,
                  endTime: DateTime.now(),
                  responseBodyPreview: preview?.substring(
                    0,
                    min(500, preview.length),
                  ),
                );
                final next = List<NetworkEntry>.from(entries);
                next[idx] = updated;
                _networkLogNotifier.value = next;
              }
              return AjaxRequestAction.PROCEED;
            },
            // Android-only; iOS Fetch calls are not intercepted by flutter_inappwebview
            shouldInterceptFetchRequest: (controller, fetchRequest) async {
              if (!mounted) return fetchRequest;
              final entry = NetworkEntry(
                id: _nextEntryId++,
                url: fetchRequest.url?.toString() ?? '',
                method: fetchRequest.method ?? 'GET',
                requestHeaders: _toStringMap(fetchRequest.headers),
                requestBody: fetchRequest.body?.toString(),
                startTime: DateTime.now(),
                type: NetworkEntryType.fetch,
              );
              _networkLogNotifier.value = [..._networkLogNotifier.value, entry];
              return fetchRequest;
            },
            onLoadResource: (controller, resource) {
              if (!mounted) return;
              final now = DateTime.now();
              final durationMs = resource.duration?.toInt() ?? 0;
              final entry = NetworkEntry(
                id: _nextEntryId++,
                url: resource.url?.toString() ?? '',
                method: 'GET',
                requestHeaders: const {},
                startTime: now.subtract(Duration(milliseconds: durationMs)),
                endTime: now,
                type: NetworkEntryType.resource,
              );
              _networkLogNotifier.value = [..._networkLogNotifier.value, entry];
            },
          ),
          Positioned(
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom + 16,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              offset: _showFloatingActions ? Offset.zero : const Offset(0, 1),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                opacity: _showFloatingActions ? 1 : 0,
                child: IgnorePointer(
                  ignoring: !_showFloatingActions,
                  child: Column(
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'webview-back-action',
                        backgroundColor: const Color(0xCC1A1A2E),
                        onPressed: _handleBackAction,
                        child: Icon(
                          Icons.arrow_back,
                          color: _canGoBack ? Colors.white : Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton.small(
                        heroTag: 'webview-forward-action',
                        backgroundColor: const Color(0xCC1A1A2E),
                        onPressed: _canGoForward
                            ? () => _controller?.goForward()
                            : null,
                        child: Icon(
                          Icons.arrow_forward,
                          color: _canGoForward ? Colors.white : Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton.small(
                        heroTag: 'webview-reload-action',
                        backgroundColor: const Color(0xCC1A1A2E),
                        onPressed: () => _controller?.reload(),
                        child: const Icon(Icons.refresh, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Badge(
                        isLabelVisible: _networkLogNotifier.value.isNotEmpty,
                        label: Text('${_networkLogNotifier.value.length}'),
                        child: FloatingActionButton.small(
                          heroTag: 'webview-network-action',
                          backgroundColor: const Color(0xCC1A1A2E),
                          onPressed: _openNetworkPanel,
                          child: const Icon(
                            Icons.network_check,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_loading) const Center(child: CircularProgressIndicator()),
          if (_loadFailed)
            Positioned.fill(
              child: Container(
                color: Colors.white.withValues(alpha: 0.95),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Unable to load the page.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Please check the URL or your network connection.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _controller?.reload(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
