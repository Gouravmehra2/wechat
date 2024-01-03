import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wechat/apis.dart';
import 'package:wechat/home_screen.dart';
import 'package:wechat/snackbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  btnclick(){
    Dialogs.showSnackbar(context, 'Something went wrong');
    signInWithGoogle().then((user) async {
      if(await Apis.userexist()){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>const Home())
        );
      }else{
        await Apis.createUser().then((value) {
          Navigator.push(context, MaterialPageRoute(builder: (context)=>const Home())
          );
        });
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height*1;
    final width = MediaQuery.sizeOf(context).width*1;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(automaticallyImplyLeading: false,),
      body: Stack(
        children: [
          Positioned(
              top: height * .20,
              left: width * .15,
              right: width * .15,
              child: const Image(image: NetworkImage('https://th.bing.com/th/id/OIP.tUobx_sNyk4L6zk7ZffI5AHaFj?rs=1&pid=ImgDetMain')
              )
          ),
          Positioned(
              bottom: height * .15,
              left: width * .15,
              right: width * .15,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                onPressed: (){
                  btnclick();
                },
                child: Row(
                  children: [
                    Image(height: height * .045,
                      image: const NetworkImage('https://img.icons8.com/?size=256&id=17949&format=png'),),
                    const SizedBox(width: 5,),
                    const Text('Sign In With Google',style: TextStyle(fontWeight: FontWeight.bold),)
                  ],
                ),
              )

          )
        ],
      ),
    );
  }
}
