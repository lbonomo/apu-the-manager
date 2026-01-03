import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/store_providers.dart';
import 'create_store_screen.dart';
import 'store_details_screen.dart';

import 'settings_screen.dart';

class StoresScreen extends ConsumerStatefulWidget {
  const StoresScreen({super.key});

  @override
  ConsumerState<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends ConsumerState<StoresScreen> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  DateTime? _parseDate(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is DateTime) return timestamp.toLocal();
    if (timestamp is String) return DateTime.tryParse(timestamp)?.toLocal();
    return null;
  }

  num? _parseNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }

  int _compareValues<T extends Comparable<T>>(T? a, T? b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;
    return a.compareTo(b);
  }

  List<dynamic> _sortedStores(List<dynamic> stores) {
    final sorted = List<dynamic>.of(stores);
    sorted.sort((a, b) {
      int result;
      switch (_sortColumnIndex) {
        case 0:
          final aName = (a.displayName ?? a.name ?? '').toString().toLowerCase();
          final bName = (b.displayName ?? b.name ?? '').toString().toLowerCase();
          result = _compareValues<String>(aName, bName);
          break;
        case 1:
          result = _compareValues<DateTime>(
            _parseDate(a.createTime),
            _parseDate(b.createTime),
          );
          break;
        case 2:
          result = _compareValues<DateTime>(
            _parseDate(a.updateTime),
            _parseDate(b.updateTime),
          );
          break;
        case 3:
          result = _compareValues<num>(_parseNum(a.activeDocumentsCount) ?? 0, _parseNum(b.activeDocumentsCount) ?? 0);
          break;
        case 4:
          result = _compareValues<num>(_parseNum(a.sizeBytes) ?? 0, _parseNum(b.sizeBytes) ?? 0);
          break;
        default:
          final aNameFallback = (a.displayName ?? a.name ?? '').toString().toLowerCase();
          final bNameFallback = (b.displayName ?? b.name ?? '').toString().toLowerCase();
          result = _compareValues<String>(aNameFallback, bNameFallback);
      }
      return _sortAscending ? result : -result;
    });
    return sorted;
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '-';
    if (timestamp is DateTime) {
      return timestamp.toLocal().toString().split('.').first;
    }
    if (timestamp is String) {
      final parsed = DateTime.tryParse(timestamp);
      if (parsed != null) {
        return parsed.toLocal().toString().split('.').first;
      }
      return timestamp;
    }
    return timestamp.toString();
  }

  String _formatBytes(num? bytes) {
    if (bytes == null) return '-';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var value = bytes.toDouble();
    var unitIndex = 0;
    while (value >= 1024 && unitIndex < units.length - 1) {
      value /= 1024;
      unitIndex++;
    }
    final precision = value >= 10 ? 0 : 1;
    return '${value.toStringAsFixed(precision)} ${units[unitIndex]}';
  }

  @override
  Widget build(BuildContext context) {
    final storesAsync = ref.watch(storesListProvider);

    return Scaffold(
      // Tools bar.
      appBar: AppBar(
        title: const Text('Stores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              return ref.invalidate(storesListProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: storesAsync.when(
        data: (stores) {
          final sortedStores = _sortedStores(stores);

          if (stores.isEmpty) {
            return const Center(child: Text('No stores found.'));
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              const columnSpacing = 16.0;
              const dateColumnWidth = 160.0;
              const documentsColumnWidth = 100.0;
              const sizeColumnWidth = 100.0;
              const actionColumnWidth = 100.0;
              const edgePadding = 32.0; // 16 left + 16 right
              final fixedColumnsWidth = (columnSpacing * 5) +
                  (dateColumnWidth * 2) +
                  documentsColumnWidth +
                  sizeColumnWidth +
                  actionColumnWidth;
              final nameColumnWidth = ((constraints.maxWidth - edgePadding) - fixedColumnsWidth).clamp(150.0, double.infinity);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortAscending,
                    columnSpacing: columnSpacing,
                    showCheckboxColumn: false,
                    // Columns of the data table.
                    columns: [
                      DataColumn(
                        label: const Text('Nombre'),
                        onSort: (columnIndex, ascending) {
                          setState(() {
                            _sortColumnIndex = columnIndex;
                            _sortAscending = ascending;
                          });
                        },
                      ),
                      DataColumn(
                        label: const Text('Creado'),
                        onSort: (columnIndex, ascending) {
                          setState(() {
                            _sortColumnIndex = columnIndex;
                            _sortAscending = ascending;
                          });
                        },
                      ),
                      DataColumn(
                        label: const Text('Actualizado'),
                        onSort: (columnIndex, ascending) {
                          setState(() {
                            _sortColumnIndex = columnIndex;
                            _sortAscending = ascending;
                          });
                        },
                      ),
                      DataColumn(
                        label: const Text('Documentos'),
                        numeric: true,
                        onSort: (columnIndex, ascending) {
                          setState(() {
                            _sortColumnIndex = columnIndex;
                            _sortAscending = ascending;
                          });
                        },
                      ),
                      DataColumn(
                        label: const Text('Tamaño'),
                        numeric: true,
                        onSort: (columnIndex, ascending) {
                          setState(() {
                            _sortColumnIndex = columnIndex;
                            _sortAscending = ascending;
                          });
                        },
                      ),
                      DataColumn(
                        label: const Text('Acciones'),
                      ),
                    ],
                    rows: sortedStores.map((store) {
                      return DataRow(
                        onSelectChanged: (_) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  StoreDetailsScreen(storeId: store.name),
                            ),
                          );
                        },
                        color: WidgetStateProperty.resolveWith<Color?>(
                          (states) => states.contains(WidgetState.hovered)
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.08)
                              : null,
                        ),
                        cells: [
                          DataCell(
                            SizedBox(
                              width: nameColumnWidth,
                              child: Text(
                                store.displayName ?? store.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: dateColumnWidth,
                              child: Text(_formatDate(store.createTime)),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: dateColumnWidth,
                              child: Text(_formatDate(store.updateTime)),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: documentsColumnWidth,
                              child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text('${store.activeDocumentsCount ?? 0}'),
                                ),
                              ),
                          ),
                          DataCell(
                            SizedBox(
                              width: sizeColumnWidth,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(_formatBytes(store.sizeBytes)),
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: actionColumnWidth,
                              child: Center(
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  tooltip: 'Eliminar',
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (dialogContext) => AlertDialog(
                                        title: const Text('Confirmar eliminación'),
                                        content: Text(
                                          '¿Deseas eliminar el store "${store.displayName ?? store.name}"?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(
                                              dialogContext,
                                              false,
                                            ),
                                            child: const Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(
                                              dialogContext,
                                              true,
                                            ),
                                            child: const Text('Eliminar'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true && context.mounted) {
                                      try {
                                        await ref
                                            .read(storesListProvider.notifier)
                                            .deleteStore(store.name);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text('Store eliminado'),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
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
                          ),
                        ],
                      );
                    }).toList(),
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
            MaterialPageRoute(builder: (context) => const CreateStoreScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
