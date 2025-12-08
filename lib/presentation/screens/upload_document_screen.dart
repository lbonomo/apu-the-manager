import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/document_providers.dart';
import '../providers/core_providers.dart';

/// Representa un campo de metadata personalizado
class MetadataField {
  String key;
  String value;
  MetadataFieldType type;

  MetadataField({
    required this.key,
    required this.value,
    this.type = MetadataFieldType.string,
  });

  /// Convierte el valor al tipo apropiado para enviarlo a la API
  dynamic get apiValue {
    if (type == MetadataFieldType.numeric) {
      return double.tryParse(value) ?? 0.0;
    } else if (type == MetadataFieldType.stringList) {
      // Para listas, separamos por comas y limpiamos espacios
      return value
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return value;
  }
}

enum MetadataFieldType {
  string,
  numeric,
  stringList,
}

class UploadDocumentScreen extends ConsumerStatefulWidget {
  final String storeId;

  const UploadDocumentScreen({super.key, required this.storeId});

  @override
  ConsumerState<UploadDocumentScreen> createState() =>
      _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends ConsumerState<UploadDocumentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  File? _selectedFile;
  bool _isLoading = false;

  // Lista de campos de metadata personalizados
  final List<MetadataField> _metadataFields = [];

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();



    if (result != null) {
      final file = File(result.files.single.path!);
      setState(() {
        _selectedFile = file;
        if (_displayNameController.text.isEmpty) {
          _displayNameController.text = result.files.single.name;
        }
        // Limpiar metadata anterior al seleccionar nuevo archivo
        _metadataFields.clear();
      });

      // Intentar cargar metadata desde JSON asociado
      await _tryLoadMetadataJson(file.path);
    }
  }

  Future<void> _tryLoadMetadataJson(String filePath) async {
    final logger = ref.read(loggerServiceProvider);
    logger.i('Buscando archivo JSON de metadata para: $filePath');
    
    try {
      // Intentar con extensión reemplazada (ej: archivo.pdf -> archivo.json)
      String jsonPath = p.setExtension(filePath, '.json');
      File jsonFile = File(jsonPath);

      if (!await jsonFile.exists()) {
        // Intentar añadiendo extensión (ej: archivo.pdf -> archivo.pdf.json)
        jsonPath = '$filePath.json';
        jsonFile = File(jsonPath);
      }

      if (await jsonFile.exists()) {
        logger.i('Archivo JSON encontrado: $jsonPath. Leyendo contenido...');
        final content = await jsonFile.readAsString();
        final dynamic jsonData = jsonDecode(content);

        final List<MetadataField> newFields = [];

        if (jsonData is Map<String, dynamic>) {
          // Caso 1: Estructura { "customMetadata": [...] }
          if (jsonData.containsKey('customMetadata') &&
              jsonData['customMetadata'] is List) {
            _parseMetadataList(jsonData['customMetadata'], newFields);
          } 
          // Caso 2: Estructura simple clave-valor { "autor": "Juan", ... }
          else {
            _parseSimpleMap(jsonData, newFields);
          }
        } else if (jsonData is List) {
          // Caso 3: Array directo de metadatos [{ "key": ... }]
          _parseMetadataList(jsonData, newFields);
        }

        if (newFields.isNotEmpty) {
          logger.i('Se cargaron ${newFields.length} campos de metadata desde JSON.');
          setState(() {
            _metadataFields.addAll(newFields);
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Metadata cargado desde ${p.basename(jsonPath)}'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          logger.w('El archivo JSON existe pero no se encontraron campos válidos.');
        }
      } else {
        logger.i('No se encontró archivo JSON sidecar.');
      }
    } catch (e) {
      logger.e('Error al leer/procesar JSON de metadata', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al leer JSON de metadata: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  String _sanitizeKey(String key) {
    // Reemplazar espacios con guiones bajos y remover caracteres inválidos
    // Solo permite alfanuméricos, guiones y guiones bajos
    // También removemos acentos básicos para evitar problemas
    return key.trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[áàäâ]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöô]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u')
        .replaceAll(RegExp(r'[ñ]'), 'n')
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^a-z0-9_-]'), '');
  }

  void _parseMetadataList(List<dynamic> list, List<MetadataField> fields) {
    for (var item in list) {
      if (item is Map<String, dynamic> && item.containsKey('key')) {
        final rawKey = item['key'] as String;
        final key = _sanitizeKey(rawKey);
        
        if (item.containsKey('stringValue')) {
          fields.add(MetadataField(
            key: key,
            value: item['stringValue'].toString(),
            type: MetadataFieldType.string,
          ));
        } else if (item.containsKey('numericValue')) {
          fields.add(MetadataField(
            key: key,
            value: item['numericValue'].toString(),
            type: MetadataFieldType.numeric,
          ));
        } else if (item.containsKey('stringListValue')) {
          // Manejar formato complejo { "values": ["a", "b"] }
          final listValue = item['stringListValue'];
          if (listValue is Map && listValue.containsKey('values')) {
            final values = listValue['values'];
            if (values is List) {
               fields.add(MetadataField(
                key: key,
                value: values.join(', '),
                type: MetadataFieldType.stringList,
              ));
            }
          }
        }
      }
    }
  }

  void _parseSimpleMap(Map<String, dynamic> map, List<MetadataField> fields) {
    map.forEach((key, value) {
      // Ignorar claves que no sean metadatos (como displayName si viniera en el root)
      if (key == 'displayName' || key == 'name' || key == 'customMetadata') return;

      final sanitizedKey = _sanitizeKey(key);

      if (value is String) {
        fields.add(MetadataField(
          key: sanitizedKey,
          value: value,
          type: MetadataFieldType.string,
        ));
      } else if (value is num) {
        fields.add(MetadataField(
          key: sanitizedKey,
          value: value.toString(),
          type: MetadataFieldType.numeric,
        ));
      } else if (value is List) {
        // Asumir lista de strings
        fields.add(MetadataField(
          key: sanitizedKey,
          value: value.join(', '),
          type: MetadataFieldType.stringList,
        ));
      }
    });
  }

  void _addMetadataField() {
    setState(() {
      _metadataFields.add(
        MetadataField(
          key: '',
          value: '',
          type: MetadataFieldType.string,
        ),
      );
    });
  }

  void _removeMetadataField(int index) {
    setState(() {
      _metadataFields.removeAt(index);
    });
  }

  Future<void> _uploadDocument() async {
    if (_formKey.currentState!.validate() && _selectedFile != null) {
      // Validar que todos los campos de metadata tengan clave
      for (var field in _metadataFields) {
        if (field.key.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Todos los campos de metadata deben tener una clave'),
            ),
          );
          return;
        }
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Construir el mapa de customMetadata
        Map<String, dynamic>? customMetadata;
        if (_metadataFields.isNotEmpty) {
          customMetadata = {};
          for (var field in _metadataFields) {
            if (field.key.isNotEmpty) {
              customMetadata[field.key] = field.apiValue;
            }
          }
        }

        await ref
            .read(documentsListProvider(widget.storeId).notifier)
            .uploadDocument(
              _selectedFile!,
              displayName: _displayNameController.text,
              customMetadata: customMetadata,
            );
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Documento subido exitosamente')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un archivo')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subir Documento'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sección de selección de archivo
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Archivo',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _pickFile,
                        icon: const Icon(Icons.file_upload),
                        label: const Text('Seleccionar Archivo'),
                      ),
                      if (_selectedFile != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.insert_drive_file,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _selectedFile!.path.split('/').last,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Sección de nombre
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información del Documento',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _displayNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del Documento',
                          hintText: 'Ingresa un nombre descriptivo',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.label),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa un nombre';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Sección de metadata personalizado
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Metadata Personalizado',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          IconButton.filled(
                            onPressed: _addMetadataField,
                            icon: const Icon(Icons.add),
                            tooltip: 'Agregar campo',
                          ),
                        ],
                      ),
                      if (_metadataFields.isEmpty) ...[
                        const SizedBox(height: 12),
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 48,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No hay campos de metadata',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Puedes agregar campos personalizados',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 12),
                        ..._metadataFields.asMap().entries.map((entry) {
                          final index = entry.key;
                          final field = entry.value;
                          return _buildMetadataFieldWidget(index, field);
                        }),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Botón de subida
              FilledButton.icon(
                onPressed: _isLoading ? null : _uploadDocument,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.cloud_upload),
                label: Text(
                  _isLoading ? 'Subiendo...' : 'Subir Documento',
                  style: const TextStyle(fontSize: 16),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataFieldWidget(int index, MetadataField field) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: field.key,
                  decoration: const InputDecoration(
                    labelText: 'Clave',
                    hintText: 'ej: autor, categoria',
                    border: OutlineInputBorder(),
                    isDense: true,
                    helperText: 'Solo letras, núm, - y _',
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Requerido';
                    }
                    if (!RegExp(r'^[a-z0-9_-]+$').hasMatch(value)) {
                      return 'Inválido. Use minúsculas, números, - o _';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    // Opcional: Sanitizar mientras escribe o solo al guardar
                    // Aquí solo guardamos el valor raw, la validación avisará
                    field.key = value;
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _removeMetadataField(index),
                icon: const Icon(Icons.delete),
                color: Colors.red,
                tooltip: 'Eliminar campo',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  initialValue: field.value,
                  decoration: InputDecoration(
                    labelText: 'Valor',
                    hintText: field.type == MetadataFieldType.stringList
                        ? 'Valores separados por comas'
                        : 'Ingresa el valor',
                    border: const OutlineInputBorder(),
                    isDense: true,
                    helperText: field.type == MetadataFieldType.stringList
                        ? 'ej: valor1, valor2, valor3'
                        : null,
                  ),
                  keyboardType: field.type == MetadataFieldType.numeric
                      ? TextInputType.number
                      : TextInputType.text,
                  maxLines: field.type == MetadataFieldType.stringList ? 2 : 1,
                  onChanged: (value) {
                    field.value = value;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<MetadataFieldType>(
                  initialValue: field.type,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: MetadataFieldType.string,
                      child: Text('Texto'),
                    ),
                    DropdownMenuItem(
                      value: MetadataFieldType.numeric,
                      child: Text('Número'),
                    ),
                    DropdownMenuItem(
                      value: MetadataFieldType.stringList,
                      child: Text('Lista'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        field.type = value;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
