import 'package:flutter/material.dart';
import '../models/network_entry.dart';

class NetworkPanel extends StatelessWidget {
  final ValueNotifier<List<NetworkEntry>> logNotifier;
  final VoidCallback onClear;

  const NetworkPanel({
    super.key,
    required this.logNotifier,
    required this.onClear,
  });

  static Color _methodColor(String method) {
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

  static Color _statusColor(int? status) {
    if (status == null) return Colors.grey;
    if (status < 300) return Colors.green.shade700;
    if (status < 400) return Colors.amber.shade700;
    if (status < 500) return Colors.red.shade700;
    return Colors.deepOrange.shade700;
  }

  static String _durationLabel(Duration? d) {
    if (d == null) return '—';
    final ms = d.inMilliseconds;
    return ms < 1000 ? '${ms}ms' : '${(ms / 1000).toStringAsFixed(1)}s';
  }

  static String _typeLabel(NetworkEntryType type) {
    switch (type) {
      case NetworkEntryType.xhr:
        return 'XHR';
      case NetworkEntryType.fetch:
        return 'FETCH';
      case NetworkEntryType.resource:
        return 'RES';
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
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            _MethodBadge(entry.method),
            const SizedBox(width: 8),
            Text(
              _typeLabel(entry.type),
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailSection('URL', entry.url),
              _DetailSection(
                'Status',
                entry.statusCode?.toString() ?? '— (pending)',
              ),
              _DetailSection('Duration', _durationLabel(entry.duration)),
              if (entry.contentLength != null)
                _DetailSection('Transfer Size', '${entry.contentLength} B'),
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
              if (entry.responseBodyPreview != null)
                _DetailSection(
                  'Response Preview',
                  entry.responseBodyPreview!,
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
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
                valueListenable: logNotifier,
                builder: (context, entries, _) => Padding(
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
                      if (entries.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${entries.length}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: entries.isEmpty ? null : onClear,
                        icon: const Icon(Icons.delete_sweep, size: 16),
                        label: const Text('Clear'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ValueListenableBuilder<List<NetworkEntry>>(
                  valueListenable: logNotifier,
                  builder: (context, entries, _) {
                    if (entries.isEmpty) {
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
                              'No network requests captured yet.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      controller: scrollController,
                      itemCount: entries.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 16),
                      itemBuilder: (context, index) {
                        final entry = entries[index];
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
                            _typeLabel(entry.type),
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
                                    color: _statusColor(
                                      entry.statusCode,
                                    ).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: _statusColor(entry.statusCode),
                                    ),
                                  ),
                                  child: Text(
                                    '${entry.statusCode}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: _statusColor(entry.statusCode),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 2),
                              Text(
                                _durationLabel(entry.duration),
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
        color: NetworkPanel._methodColor(method),
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
