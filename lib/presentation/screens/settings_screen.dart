import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: settingsAsync.when(
        data: (settings) => ListView(
          children: [
            SwitchListTile(
              title: const Text('Habilitar Logs'),
              subtitle: const Text(
                'Activa o desactiva el registro de eventos de la aplicación.',
              ),
              value: settings.loggingEnabled,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).toggleLogging(value);
              },
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gemini API Key',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: TextEditingController(text: settings.apiKey),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Ingrese su API Key',
                    ),
                    onSubmitted: (value) {
                      ref.read(settingsProvider.notifier).setApiKey(value);
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Presione Enter para guardar.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
