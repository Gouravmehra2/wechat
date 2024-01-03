import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:wechat/apis.dart';
import 'package:wechat/home_screen.dart';
import 'package:wechat/login_screen.dart';
// import 'package:social_media_buttons/social_media_button.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(const Duration(seconds: 5),(){
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(systemNavigationBarColor: Colors.white,statusBarColor: Colors.white));
      final user = Apis.user?.uid;
      if(user != null){
        // print('chatuser name : ${chatuser.name}');
        Navigator.push(context, MaterialPageRoute(builder:(context) =>const Home()));
      }else{
        Navigator.push(context, MaterialPageRoute(builder:(context) => const LoginScreen()));
      }
      // if(await Apis.userexist()){
      //   print('1');
      //   Navigator.push(context, MaterialPageRoute(builder: (context)=>Home())
      //   );
      // }else{
      //   print('2');
      //   await Apis.createUser().then((value) {
      //     Navigator.push(context, MaterialPageRoute(builder: (context)=>Home())
      //     );
      //   });
      // }
    });
  }
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height*1;
    final width = MediaQuery.sizeOf(context).width*1;
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          Positioned(
              top: height * .20,
              left: width * .15,
              right: width * .15,
              child: const Image(
                  image: AssetImage('images/maipic.jpg')
              )
          ),
          Positioned(
              bottom: height * .15,
              left: width * .15,
              right: width * .15,
              child: const SpinKitFadingCircle(color: Colors.blue,size: 25,)
          )
        ],
      ),
    );
  }
}
