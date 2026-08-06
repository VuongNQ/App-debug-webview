import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'config_screen.dart';

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
  bool _loadFailed = false;
  String _currentUrl = '';
  Timer? _loadTimeout;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.config.url;
  }

  @override
  void dispose() {
    _loadTimeout?.cancel();
    super.dispose();
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'The page did not load in time. Check the URL or network connection.',
            ),
          ),
        );
      }
    });
  }

  void _resetLoadState() {
    _loadTimeout?.cancel();
    setState(() {
      _loading = true;
      _loadFailed = false;
    });
  }

  Future<void> _openExternalUrl(String link) async {
    final uri = Uri.tryParse(link);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        leading: IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back to Config',
        ),
        title: Text(
          _currentUrl,
          style: const TextStyle(fontSize: 13, color: Color(0xFFCCCCCC)),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios,
                color: _canGoBack ? Colors.white : Colors.white38),
            onPressed: _canGoBack ? () => _controller?.goBack() : null,
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios,
                color: _canGoForward ? Colors.white : Colors.white38),
            onPressed: _canGoForward ? () => _controller?.goForward() : null,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _controller?.reload(),
          ),
        ],
        elevation: 0,
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.config.url)),
            initialSettings: InAppWebViewSettings(
              supportZoom: true,
              builtInZoomControls: true,
              enableViewportScale: true,
              ignoresViewportScaleLimits: true,
              displayZoomControls: false,
              useWideViewPort: true,
              loadWithOverviewMode: true,
              isInspectable:
                  widget.config.debuggingEnabled && Platform.isAndroid,
              javaScriptEnabled: widget.config.javaScriptEnabled,
              domStorageEnabled: widget.config.domStorageEnabled,
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
              userAgent: widget.config.userAgent.isEmpty
                  ? null
                  : widget.config.userAgent,
              mixedContentMode: widget.config.allowMixedContent
                  ? MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW
                  : MixedContentMode.MIXED_CONTENT_NEVER_ALLOW,
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
              _resetLoadState();
              _startLoadTimeout();
              setState(() {
                _currentUrl = url?.toString() ?? _currentUrl;
              });
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
          ),
          if (_loading) const Center(child: CircularProgressIndicator()),
          if (_loadFailed)
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.95),
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
          if (widget.config.debuggingEnabled && Platform.isAndroid)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: const Color(0xFF1A1A2E),
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: const Text(
                  '🔍 Remote debugging: chrome://inspect',
                  style: TextStyle(color: Color(0xFFAAFFDD), fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
