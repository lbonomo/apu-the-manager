import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/store_providers.dart';
import 'create_store_screen.dart';
import 'store_details_screen.dart';

import 'settings_screen.dart';

class StoresScreen extends ConsumerWidget {
  const StoresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storesAsync = ref.watch(storesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('File Search Stores'),
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
          if (stores.isEmpty) {
            return const Center(child: Text('No stores found.'));
          }
          return ListView.builder(
            itemCount: stores.length,
            itemBuilder: (context, index) {
              final store = stores[index];
              return ListTile(
                title: Text(store.displayName ?? store.name),
                subtitle: Text(store.name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    try {
                      await ref
                          .read(storesListProvider.notifier)
                          .deleteStore(store.name);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Store deleted')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    }
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          StoreDetailsScreen(storeId: store.name),
                    ),
                  );
                },
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
