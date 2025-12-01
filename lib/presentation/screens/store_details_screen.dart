import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/document.dart';
import '../providers/document_providers.dart';
import 'upload_document_screen.dart';

class StoreDetailsScreen extends ConsumerWidget {
  final String storeId;

  const StoreDetailsScreen({super.key, required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsAsync = ref.watch(documentsListProvider(storeId));

    return Scaffold(
      appBar: AppBar(title: const Text('Store Documents')),
      body: documentsAsync.when(
        data: (paginatedResult) {
          final documents = paginatedResult.items;
          if (documents.isEmpty) {
            return const Center(child: Text('No documents found.'));
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              // Calculate widths for fixed columns
              const stateWidth = 120.0;
              const sizeWidth = 100.0;
              const mimeWidth = 150.0;
              const createdWidth = 120.0;
              const updatedWidth = 120.0;
              const actionsWidth = 80.0;
              const columnSpacing = 16.0;
              const horizontalMargin = 24.0;

              // Calculate remaining width for Display Name
              final displayNameWidth =
                  constraints.maxWidth -
                  (stateWidth +
                      sizeWidth +
                      mimeWidth +
                      createdWidth +
                      updatedWidth +
                      actionsWidth +
                      (columnSpacing * 6) +
                      (horizontalMargin * 2));

              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SizedBox(
                  width: constraints.maxWidth,
                  child: Column(
                    children: [
                      DataTable(
                        columnSpacing: columnSpacing,
                        horizontalMargin: horizontalMargin,
                        columns: const [
                          DataColumn(label: Text('Display Name')),
                          DataColumn(label: Text('State')),
                          DataColumn(label: Text('Size')),
                          DataColumn(label: Text('MIME Type')),
                          DataColumn(label: Text('Created')),
                          DataColumn(label: Text('Updated')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: documents.map((document) {
                          return DataRow(
                            cells: [
                              DataCell(
                                SizedBox(
                                  width: displayNameWidth > 200
                                      ? displayNameWidth
                                      : 200,
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: InkWell(
                                      onTap: () => _showDocumentContentDialog(
                                        context,
                                        ref,
                                        document,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        child: Text(
                                          document.displayName ??
                                              document.name.split('/').last,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: stateWidth,
                                  child: _buildStateChip(document.state),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: sizeWidth,
                                  child: Text(_formatBytes(document.sizeBytes)),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: mimeWidth,
                                  child: Text(
                                    document.mimeType ?? 'N/A',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: createdWidth,
                                  child: Text(
                                    document.createTime != null
                                        ? _formatDateTime(document.createTime!)
                                        : 'N/A',
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: updatedWidth,
                                  child: Text(
                                    document.updateTime != null
                                        ? _formatDateTime(document.updateTime!)
                                        : 'N/A',
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: actionsWidth,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Confirm Delete'),
                                          content: Text(
                                            'Are you sure you want to delete "${document.displayName ?? document.name.split('/').last}"?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true && context.mounted) {
                                        try {
                                          await ref
                                              .read(
                                                documentsListProvider(
                                                  storeId,
                                                ).notifier,
                                              )
                                              .deleteDocument(document.name);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Document deleted',
                                                ),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text('Error: $e'),
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                      if (paginatedResult.nextPageToken != null)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ref
                                  .read(documentsListProvider(storeId).notifier)
                                  .loadMore();
                            },
                            icon: const Icon(Icons.arrow_downward),
                            label: const Text('Load More'),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UploadDocumentScreen(storeId: storeId),
            ),
          );
        },
        child: const Icon(Icons.upload_file),
      ),
    );
  }

  Widget _buildStateChip(DocumentState state) {
    Color color;
    IconData icon;

    switch (state) {
      case DocumentState.active:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case DocumentState.pending:
        color = Colors.orange;
        icon = Icons.hourglass_empty;
        break;
      case DocumentState.failed:
        color = Colors.red;
        icon = Icons.error;
        break;
      case DocumentState.unspecified:
        color = Colors.grey;
        icon = Icons.help;
        break;
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        state.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 12),
      ),
      backgroundColor: color.withOpacity(0.1),
    );
  }

  String _formatBytes(int? bytes) {
    if (bytes == null) return 'N/A';
    if (bytes == 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    var size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return '${size.toStringAsFixed(2)} ${suffixes[i]}';
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  void _showDocumentContentDialog(
    BuildContext context,
    WidgetRef ref,
    Document document,
  ) {
    final rootContext = context;
    final scaffoldMessenger = ScaffoldMessenger.of(rootContext);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Consumer(
          builder: (dialogConsumerContext, dialogRef, _) {
            final contentAsync = dialogRef.watch(
              documentContentProvider(document),
            );

            return AlertDialog(
              title: Text(
                document.displayName ?? document.name.split('/').last,
                overflow: TextOverflow.ellipsis,
              ),
              content: SizedBox(
                width: 600,
                height: 400,
                child: contentAsync.when(
                  data: (content) {
                    if (content.isBinary) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: SelectableText(
                                content.textPreview,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tamaño: ${content.byteLength} bytes',
                            style: Theme.of(dialogContext).textTheme.bodySmall,
                          ),
                          Text(
                            'Tipo MIME: ${content.mimeType ?? 'desconocido'}',
                            style: Theme.of(dialogContext).textTheme.bodySmall,
                          ),
                          if (content.downloadUri != null) ...[
                            const SizedBox(height: 12),
                            SelectableText(
                              content.downloadUri!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: () async {
                                  await Clipboard.setData(
                                    ClipboardData(text: content.downloadUri!),
                                  );
                                  scaffoldMessenger.showSnackBar(
                                    const SnackBar(
                                      content: Text('Enlace copiado'),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.copy, size: 18),
                                label: const Text('Copiar enlace'),
                              ),
                            ),
                          ],
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: SelectableText(
                              content.textPreview,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tamaño: ${content.byteLength} bytes',
                          style: Theme.of(dialogContext).textTheme.bodySmall,
                        ),
                        Text(
                          'Codificación: '
                          '${content.encoding?.toUpperCase() ?? 'UTF-8'}'
                          '${content.isTruncated ? ' · Contenido truncado' : ''}',
                          style: Theme.of(dialogContext).textTheme.bodySmall,
                        ),
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Text(
                      'Error: $error',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cerrar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
