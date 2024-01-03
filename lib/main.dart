import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:wechat/firebase_options.dart';
import 'package:wechat/splash_screen.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  _initializeAppFirebase();
  runApp(const MyApp());
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
        )
      ),
     home:const SplashScreen()
    );
  }
}
_initializeAppFirebase()async{
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  var result = await FlutterNotificationChannel.registerNotificationChannel(
    description: 'For Showing Chats Messages',
    id: 'chat',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chats',
  );
}