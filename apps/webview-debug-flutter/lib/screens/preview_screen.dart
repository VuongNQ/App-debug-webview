import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'config_screen.dart';

class PreviewScreen extends StatefulWidget {
  final WebViewConfig config;
  const PreviewScreen({super.key, required this.config});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _canGoBack = false;
  bool _canGoForward = false;
  String _currentUrl = '';

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.config.url;

    _controller = WebViewController()
      ..setJavaScriptMode(widget.config.javaScriptEnabled
          ? JavaScriptMode.unrestricted
          : JavaScriptMode.disabled)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) => setState(() {
          _loading = true;
          _currentUrl = url;
        }),
        onPageFinished: (url) async {
          final canBack = await _controller.canGoBack();
          final canForward = await _controller.canGoForward();
          setState(() {
            _loading = false;
            _canGoBack = canBack;
            _canGoForward = canForward;
          });
        },
        onWebResourceError: (error) {
          setState(() => _loading = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Error: ${error.description} (${error.errorCode})')),
            );
          }
        },
      ));

    if (widget.config.userAgent.isNotEmpty) {
      _controller.setUserAgent(widget.config.userAgent);
    }

    // Enable remote debugging on Android
    if (Platform.isAndroid) {
      WebViewController.enableDebugging(widget.config.debuggingEnabled);
    }

    _controller.loadRequest(Uri.parse(widget.config.url));
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
            onPressed: _canGoBack ? () => _controller.goBack() : null,
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios,
                color: _canGoForward ? Colors.white : Colors.white38),
            onPressed: _canGoForward ? () => _controller.goForward() : null,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _controller.reload(),
          ),
        ],
        elevation: 0,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const Center(child: CircularProgressIndicator()),
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
