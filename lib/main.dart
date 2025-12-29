import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'core/di/service_locator.dart';
import 'viewmodels/chat_viewmodel.dart';
import 'viewmodels/settings_viewmodel.dart';

void main() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize service locator
    await setupServiceLocator();

    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);

    runApp(const ConverseApp());
}

class ConverseApp extends StatelessWidget {
    const ConverseApp({super.key});

    @override
    Widget build(BuildContext context) {
          return MultiProvider(
                  providers: [
                            ChangeNotifierProvider(create: (_) => getIt<ChatViewModel>()),
                            ChangeNotifierProvider(create: (_) => getIt<SettingsViewModel>()),
                          ],
                  child: Consumer<SettingsViewModel>(
                            builder: (context, settingsViewModel, child) {
                                        return MaterialApp(
                                                      title: 'Converse',
                                                      debugShowCheckedModeBanner: false,
                                                      theme: AppTheme.lightTheme,
                                                      darkTheme: AppTheme.darkTheme,
                                                      themeMode: settingsViewModel.themeMode,
                                                      initialRoute: AppRoutes.home,
                                                      onGenerateRoute: AppRoutes.generateRoute,
                                                    );
                            },
                          ),
                );
    }
}
