import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_flutter_notification/views/second_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_flutter_notification/viewmodels/auth_viewmodel.dart';
import 'package:firebase_flutter_notification/viewmodels/home_viewmodel.dart';
import 'package:firebase_flutter_notification/viewmodels/notes_viewmodel.dart';
import 'package:firebase_flutter_notification/viewmodels/account_viewmodel.dart';
import 'package:firebase_flutter_notification/views/login_page.dart';
import 'package:firebase_flutter_notification/views/register_page.dart';
import 'package:firebase_flutter_notification/views/home_page.dart';
import 'package:firebase_flutter_notification/views/notes_page.dart';
import 'package:firebase_flutter_notification/views/account_page.dart';
import 'package:firebase_flutter_notification/services/notification.dart';
import 'package:firebase_flutter_notification/services/firestore.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');

  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initializeNotification();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        Provider(create: (_) => FirestoreService()),
        Provider(create: (_) => NotificationService()),

        // ViewModels
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProxyProvider<AuthViewModel, HomeViewModel>(
          create: (context) => HomeViewModel(context.read<AuthViewModel>()),
          update: (context, auth, previous) => HomeViewModel(auth),
        ),
        ChangeNotifierProxyProvider2<AuthViewModel, FirestoreService,
            NotesViewModel>(
          create: (context) => NotesViewModel(
            context.read<FirestoreService>(),
            context.read<AuthViewModel>(),
          ),
          update: (context, auth, firestore, previous) =>
              NotesViewModel(firestore, auth),
        ),
        ChangeNotifierProxyProvider<AuthViewModel, AccountViewModel>(
          create: (context) => AccountViewModel(context.read<AuthViewModel>()),
          update: (context, auth, previous) => AccountViewModel(auth),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
          useMaterial3: true,
        ),
        navigatorKey: navigatorKey,
        home: Consumer<AuthViewModel>(
          builder: (context, authViewModel, _) {
            if (authViewModel.isLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // Only navigate to home if we're not already on the login page
            if (authViewModel.isAuthenticated &&
                ModalRoute.of(context)?.settings.name != 'login') {
              return const MyHomePage();
            }

            return const LoginPage();
          },
        ),
        routes: {
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/home': (context) => const MyHomePage(),
          '/notes': (context) => const NotesPage(),
          '/account': (context) => const AccountPage(),
          '/second': (context) => const SecondPage(),
        },
      ),
    );
  }
}
