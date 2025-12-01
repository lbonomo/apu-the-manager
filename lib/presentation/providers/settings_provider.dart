import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'core_providers.dart';
import 'settings_state.dart';

part 'settings_provider.g.dart';

@riverpod
class Settings extends _$Settings {
  @override
  Future<SettingsState> build() async {
    final repository = ref.watch(settingsRepositoryProvider);
    final loggingEnabled = await repository.getLoggingEnabled();
    final apiKey = await repository.getGeminiApiKey();

    // Update logger service
    ref.read(loggerServiceProvider).setEnabled(loggingEnabled);

    return SettingsState(loggingEnabled: loggingEnabled, apiKey: apiKey);
  }

  Future<void> toggleLogging(bool enabled) async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.setLoggingEnabled(enabled);

    // Update logger service
    ref.read(loggerServiceProvider).setEnabled(enabled);

    state = AsyncValue.data(state.value!.copyWith(loggingEnabled: enabled));
  }

  Future<void> setApiKey(String apiKey) async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.setGeminiApiKey(apiKey);

    state = AsyncValue.data(state.value!.copyWith(apiKey: apiKey));
  }
}
