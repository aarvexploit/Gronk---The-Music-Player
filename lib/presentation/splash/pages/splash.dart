import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gronk/common/helpers/is_dark.dart';
import 'package:gronk/core/configs/assets/app_vectors.dart';
import 'package:gronk/presentation/home/pages/home.dart';
import 'package:gronk/presentation/intro/pages/get_started.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {


  var auth = FirebaseAuth.instance;
  var isLogin = false;

  checkiflogin() async {
    auth.authStateChanges().listen((User? user) {
      if(user != null && mounted){
        setState(() {
          isLogin = true;
        });
      }
    });
  }

  @override
  void initState(){
    checkiflogin();
    super.initState();
    redirect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.none,
              image: AssetImage(
          context.isDarkMode ? AppVectors.lightlogo : AppVectors.darklogo
        )
        
            )
          ),
        )
        
        //SvgPicture.asset(
          //context.isDarkMode ? AppVectors.darklogo : AppVectors.lightlogo
        //)
        ),
    );
  }

  Future<void> redirect() async{
    await Future.delayed(const Duration(seconds: 2));
    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(
      builder: (BuildContext context) => isLogin ? const HomePage() : const GetStartedPage()
      )
    );
  }
}