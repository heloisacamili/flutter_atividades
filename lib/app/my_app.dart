import 'package:atividade/screens/home_screen.dart';
import 'package:atividade/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeService(),
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            title: 'App Usuários Firebase',
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: themeService.themeMode,
            home: HomeScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}