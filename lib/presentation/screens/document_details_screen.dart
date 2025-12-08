import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/document.dart';
import 'package:intl/intl.dart';

class DocumentDetailsScreen extends StatelessWidget {
  final Document document;

  const DocumentDetailsScreen({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(document.displayName ?? document.name.split('/').last),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: document.name));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ID copiado al portapapeles')),
              );
            },
            tooltip: 'Copiar ID',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información General
            _buildSectionTitle(context, 'Información General'),
            const SizedBox(height: 8),
            _buildInfoTable(context, [
              _InfoRow('ID', document.name),
              _InfoRow('Nombre', document.displayName ?? 'N/A'),
              _InfoRow('Estado', _getStateText(document.state)),
              _InfoRow('Tipo MIME', document.mimeType ?? 'N/A'),
              _InfoRow('Tamaño', _formatBytes(document.sizeBytes)),
              _InfoRow(
                'Creado',
                document.createTime != null
                    ? DateFormat('dd/MM/yyyy HH:mm:ss').format(document.createTime!)
                    : 'N/A',
              ),
              _InfoRow(
                'Actualizado',
                document.updateTime != null
                    ? DateFormat('dd/MM/yyyy HH:mm:ss').format(document.updateTime!)
                    : 'N/A',
              ),
            ]),

            // Custom Metadata
            if (document.customMetadata != null && document.customMetadata!.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'Metadatos Personalizados'),
              const SizedBox(height: 8),
              _buildMetadataTable(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildInfoTable(BuildContext context, List<_InfoRow> rows) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(2),
          },
          children: rows.map((row) {
            return TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    row.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: SelectableText(
                    row.value,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMetadataTable(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Table(
          border: TableBorder.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
          columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(2),
          },
          children: [
            // Header
            TableRow(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Clave',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Valor',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            // Data rows
            ...document.customMetadata!.map((metadata) {
              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      metadata.key,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SelectableText(
                      metadata.displayValue,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  String _getStateText(DocumentState state) {
    switch (state) {
      case DocumentState.active:
        return 'ACTIVO';
      case DocumentState.pending:
        return 'PENDIENTE';
      case DocumentState.failed:
        return 'FALLIDO';
      case DocumentState.unspecified:
        return 'NO ESPECIFICADO';
    }
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
}

class _InfoRow {
  final String label;
  final String value;

  _InfoRow(this.label, this.value);
}
