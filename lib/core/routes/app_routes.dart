import 'package:flutter/material.dart';

import '../../views/home/home_view.dart';
import '../../views/chat/chat_view.dart';
import '../../views/settings/settings_view.dart';

class AppRoutes {
    AppRoutes._();

    // Route names
    static const String home = '/';
    static const String chat = '/chat';
    static const String settings = '/settings';

    // Route generator
    static Route<dynamic> generateRoute(RouteSettings settings) {
          switch (settings.name) {
            case home:
                      return _buildRoute(const HomeView(), settings);

            case chat:
                      final args = settings.arguments as Map<String, dynamic>?;
                      return _buildRoute(
                                  ChatView(conversationId: args?['conversationId']),
                                  settings,
                                );

            case AppRoutes.settings:
                      return _buildRoute(const SettingsView(), settings);

            default:
                      return _buildRoute(
                                  const Scaffold(
                                                body: Center(
                                                                child: Text('Page not found'),
                                                              ),
                                              ),
                                  settings,
                                );
          }
    }

    // Helper method to build routes with transitions
    static PageRouteBuilder _buildRoute(Widget page, RouteSettings settings) {
          return PageRouteBuilder(
                  settings: settings,
                  pageBuilder: (context, animation, secondaryAnimation) => page,
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOut;

                            var tween = Tween(begin: begin, end: end).chain(
                                        CurveTween(curve: curve),
                                      );

                            return SlideTransition(
                                        position: animation.drive(tween),
                                        child: child,
                                      );
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                );
    }

    // Navigation helpers
    static void navigateToChat(BuildContext context, {String? conversationId}) {
          Navigator.pushNamed(
                  context,
                  chat,
                  arguments: {'conversationId': conversationId},
                );
    }

    static void navigateToSettings(BuildContext context) {
          Navigator.pushNamed(context, settings);
    }

    static void navigateToHome(BuildContext context) {
          Navigator.pushNamedAndRemoveUntil(context, home, (route) => false);
    }
}
