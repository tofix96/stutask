import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Import dla kIsWeb
import 'package:provider/provider.dart'; // Import dla Provider
import 'package:firebase_app_check/firebase_app_check.dart'; // Import App Check
import 'package:stutask/screens/application_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home.dart'; // Import HomePage
import 'bloc/auth_providers.dart' as custom_auth; // Import AuthProvider
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase User
import 'screens/seetings_screen.dart';
import 'screens/user_info_screen.dart'; // Import UserInfoScreen
import 'package:stutask/screens/task_detail_screen.dart';
import 'package:stutask/screens/chat_screen.dart';
import 'package:stutask/screens/chats_overview_screen.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Upewnij się, że Flutter jest zainicjowany

  // Inicjalizacja Firebase
  await Firebase.initializeApp(
    options: kIsWeb
        ? const FirebaseOptions(
            apiKey: "AIzaSyD8EwmPJFpulW7lFpHlXOb-VR3tnSutI38",
            authDomain: "stutask-52ad6.firebaseapp.com",
            projectId: "stutask-52ad6",
            storageBucket: "stutask-52ad6.appspot.com",
            messagingSenderId: "618977047861",
            appId: "1:618977047861:web:b71a855270d76ae062887c",
            measurementId: "G-DPVVFX7WYV",
          )
        : null, // Dla aplikacji mobilnych Firebase sam pobierze konfigurację
  );

  // Aktywacja Firebase App Check
  await FirebaseAppCheck.instance.activate(
    webProvider: kIsWeb
        ? null // ReCaptcha dla Web
        : null, // domyślna aktywacja dla Androida i iOS
  );

  runApp(const MyApp());
}

// App StuTask
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => custom_auth.AuthProvider(), // Dodanie AuthProvider
      child: MaterialApp(
        debugShowCheckedModeBanner: false, // Usunięcie "debug" z ekranu
        initialRoute: '/', // Domyślna trasa (login)
        routes: {
          '/': (context) => const LoginPage(),
          '/home': (context) => HomePage(
                user: FirebaseAuth.instance.currentUser,
                showEmployerTasks: false,
              ),
          '/home-employer-tasks': (context) => HomePage(
              user: FirebaseAuth
                  .instance.currentUser), // Zadania danego pracodawcy
          '/user-info': (context) => UserInfoScreen(),
          '/settings': (context) => SettingsScreen(),
          '/task-detail': (context) => TaskDetailScreen(),
          '/applications': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map;
            return ApplicationsScreen(taskId: args['taskId']);
          },
          '/chat-overview': (context) => ChatOverviewScreen(),
          '/chat': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map;
            return ChatScreen(chatId: args['chatId']);
          },
        },
      ),
    );
  }
}
