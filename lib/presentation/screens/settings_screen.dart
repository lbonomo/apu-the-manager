import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../providers/core_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _apiKeyController;
  String? _logFilePath;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController();
    _loadLogFilePath();
  }

  Future<void> _loadLogFilePath() async {
    final loggerService = ref.read(loggerServiceProvider);
    final filePath = await loggerService.getLogFilePath();
    setState(() {
      _logFilePath = filePath;
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: settingsAsync.when(
        data: (settings) {
          // Update text only if controller is empty (initial load) or
          // if we want to force sync, but be careful not to overwrite user typing.
          // Better approach: initialize once in initState or when data is first available.
          // For simplicity here, we'll set it if it's not currently being edited
          // or if it matches the "old" known value.
          // Ideally, we just set it once.

          if (_apiKeyController.text.isEmpty && settings.apiKey != null) {
            _apiKeyController.text = settings.apiKey!;
          }

          return ListView(
            children: [
              Tooltip(
                message: settings.loggingEnabled && _logFilePath != null
                    ? 'Ubicación del archivo: $_logFilePath'
                    : 'Los logs se guardarán cuando estén habilitados',
                child: SwitchListTile(
                  title: const Text('Habilitar Logs'),
                  subtitle: const Text(
                    'Activa o desactiva el registro de eventos de la aplicación.',
                  ),
                  value: settings.loggingEnabled,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).toggleLogging(value);
                  },
                ),
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
                      controller: _apiKeyController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Ingrese su API Key',
                        helperText:
                            'Presione el botón guardar para aplicar cambios',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ref
                              .read(settingsProvider.notifier)
                              .setApiKey(_apiKeyController.text);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Configuración guardada'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
