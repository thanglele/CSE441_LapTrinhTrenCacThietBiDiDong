import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/home_page_lecture.dart';

const Color tluPrimaryColor = Color(0xFF0D47A1);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TLU Attendance System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: tluPrimaryColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: tluPrimaryColor,
          foregroundColor: Colors.white,
        ),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
        ).copyWith(
          primary: tluPrimaryColor,
        ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}