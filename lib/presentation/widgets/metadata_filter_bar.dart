import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/store_metadata_provider.dart';
import '../providers/metadata_filters_provider.dart';

class MetadataFilterBar extends ConsumerWidget {
  final String storeId;

  const MetadataFilterBar({super.key, required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(storeMetadataConfigProvider(storeId));
    final filters = ref.watch(metadataFiltersProvider(storeId));

    return configAsync.when(
      data: (config) {
        if (config.fields.isEmpty) return const SizedBox.shrink();

        // Filtramos solo campos con valores posibles definidos
        final activeFields = config.fields.where((f) => f.possibleValues.isNotEmpty).toList();
        if (activeFields.isEmpty) return const SizedBox.shrink();

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: activeFields.map((field) {
              final selectedValues = filters[field.key] ?? {};
              final isActive = selectedValues.isNotEmpty;

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(
                    isActive ? '${field.key}: ${selectedValues.length}' : field.key,
                    style: TextStyle(
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isActive,
                  onSelected: (_) {
                    _showFilterDialog(context, ref, field.key, field.possibleValues, selectedValues);
                  },
                  onDeleted: isActive
                      ? () {
                          // Clear filter for this key
                          final map = Map<String, Set<String>>.from(ref.read(metadataFiltersProvider(storeId)));
                          map.remove(field.key);
                          ref.read(metadataFiltersProvider(storeId).notifier).state = map;
                        }
                      : null,
                ),
              );
            }).toList(),
          ),
        );
      },
      loading: () => const SizedBox(height: 50, child: Center(child: CircularProgressIndicator())),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _showFilterDialog(
    BuildContext context,
    WidgetRef ref,
    String key,
    List<String> possibleValues,
    Set<String> currentSelected,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return _FilterValuesDialog(
          title: key,
          possibleValues: possibleValues,
          initialSelected: currentSelected,
          onApply: (newSelection) {
            final map = Map<String, Set<String>>.from(ref.read(metadataFiltersProvider(storeId)));
            if (newSelection.isEmpty) {
              map.remove(key);
            } else {
              map[key] = newSelection;
            }
            ref.read(metadataFiltersProvider(storeId).notifier).state = map;
          },
        );
      },
    );
  }
}

class _FilterValuesDialog extends StatefulWidget {
  final String title;
  final List<String> possibleValues;
  final Set<String> initialSelected;
  final ValueChanged<Set<String>> onApply;

  const _FilterValuesDialog({
    required this.title,
    required this.possibleValues,
    required this.initialSelected,
    required this.onApply,
  });

  @override
  State<_FilterValuesDialog> createState() => _FilterValuesDialogState();
}

class _FilterValuesDialogState extends State<_FilterValuesDialog> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.initialSelected);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Filtrar por ${widget.title}'),
      content: SizedBox(
        width: 300,
        height: 400,
        child: ListView.builder(
          itemCount: widget.possibleValues.length,
          itemBuilder: (context, index) {
            final value = widget.possibleValues[index];
            final isChecked = _selected.contains(value);
            return CheckboxListTile(
              title: Text(value),
              value: isChecked,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    _selected.add(value);
                  } else {
                    _selected.remove(value);
                  }
                });
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            widget.onApply(_selected);
            Navigator.pop(context);
          },
          child: const Text('Aplicar'),
        ),
      ],
    );
  }
}
