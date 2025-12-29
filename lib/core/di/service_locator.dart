import 'package:get_it/get_it.dart';

import '../../services/llm_service.dart';
import '../../services/speech_service.dart';
import '../../services/storage_service.dart';
import '../../services/audio_service.dart';
import '../../viewmodels/chat_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
    // Services
    getIt.registerLazySingleton<StorageService>(() => StorageService());
    getIt.registerLazySingleton<LLMService>(() => LLMService());
    getIt.registerLazySingleton<SpeechService>(() => SpeechService());
    getIt.registerLazySingleton<AudioService>(() => AudioService());

    // Initialize storage service
    await getIt<StorageService>().init();

    // ViewModels
    getIt.registerFactory<ChatViewModel>(
          () => ChatViewModel(
                  llmService: getIt<LLMService>(),
                  speechService: getIt<SpeechService>(),
                  audioService: getIt<AudioService>(),
                  storageService: getIt<StorageService>(),
                ),
        );

    getIt.registerFactory<SettingsViewModel>(
          () => SettingsViewModel(
                  storageService: getIt<StorageService>(),
                ),
        );
}
