import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/document_providers.dart';
import 'upload_document_screen.dart';

class StoreDetailsScreen extends ConsumerWidget {
  final String storeId;

  const StoreDetailsScreen({super.key, required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsAsync = ref.watch(documentsListProvider(storeId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Documents'),
      ),
      body: documentsAsync.when(
        data: (documents) {
          if (documents.isEmpty) {
            return const Center(child: Text('No documents found.'));
          }
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final document = documents[index];
              return ListTile(
                title: Text(document.displayName ?? document.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ID: ${document.name}'),
                    Text('State: ${document.state.name}'),
                    if (document.mimeType != null) Text('Type: ${document.mimeType}'),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    try {
                      await ref.read(documentsListProvider(storeId).notifier).deleteDocument(document.name);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Document deleted')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
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
}
