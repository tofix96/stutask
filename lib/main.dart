import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Import dla kIsWeb
import 'package:provider/provider.dart'; // Import dla Provider
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:stutask/screens/moderator/admin_review_screen.dart';
import 'package:stutask/screens/tasks/application_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home.dart';
import 'bloc/auth_providers.dart' as custom_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/profile/seetings_screen.dart';
import 'screens/profile/user_info_screen.dart';
import 'package:stutask/screens/tasks/task_detail_screen.dart';
import 'package:stutask/screens/tasks/assigned_tasks_screen.dart';
import 'package:stutask/screens/chat/chat_screen.dart';
import 'package:stutask/screens/chat/chats_overview_screen.dart';
import 'package:stutask/bloc/user_service.dart';
import 'package:stutask/bloc/task_service.dart';
import 'package:stutask/screens/moderator/admin_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
        : null,
  );

  await FirebaseAppCheck.instance.activate(
    webProvider: kIsWeb ? ReCaptchaV3Provider('site-key') : null,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<UserService>(create: (_) => UserService()),
        Provider<TaskService>(create: (_) => TaskService()),
        Provider<custom_auth.AuthProvider>(
          create: (_) => custom_auth.AuthProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => custom_auth.AuthProvider(),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Color.fromARGB(255, 51, 52, 58),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.deepOrange,
          ).copyWith(
            secondary: Color.fromARGB(255, 51, 52, 58),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 51, 52, 58)),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFEF6C00)),
            ),
            labelStyle: TextStyle(
              color: Color.fromARGB(255, 51, 52, 58),
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.black45,
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginPage(),
          '/home': (context) => HomePage(
                user: FirebaseAuth.instance.currentUser,
                showEmployerTasks: false,
              ),
          '/assigned-tasks': (context) => AssignedTasksScreen(
                user: FirebaseAuth.instance.currentUser!,
                accountType: 'Pracownik',
              ),
          '/user-info': (context) => UserInfoScreen(),
          '/settings': (context) => SettingsScreen(),
          '/task-detail': (context) => TaskDetailScreen(),
          '/applications': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map;
            return ApplicationsScreen(taskId: args['taskId']);
          },
          '/admin': (context) =>
              AdminPage(user: FirebaseAuth.instance.currentUser!),
          '/chat-overview': (context) => ChatOverviewScreen(),
          '/chat': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map;
            return ChatScreen(chatId: args['chatId'], taskId: args['taskId']);
          },
          '/admin-review-screen': (context) => AdminReviewsScreen(),
        },
      ),
    );
  }
}
