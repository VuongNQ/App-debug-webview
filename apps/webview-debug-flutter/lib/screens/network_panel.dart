import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/network_entry.dart';

enum NetworkFilter { all, xhrFetch, doc, css, js, image, socket }

class NetworkPanel extends StatefulWidget {
  final ValueNotifier<List<NetworkEntry>> logNotifier;
  final VoidCallback onClear;

  const NetworkPanel({
    super.key,
    required this.logNotifier,
    required this.onClear,
  });

  @override
  State<NetworkPanel> createState() => _NetworkPanelState();
}

class _NetworkPanelState extends State<NetworkPanel> {
  NetworkFilter _activeFilter = NetworkFilter.all;

  static const _filterLabels = {
    NetworkFilter.all: 'All',
    NetworkFilter.xhrFetch: 'XHR/Fetch',
    NetworkFilter.doc: 'Doc',
    NetworkFilter.css: 'CSS',
    NetworkFilter.js: 'JS',
    NetworkFilter.image: 'Image',
    NetworkFilter.socket: 'Socket',
  };

  static bool _matchesFilter(NetworkEntry e, NetworkFilter f) {
    switch (f) {
      case NetworkFilter.all:
        return true;
      case NetworkFilter.xhrFetch:
        return e.type == NetworkEntryType.xhr ||
            e.type == NetworkEntryType.fetch;
      case NetworkFilter.doc:
        return e.type == NetworkEntryType.document;
      case NetworkFilter.css:
        return e.type == NetworkEntryType.stylesheet;
      case NetworkFilter.js:
        return e.type == NetworkEntryType.script;
      case NetworkFilter.image:
        return e.type == NetworkEntryType.image;
      case NetworkFilter.socket:
        return e.type == NetworkEntryType.socket;
    }
  }

  static Color methodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return Colors.blue.shade700;
      case 'POST':
        return Colors.green.shade700;
      case 'PUT':
        return Colors.orange.shade700;
      case 'DELETE':
        return Colors.red.shade700;
      case 'PATCH':
        return Colors.purple.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  static Color statusColor(int? status) {
    if (status == null) return Colors.grey;
    if (status < 300) return Colors.green.shade700;
    if (status < 400) return Colors.amber.shade700;
    if (status < 500) return Colors.red.shade700;
    return Colors.deepOrange.shade700;
  }

  static String durationLabel(Duration? d) {
    if (d == null) return '—';
    final ms = d.inMilliseconds;
    return ms < 1000 ? '${ms}ms' : '${(ms / 1000).toStringAsFixed(1)}s';
  }

  static String typeLabel(NetworkEntryType type) {
    switch (type) {
      case NetworkEntryType.xhr:
        return 'XHR';
      case NetworkEntryType.fetch:
        return 'FETCH';
      case NetworkEntryType.document:
        return 'DOC';
      case NetworkEntryType.stylesheet:
        return 'CSS';
      case NetworkEntryType.script:
        return 'JS';
      case NetworkEntryType.image:
        return 'IMG';
      case NetworkEntryType.media:
        return 'MEDIA';
      case NetworkEntryType.socket:
        return 'WS';
      case NetworkEntryType.other:
        return 'OTHER';
    }
  }

  static String _truncateUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    final path = uri.path.isEmpty ? '/' : uri.path;
    return '${uri.host}$path';
  }

  void _showDetail(BuildContext context, NetworkEntry entry) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _DetailDialog(entry: entry),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 1.0,
      expand: false,
      builder: (context, scrollController) {
        return Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              ValueListenableBuilder<List<NetworkEntry>>(
                valueListenable: widget.logNotifier,
                builder: (context, entries, _) {
                  final filtered = entries
                      .where((e) => _matchesFilter(e, _activeFilter))
                      .toList();
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.network_check, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Network',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(width: 6),
                            if (filtered.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${filtered.length}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed:
                                  entries.isEmpty ? null : widget.onClear,
                              icon: const Icon(Icons.delete_sweep, size: 16),
                              label: const Text('Clear'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 36,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          children: NetworkFilter.values.map((f) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                label: Text(_filterLabels[f]!),
                                selected: _activeFilter == f,
                                onSelected: (_) =>
                                    setState(() => _activeFilter = f),
                                labelStyle: const TextStyle(fontSize: 12),
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const Divider(height: 1),
              Expanded(
                child: ValueListenableBuilder<List<NetworkEntry>>(
                  valueListenable: widget.logNotifier,
                  builder: (context, entries, _) {
                    final filtered = entries
                        .where((e) => _matchesFilter(e, _activeFilter))
                        .toList();
                    if (filtered.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.wifi_off,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No requests captured for this filter.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      controller: scrollController,
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 16),
                      itemBuilder: (context, index) {
                        final entry = filtered[index];
                        return ListTile(
                          dense: true,
                          leading: _MethodBadge(entry.method),
                          title: Text(
                            _truncateUrl(entry.url),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                          subtitle: Text(
                            typeLabel(entry.type),
                            style: const TextStyle(fontSize: 11),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (entry.statusCode != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor(
                                      entry.statusCode,
                                    ).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: statusColor(entry.statusCode),
                                    ),
                                  ),
                                  child: Text(
                                    '${entry.statusCode}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: statusColor(entry.statusCode),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 2),
                              Text(
                                durationLabel(entry.duration),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          onTap: () => _showDetail(context, entry),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MethodBadge extends StatelessWidget {
  final String method;
  const _MethodBadge(this.method);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: _NetworkPanelState.methodColor(method),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        method.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _DetailDialog extends StatefulWidget {
  final NetworkEntry entry;
  const _DetailDialog({required this.entry});

  @override
  State<_DetailDialog> createState() => _DetailDialogState();
}

class _DetailDialogState extends State<_DetailDialog> {
  bool get _isXhrOrFetch =>
      widget.entry.type == NetworkEntryType.xhr ||
      widget.entry.type == NetworkEntryType.fetch;

  static String _buildCurl(NetworkEntry e) {
    final buf = StringBuffer('curl');
    if (e.method.toUpperCase() != 'GET') {
      buf.write(' -X ${e.method.toUpperCase()}');
    }
    buf.write(" '${e.url}'");
    for (final h in e.requestHeaders.entries) {
      buf.write(" \\\n  -H '${h.key}: ${h.value}'");
    }
    if (e.requestBody != null && e.requestBody!.isNotEmpty) {
      final body = e.requestBody!.replaceAll("'", r"'\''");
      buf.write(" \\\n  -d '$body'");
    }
    return buf.toString();
  }

  Future<void> _copy(BuildContext ctx, String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!ctx.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final hasResponse = entry.responseBodyPreview != null;

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Row(
        children: [
          _MethodBadge(entry.method),
          const SizedBox(width: 8),
          Text(
            _NetworkPanelState.typeLabel(entry.type),
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailSection('URL', entry.url),
              _DetailSection(
                'Status',
                entry.statusCode?.toString() ?? '— (pending)',
              ),
              _DetailSection(
                'Duration',
                _NetworkPanelState.durationLabel(entry.duration),
              ),
              if (entry.requestHeaders.isNotEmpty)
                _DetailSection(
                  'Request Headers',
                  entry.requestHeaders.entries
                      .map((e) => '${e.key}: ${e.value}')
                      .join('\n'),
                ),
              if (entry.requestBody != null && entry.requestBody!.isNotEmpty)
                _DetailSection('Request Body', entry.requestBody!),
              if (entry.responseHeaders.isNotEmpty)
                _DetailSection(
                  'Response Headers',
                  entry.responseHeaders.entries
                      .map((e) => '${e.key}: ${e.value}')
                      .join('\n'),
                ),
              if (hasResponse)
                _DetailSection('Response', entry.responseBodyPreview!),
            ],
          ),
        ),
      ),
      actions: [
        if (_isXhrOrFetch)
          TextButton.icon(
            icon: const Icon(Icons.terminal, size: 15),
            label: const Text('Copy as cURL'),
            onPressed: () => _copy(context, _buildCurl(entry), 'cURL command'),
          ),
        if (hasResponse)
          TextButton.icon(
            icon: const Icon(Icons.copy, size: 15),
            label: const Text('Copy Response'),
            onPressed: () =>
                _copy(context, entry.responseBodyPreview!, 'Response'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final String content;
  const _DetailSection(this.title, this.content);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            content,
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }
}
