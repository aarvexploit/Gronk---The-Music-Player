import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gronk/core/configs/constants/app_urls.dart';
import 'package:gronk/data/models/auth/create_user_req.dart';
import 'package:gronk/data/models/auth/signin_user_req.dart';
import 'package:gronk/data/models/auth/user.dart';
import 'package:gronk/doamin/entities/auth/user.dart';

abstract class AuthFirebaseServices {

  Future<Either> signup(CreateUserReq createUserReq);

  Future<Either> signin(SigninUserReq signinUserReq);

  Future<Either> getUser();

}


class AuthFirebaseServicesImpl extends AuthFirebaseServices {
  @override
  Future<Either> signin(SigninUserReq signinUserReq) async {
    try {

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: signinUserReq.email, 
        password: signinUserReq.password
        );

        return const Right('Signin Succesfully');

    }on FirebaseAuthException catch(e) {
      String message = "";

      if(e.code == 'invalid-email'){
        message = 'No User Found for email';
      } else if(e.code == 'invalid-credentials'){
        message = 'Wrong Password';
      }

      return left(message);
    }
  }

  @override
  Future<Either> signup(CreateUserReq createUserReq) async {
    try {

      var data = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: createUserReq.email, 
        password: createUserReq.password
        );

        FirebaseFirestore.instance.collection('Users').doc(data.user?.uid).set(
          {
            'name' : createUserReq.fullName,
            'email' : data.user?.email
          }
        );

        return const Right('Signed up Succesfully');

    }on FirebaseAuthException catch(e) {
      String message = "";

      if(e.code == 'weak-password'){
        message = 'Password is Weak';
      } else if(e.code == 'emil-already-in-use'){
        message = 'Account alreasy Registered with email';
      }

      return left(message);
    }
  }
  
  @override
  Future<Either> getUser() async {
    try {
      FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

      var user = await firebaseFirestore.collection('Users').doc(
        firebaseAuth.currentUser?.uid
      ).get();

      UserModel userModel = UserModel.fromJson(user.data() !);
      userModel.imageURL = firebaseAuth.currentUser?.photoURL ?? AppUrls.defaultImage;

      UserEntity userEntity = userModel.toEntity();
      return Right(userEntity);
    } catch (e) {
      return const Left("An error Occured");
    }


    }
  
}