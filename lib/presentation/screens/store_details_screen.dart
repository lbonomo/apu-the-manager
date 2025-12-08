import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/document.dart';
import '../providers/document_providers.dart';
import '../providers/store_providers.dart';
import 'upload_document_screen.dart';
import 'document_details_screen.dart';
import '../widgets/metadata_config_dialog.dart';
import '../widgets/metadata_filter_bar.dart';
import '../providers/metadata_filters_provider.dart';
import '../../domain/entities/custom_metadata.dart';

class StoreDetailsScreen extends ConsumerStatefulWidget {
  final String storeId;

  const StoreDetailsScreen({super.key, required this.storeId});

  @override
  ConsumerState<StoreDetailsScreen> createState() => _StoreDetailsScreenState();
}

class _StoreDetailsScreenState extends ConsumerState<StoreDetailsScreen> {
  final Set<String> _selectedDocumentIds = <String>{};
  bool _isBulkDeleting = false;
  late ScrollController _scrollController;
  bool _isLoadingMore = false;
  
  // Variables para ordenamiento
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore) return;
    if (!mounted) return;

    // Detectar cuando el usuario está cerca del final (90%)
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final threshold = maxScroll * 0.9;

    if (currentScroll >= threshold) {
      _loadMoreDocuments();
    }
  }

  Future<void> _loadMoreDocuments() async {
    if (_isLoadingMore) return;
    if (!mounted) return;

    final documentsAsync = ref.read(documentsListProvider(widget.storeId));
    final hasNextPage = documentsAsync.value?.nextPageToken != null;
    
    if (!hasNextPage) return;
    
    setState(() {
      _isLoadingMore = true;
    });

    try {
      await ref
          .read(documentsListProvider(widget.storeId).notifier)
          .loadMore();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  void _onSort<T>(
    Comparable<T> Function(Document d) getField,
    int columnIndex,
    bool ascending,
  ) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    final documentsAsync = ref.watch(documentsListProvider(widget.storeId));
    final storeAsync = ref.watch(storeByIdProvider(widget.storeId));

    return Scaffold(
      appBar: AppBar(
        title: storeAsync.when(
          data: (store) {
            if (store == null) return const Text('Store Documents');
            return Text('Corpus: ${store.displayName ?? store.name}');
          },
          loading: () => const Text('Store Documents'),
          error: (_, __) => const Text('Store Documents'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(documentsListProvider(widget.storeId));
            },
            tooltip: 'Refrescar',
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => MetadataConfigDialog(storeId: widget.storeId),
              );
            },
            tooltip: 'Configurar Metadatos',
          ),
        ],
      ),
      body: Column(
        children: [
          // Información del Corpus (Store)
          storeAsync.when(
            data: (store) {
              if (store == null) return const SizedBox.shrink();
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 12.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildInfoChip(
                          Icons.check_circle,
                          'Activos: ${store.activeDocumentsCount ?? 0}',
                          Colors.green,
                        ),
                        _buildInfoChip(
                          Icons.hourglass_empty,
                          'Pendientes: ${store.pendingDocumentsCount ?? 0}',
                          Colors.orange,
                        ),
                        _buildInfoChip(
                          Icons.error,
                          'Fallidos: ${store.failedDocumentsCount ?? 0}',
                          Colors.red,
                        ),
                        _buildInfoChip(
                          Icons.storage,
                          'Tamaño: ${_formatBytes(store.sizeBytes)}',
                          Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            ),
            error: (error, stack) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error cargando información del corpus: $error',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
          // Lista de documentos
          Expanded(
            child: documentsAsync.when(
        data: (paginatedResult) {
          // Crear copia para ordenar y filtrar
          var documents = List<Document>.from(paginatedResult.items);

          // Filtrado por Metadatos
          final filters = ref.watch(metadataFiltersProvider(widget.storeId));
          if (filters.isNotEmpty) {
            documents = documents.where((doc) {
              for (final entry in filters.entries) {
                final key = entry.key;
                final allowedValues = entry.value;
                if (allowedValues.isEmpty) continue;

                final hasMatch = doc.customMetadata?.any((m) {
                  return m.key == key && allowedValues.contains(m.displayValue);
                }) ?? false;

                if (!hasMatch) return false;
              }
              return true;
            }).toList();
          }

          if (_sortColumnIndex != null) {
            documents.sort((a, b) {
              final aValue = _getSortValue(a, _sortColumnIndex!);
              final bValue = _getSortValue(b, _sortColumnIndex!);
              return Comparable.compare(aValue, bValue);
            });
            if (!_sortAscending) {
               // Invertir lista manualmente o usar compareTo invertido
               // documents = documents.reversed.toList(); no ordena in-place
               // Mejor ordenar con a y b invertidos si ascendente es falso, pero arriba ya orderné
               // Simplemente invertimos
               final reversed = documents.reversed.toList();
               documents.clear();
               documents.addAll(reversed);
            }
          }

          if (documents.isEmpty) {
            return const Center(child: Text('No documents found.'));
          }
// ...
          return LayoutBuilder(
            builder: (context, constraints) {
              // Calculate widths for fixed columns
              const checkboxWidth = 56.0;
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
                  (checkboxWidth +
                      stateWidth +
                      sizeWidth +
                      mimeWidth +
                      createdWidth +
                      updatedWidth +
                      actionsWidth +
                      (columnSpacing * 7) +
                      (horizontalMargin * 2));

              // Definir anchos explícitos
              final colWidths = {
                'checkbox': checkboxWidth,
                'name': displayNameWidth,
                'state': stateWidth,
                'size': sizeWidth,
                'mime': mimeWidth,
                'created': createdWidth,
                'updated': updatedWidth,
                'actions': actionsWidth,
              };

              return Column(
                children: [
                   MetadataFilterBar(storeId: widget.storeId),
                   if (_selectedDocumentIds.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            horizontalMargin,
                            16,
                            horizontalMargin,
                            8,
                          ),
                          child: Material(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    '${_selectedDocumentIds.length} documentos seleccionados',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                  const Spacer(),
                                  TextButton.icon(
                                    onPressed: _isBulkDeleting
                                        ? null
                                        : () => _confirmBulkDelete(),
                                    icon: _isBulkDeleting
                                        ? const SizedBox(
                                            height: 16,
                                            width: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                    label: Text(
                                      _isBulkDeleting
                                          ? 'Eliminando...'
                                          : 'Eliminar seleccionados',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                  // Sticky Header
                  _buildStickyHeader(
                    context,
                    colWidths,
                    horizontalMargin,
                    columnSpacing,
                    documents.length,
                    documents.where((d) =>_selectedDocumentIds.contains(d.name)).length,
                     (selected) {
                        setState(() {
                          if (selected == true) {
                            _selectedDocumentIds.addAll(documents.map((d) => d.name));
                          } else {
                            _selectedDocumentIds.clear();
                          }
                        });
                     }
                  ),
                  
                  // Scrollable List
                  Expanded(
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(bottom: 80), // Espacio para FAB
                      itemCount: documents.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final document = documents[index];
                        final isSelected = _selectedDocumentIds.contains(document.name);
                        return _buildDocumentRow(
                          context,
                          document,
                          isSelected,
                          colWidths,
                          horizontalMargin,
                          columnSpacing,
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    ),
  ],
),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  UploadDocumentScreen(storeId: widget.storeId),
            ),
          );
        },
        child: const Icon(Icons.upload_file),
      ),
    );
  }

  Future<void> _confirmBulkDelete() async {
    final selectedIds = List<String>.unmodifiable(_selectedDocumentIds);
    final count = selectedIds.length;

    if (count == 0) {
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          count == 1
              ? '¿Deseas eliminar el documento seleccionado?'
              : '¿Deseas eliminar los $count documentos seleccionados?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) {
      return;
    }

    setState(() {
      _isBulkDeleting = true;
    });

    try {
      await ref
          .read(documentsListProvider(widget.storeId).notifier)
          .deleteDocuments(selectedIds);
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedDocumentIds.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            count == 1 ? 'Documento eliminado' : 'Documentos eliminados',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isBulkDeleting = false;
        });
      }
    }
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
      backgroundColor: color.withValues(alpha: 0.1),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        label,
        style: TextStyle(color: color, fontSize: 12),
      ),
      backgroundColor: color.withValues(alpha: 0.1),
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

  Comparable _getSortValue(Document d, int columnIndex) {
    switch (columnIndex) {
      case 0:
        return (d.displayName ?? d.name.split('/').last).toLowerCase();
      case 1:
        return d.state.toString();
      case 2:
        return d.sizeBytes ?? 0;
      case 3:
        return d.mimeType ?? '';
      case 4:
        return d.createTime ?? DateTime(0);
      case 5:
        return d.updateTime ?? DateTime(0);
      default:
        return '';
    }
  }
  Widget _buildStickyHeader(
    BuildContext context,
    Map<String, double> widths,
    double hMargin,
    double spacing,
    int totalDocs,
    int selectedDocs,
    ValueChanged<bool?> onSelectAll,
  ) {
    final theme = Theme.of(context);
    final borderSide = BorderSide(color: theme.dividerColor, width: 1);
    
    // Checkbox state
    bool? checkboxState = false;
    if (selectedDocs > 0) {
      checkboxState = selectedDocs == totalDocs ? true : null; // null es tristate (dash)
    }

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: borderSide),
        boxShadow: [
          BoxShadow(
             color: Colors.black.withValues(alpha: 0.05),
             offset: const Offset(0, 2),
             blurRadius: 4,
          )
        ]
      ),
      padding: EdgeInsets.symmetric(horizontal: hMargin),
      child: Row(
        children: [
          // Checkbox Column
          SizedBox(
            width: widths['checkbox'],
            child: Checkbox(
              value: checkboxState,
              tristate: true,
              onChanged: onSelectAll,
            ),
          ),
          SizedBox(width: spacing),
          
          // Columns
          _buildHeaderCell('Display Name', widths['name']!, 0),
          SizedBox(width: spacing),
          _buildHeaderCell('State', widths['state']!, 1),
          SizedBox(width: spacing),
          _buildHeaderCell('Size', widths['size']!, 2, numeric: true),
          SizedBox(width: spacing),
          _buildHeaderCell('MIME Type', widths['mime']!, 3),
          SizedBox(width: spacing),
          _buildHeaderCell('Created', widths['created']!, 4),
          SizedBox(width: spacing),
          _buildHeaderCell('Updated', widths['updated']!, 5),
          SizedBox(width: spacing),
          _buildHeaderCell('Actions', widths['actions']!, -1, sortable: false),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String label, double width, int colIndex, {bool numeric = false, bool sortable = true}) {
    final isSorted = _sortColumnIndex == colIndex;
    final isAscending = _sortAscending;
    final color = isSorted ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyMedium?.color;
    final fontWeight = isSorted ? FontWeight.bold : FontWeight.w500;

    Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: numeric ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(child: Text(label, style: TextStyle(color: color, fontWeight: fontWeight), overflow: TextOverflow.ellipsis)),
        if (isSorted) ...[
          const SizedBox(width: 4),
          Icon(
            isAscending ? Icons.arrow_upward : Icons.arrow_downward,
            size: 16,
            color: color,
          )
        ]
      ],
    );

    if (sortable) {
       child = InkWell(
         onTap: () {
           // final newAscending = isSorted ? !isAscending : true; // unused variable removed
           _handleSort(colIndex);
         },
         child: child,
       );
    }
    
    return SizedBox(
      width: width,
      child: Align(
        alignment: numeric ? Alignment.centerRight : Alignment.centerLeft,
        child: child,
      ),
    );
  }

  void _handleSort(int index) {
     switch(index) {
       case 0: _onSort<String>((d) => d.displayName ?? d.name.split('/').last, index, _sortColumnIndex == index ? !_sortAscending : true); break;
       case 1: _onSort<String>((d) => d.state.toString(), index, _sortColumnIndex == index ? !_sortAscending : true); break;
       case 2: _onSort<num>((d) => d.sizeBytes ?? 0, index, _sortColumnIndex == index ? !_sortAscending : true); break;
       case 3: _onSort<String>((d) => d.mimeType ?? '', index, _sortColumnIndex == index ? !_sortAscending : true); break;
       case 4: _onSort<DateTime>((d) => d.createTime ?? DateTime(0), index, _sortColumnIndex == index ? !_sortAscending : true); break;
       case 5: _onSort<DateTime>((d) => d.updateTime ?? DateTime(0), index, _sortColumnIndex == index ? !_sortAscending : true); break;
     }
  }

  Widget _buildDocumentRow(
    BuildContext context,
    Document document,
    bool isSelected,
    Map<String, double> widths,
    double hMargin,
    double spacing,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DocumentDetailsScreen(document: document),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: hMargin, vertical: 8),
        color: isSelected ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1) : null,
        child: Row(
          children: [
             SizedBox(
               width: widths['checkbox'],
               child: Checkbox(
                 value: isSelected,
                 onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selectedDocumentIds.add(document.name);
                      } else {
                        _selectedDocumentIds.remove(document.name);
                      }
                    });
                 },
               ),
             ),
             SizedBox(width: spacing),
             // Name
             SizedBox(
               width: widths['name'],
               child: Text(
                 document.displayName ?? document.name.split('/').last,
                 style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                 ),
                 overflow: TextOverflow.ellipsis,
               ),
             ),
             SizedBox(width: spacing),
             // State
             SizedBox(width: widths['state'], child: Align(alignment: Alignment.centerLeft, child: _buildStateChip(document.state))),
             SizedBox(width: spacing),
             // Size
             SizedBox(width: widths['size'], child: Text(_formatBytes(document.sizeBytes), textAlign: TextAlign.right)),
             SizedBox(width: spacing),
             // Mime
             SizedBox(width: widths['mime'], child: Text(document.mimeType ?? 'N/A', overflow: TextOverflow.ellipsis)),
             SizedBox(width: spacing),
             // Created
             SizedBox(width: widths['created'], child: Text(document.createTime != null ? _formatDateTime(document.createTime!) : 'N/A')),
             SizedBox(width: spacing),
             // Updated
             SizedBox(width: widths['updated'], child: Text(document.updateTime != null ? _formatDateTime(document.updateTime!) : 'N/A')),
             SizedBox(width: spacing),
             // Actions
             SizedBox(
               width: widths['actions'],
               child: IconButton(
                 icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                 onPressed: () => _deleteSingleDocument(document),
               ),
             ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteSingleDocument(Document document) async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: Text(
              'Are you sure you want to delete "${document.displayName ?? document.name.split('/').last}"?',
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext, false),child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(dialogContext, true),child: const Text('Delete')),
            ],
          ),
        );

        if (confirm == true && mounted) {
          try {
            await ref.read(documentsListProvider(widget.storeId).notifier).deleteDocument(document.name);
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Document deleted')));
          } catch (e) {
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
          }
        }
  }
}
