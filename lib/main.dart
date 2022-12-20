import 'package:admin_panel_customers_app/providers/dark_theme_provider.dart';
import 'package:admin_panel_customers_app/screens/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'consts/theme_data.dart';
import 'inner_screens/add_prod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  void getCurrentAppTheme() async {
    themeChangeProvider.setDarkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
  }

  @override
  void initState() {
    getCurrentAppTheme();
    super.initState();
  }

  final Future<FirebaseApp> _initialization = Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyCXyxqG_ddESiG4JehR2QyqqxXVboz2ESY",
          authDomain: "fyp2-d8f8a.firebaseapp.com",
          projectId: "fyp2-d8f8a",
          storageBucket: "fyp2-d8f8a.appspot.com",
          messagingSenderId: "558406920915",
          appId: "1:558406920915:web:94cfeb457ea357a2194226",
          measurementId: "G-2972Z18Y5H"));

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(
                  child: Center(
                    child: Text('App is being initialized'),
                  ),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(
                  child: Center(
                    child: Text('An error has been occured ${snapshot.error}'),
                  ),
                ),
              ),
            );
          }
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) {
                  return themeChangeProvider;
                },
              ),
            ],
            child: Consumer<DarkThemeProvider>(
              builder: (context, themeProvider, child) {
                return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    title: 'SKIN4U',
                    theme:
                        Styles.themeData(themeProvider.getDarkTheme, context),
                    home: const Home(),
                    routes: {
                      AddProducts.routeName: (context) => const AddProducts(),
                    });
              },
            ),
          );
        });
  }
}
