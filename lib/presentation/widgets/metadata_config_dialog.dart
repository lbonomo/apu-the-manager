import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/store_metadata_provider.dart';

class MetadataConfigDialog extends ConsumerStatefulWidget {
  final String storeId;

  const MetadataConfigDialog({super.key, required this.storeId});

  @override
  ConsumerState<MetadataConfigDialog> createState() => _MetadataConfigDialogState();
}

class _MetadataConfigDialogState extends ConsumerState<MetadataConfigDialog> {
  final _keyController = TextEditingController();
  final _valueController = TextEditingController();

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(storeMetadataConfigProvider(widget.storeId));

    return AlertDialog(
      title: const Text('Configuración de Metadatos'),
      content: SizedBox(
        width: 500,
        height: 400,
        child: configAsync.when(
          data: (config) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: config.fields.length,
                    itemBuilder: (context, index) {
                      final field = config.fields[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ExpansionTile(
                          title: Text(field.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => ref.read(storeMetadataConfigProvider(widget.storeId).notifier).removeField(field.key),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Valores posibles:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8.0,
                                    runSpacing: 8.0,
                                    children: [
                                      ...field.possibleValues.map((val) => Chip(
                                        label: Text(val),
                                        onDeleted: () => ref.read(storeMetadataConfigProvider(widget.storeId).notifier).removeValueFromField(field.key, val),
                                      )),
                                      ActionChip(
                                        avatar: const Icon(Icons.add, size: 16),
                                        label: const Text('Agregar Valor'),
                                        onPressed: () => _showAddValueDialog(context, field.key),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const Divider(),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _keyController,
                        decoration: const InputDecoration(
                          labelText: 'Nueva Clave',
                          hintText: 'ej. Año, Departamento',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onSubmitted: (_) => _submitKey(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _submitKey,
                      child: const Text('Agregar'),
                    ),
                  ],
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }

  void _submitKey() {
    if (_keyController.text.isNotEmpty) {
      ref.read(storeMetadataConfigProvider(widget.storeId).notifier).addField(_keyController.text.trim());
      _keyController.clear();
    }
  }

  Future<void> _showAddValueDialog(BuildContext context, String fieldKey) async {
    _valueController.clear();
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Agregar valor para "$fieldKey"'),
        content: TextField(
          controller: _valueController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Valor (ej. 2024)'),
          onSubmitted: (_) {
            _submitValue(dialogContext, fieldKey);
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          TextButton(onPressed: () => _submitValue(dialogContext, fieldKey), child: const Text('Agregar')),
        ],
      ),
    );
  }

  void _submitValue(BuildContext context, String fieldKey) {
    if (_valueController.text.isNotEmpty) {
      ref.read(storeMetadataConfigProvider(widget.storeId).notifier)
         .addValueToField(fieldKey, _valueController.text.trim());
      Navigator.pop(context);
    }
  }
}
